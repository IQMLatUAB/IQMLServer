%{
  The MIT License (MIT)
  
  Copyright (c) 2013 Bronson Philippa
  
  Permission is hereby granted, free of charge, to any person obtaining a copy of
  this software and associated documentation files (the "Software"), to deal in
  the Software without restriction, including without limitation the rights to
  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
  the Software, and to permit persons to whom the Software is furnished to do so,
  subject to the following conditions:
  
  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.
  
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  
%}

function start_server(timeout_seconds)
% JOBMGR.SERVER.START Start the job server

    % How long can we wait without an update before we assume that a client
    % has been lost, and resubmit that job to a different worker?
    if nargin < 1
        timeout_seconds = 10 * 60; % 10 minutes
    end

    % Store scheduled jobs here
    jobs = containers.Map; % keys = hashes, values = jobs structure
    jobs_duplicate_control= containers.Map; % create hashmap to calculate same duplicate jobs
    
    % Store statistics 
    stats = struct();
    stats.jobs_completed = 0;

    % Are we currently quitting?
    quitting = false;
    quit_when_idle = true;
   

    % Measure the rate of transactions
    transaction_count = 0;
    
    % Check which function handles we have served results for, so that we
    % can check the memoise cache if this is a new function handle
    functions_memoised = containers.Map();
    
    % Status update timer
    update_timer = timer('Period', 5, 'ExecutionMode', 'fixedRate', 'TimerFcn', @print_status);
    start(update_timer);
    
    % Run the server inside a subfunction so that when it quits, the
    % garbage collector will trigger the onCleanup event. We can't do this
    % here (in the top level) because the timer holds a handle to the
    % sub-function @print_status, which closes over any variables created
    % at this level and hence prevents the GC from clearing them even after
    % the function has quit.
    start_server();
    function start_server
        canary = onCleanup(@()stop(update_timer));
        fprintf('Starting the server. Press Ctrl+C to quit.\n');
        jobmgr.netsrv.start_server(@request_callback, jobmgr.server.tcp_port);
    end
    
    function response = request_callback(request)
        response = struct();
        response.status = 'OK';
        transaction_count = transaction_count + 1;
        
        switch request.msg
            case 'check_server_connection'
                response.status = 'Server connected !';
                response.result = [];
            case 'check_job'
                % Have we already computed the answer?
                hash = request.argument;
                [result, in_cache] = jobmgr.recall(@jobmgr.example.solver , hash);
                
                response.result = result;
                
                if isempty(response.result)
                    if isKey(jobs, request.argument)
		                job_to_check = jobs(request.argument);
		                hashes = keys(jobs);
		                num = 1;
		                if ~job_to_check.running % Check if this job is being processed
		                    for i = randperm(numel(hashes))
		                        job = jobs(hashes{i});
		                        if ~job.running && (now() - job.last_touch() > now() -job_to_check.last_touch()) % Check how amny jobs are enqueued
		                            num =num +1;
		                        end
		                    end
		                    waitingmin = num2str(num*3);
		                    num = num2str(num);
		                    response.status = append('This job is No.',num,' in the server waiting list. Approximate waiting time: ',waitingmin,' minutes.');
		                else % This job is being processed
		                    response.status = 'This job is being processed in the server.';
		                end
                    end
                else
                    if jobs_duplicate_control.isKey(hash)
                        jobs_duplicate_control(hash) = jobs_duplicate_control(hash) -1;
                        if (jobs_duplicate_control(hash) <=0)
                            jobs_duplicate_control.remove(hash);
                            [path, cache_dir] = jobmgr.return_cache_filename(@jobmgr.example.solver, request.argument);
                            delete(path);
                            if(numel(dir(cache_dir)))<=2
                                [~,~,~] = rmdir(cache_dir);
                            end
                        end
                    end
                end
                
            case 'cancel_job'
                if isKey(jobs, request.argument) && jobs_duplicate_control.isKey(request.argument) % check if there are two people upload the same job...
                    jobs_duplicate_control(request.argument) = jobs_duplicate_control(request.argument) -1;
                    job_to_cancel = jobs(request.argument);
                    if(jobs_duplicate_control(request.argument) <=0) && ~job_to_cancel.running
                        jobs_duplicate_control.remove(request.argument);
                        jobs.remove(request.argument);
                        % There is a warning msg if the file doesn't exist...
			            delete(append(pwd,'/wait_for_process/',job_to_cancel.hash,'T1','.mat'));
			            delete(append(pwd,'/wait_for_process/',job_to_cancel.hash,'T1post','.mat'));
			            delete(append(pwd,'/wait_for_process/',job_to_cancel.hash,'T2','.mat'));
			            delete(append(pwd,'/wait_for_process/',job_to_cancel.hash,'FLAIR','.mat'));
                    	delete(append(pwd,'/wait_for_process/',request.argument,'.mat'));
                    end
%                                         job_to_cancel = jobs(request.argument);
%                     
%                                         if jobs.isKey(job_to_cancel.hash) && ~job_to_cancel.running
%                                             jobs.remove(job_to_cancel.hash);
%                                         end
%                                         delete(append(pwd,'/wait_for_process/',request.argument,'.mat'));
                end
                response.result = [];

            case 'quit_workers'
                quitting = true;
            case 'quit_workers_when_idle'
                quit_when_idle = true;
            case 'accept_workers'
                quitting = false;
                quit_when_idle = false;
            case 'set_timeout'
                if isfield(request, 'argument') && isnumeric(request.argument) && isscalar(request.argument) && request.argument > 0
                    timeout_seconds = request.argument;
                else
                    response.status = 'Error';
                end
            case 'enqueue_job'
                job = request.job;
                
                % Have we initialised memoisation of this solver?
                if ~functions_memoised.isKey(char(job.config.solver))
                    functions_memoised(char(job.config.solver)) = true;
                    jobmgr.check_cache(job.config.solver);
                end
                
                % Have we already computed the answer?
                [result, in_cache] = jobmgr.recall(job.config.solver, job.hash);
                
                response.result = result;
                % Silently discard jobs that are already running
                if ~in_cache && ~jobs.isKey(job.hash)
                    % Job is new
                    job.running = false;
                    job.last_touch = now();
                    [~, num_data] = size(job.config.input);
                    if(num_data == 4)
		                fileID = fopen(append(pwd,'/wait_for_process/', job.hash, 'T1', '.mat'),'w');
		                fwrite(fileID, job.config.input{1},'*int8');
		                fclose(fileID);
		                fileID = fopen(append(pwd,'/wait_for_process/', job.hash, 'T1post', '.mat'),'w');
		                fwrite(fileID, job.config.input{2},'*int8');
		                fclose(fileID);
		                fileID = fopen(append(pwd,'/wait_for_process/', job.hash, 'T2', '.mat'),'w');
		                fwrite(fileID, job.config.input{3},'*int8');
		                fclose(fileID);
		                fileID = fopen(append(pwd,'/wait_for_process/', job.hash, 'FLAIR', '.mat'),'w');
		                fwrite(fileID, job.config.input{4},'*int8');
		                fclose(fileID);
                    elseif(num_data == 1)
                    	fileID = fopen(append(pwd,'/wait_for_process/', job.hash, '.mat'),'w');
                    	fwrite(fileID, job.config.input,'*int8');
                    	fclose(fileID);
                    end
                    job.config.input = 0; % prevent cache memory explosion
                    job.complete = false;
                    % Add to jobs hashmap
                    jobs(job.hash) = job;
                    if ~jobs_duplicate_control.isKey(job.hash) % use hashmap to handle duplicates when same jobs upload to server
                        jobs_duplicate_control(job.hash) = 1; % add new key, set value as 1
                    else % if same job exist, increase key count
                        jobs_duplicate_control(job.hash) = jobs_duplicate_control(job.hash) + 1;
                    end
                    response.result = result;
                elseif in_cache && jobs.isKey(job.hash) && job.complete
                    response.result = result;
                end
            case 'ready_for_work'
                if quitting
                    response.status = 'Quit';
                    return;
                end
                
                response.status = 'Wait';
                % Look for a job to do
                hashes = keys(jobs);
                temp={};
                temp.last_touch = 0;
                waiting_time = 0;
                % First find jobs that we've never sent to any worker
                for i = randperm(numel(hashes))
                    job = jobs(hashes{i});
                    if ~job.running && ~job.complete
                    	% check which job is waiting for the longest time,
                        % assign 'temp' to store it.
                        if (now() - job.last_touch) > waiting_time
                            temp = job;
                            waiting_time = (now() - job.last_touch);
                        end

                    end
                end
                % Now, temp is the longest job structure
                % last touch != 0 means there is a job in job queue.
                if temp.last_touch ~= 0 % send worker the longest waiting job in server
                    job = temp;
                    response.status = 'OK';
                    if job.config.softnum < 1000 % DeepBT
		                fileID = fopen(append(pwd,'/wait_for_process/', job.hash,'T1', '.mat'),'r');
		                rawdata = fread(fileID, '*int8');
		                [s,~] = size(rawdata);
		                job.config.input = cell(s,1);
		                job.config.input{1} = rawdata;
		                fclose(fileID);
		                fileID = fopen(append(pwd,'/wait_for_process/', job.hash,'T1post', '.mat'),'r');
		                rawdata = fread(fileID, '*int8');
		                job.config.input{2} = rawdata;
		                fclose(fileID);
		                fileID = fopen(append(pwd,'/wait_for_process/', job.hash,'T2', '.mat'),'r');
		                rawdata = fread(fileID, '*int8');
		                job.config.input{3} = rawdata;
		                fclose(fileID);
		                fileID = fopen(append(pwd,'/wait_for_process/', job.hash,'FLAIR', '.mat'),'r');
		                rawdata = fread(fileID, '*int8');
		                job.config.input{4} = rawdata;
		                fclose(fileID);
	                elseif job.config.softnum >= 1000
			            fileID = fopen(append(pwd, '/wait_for_process/', job.hash, '.mat'),'r');
		                rawdata = fread(fileID, '*int8');
		                [s,~] = size(rawdata);
		                job.config.input = cell(s,1);
		                job.config.input{1} = rawdata;
		                fclose(fileID);
                    end
                    
                    response.job = job;

                    % Update our list
                    job.running = true;
                    job.last_touch = now();
                    jobs(temp.hash) = job;
                    temp = {};
                end
                % If all jobs have been submitted, re-send any where the worker
                % has disappeared (e.g. crashed, shut down, ...)
                if ~strcmp(response.status, 'OK')
                    for i = randperm(numel(hashes))
                        job = jobs(hashes{i});
                        if (now() - job.last_touch) * 24 * 60 * 60 > timeout_seconds
                            % Send to the worker
                            response.status = 'OK';
                            response.job = job;
                            
                            % Update our list
                            job.running = true;
                            job.last_touch = now();
                            jobs(hashes{i}) = job;
                            break;
                        end
                    end
                end
                
                if strcmp(response.status, 'Wait') && quit_when_idle
                    % If we didn't find any jobs and we have been
                    % instructed to quit workers when idle, tell them to
                    % quit.
                    response.status = 'Quit';
                end
                
            case 'update_job'
                % Silently ignore jobs that we don't know about
                if jobs.isKey(request.hash)
                    % Load it from the hashmap
                    job = jobs(request.hash);
                    
                    % Set the status
                    job.status = request.status;
                    job.last_touch = now();
                    job.running = true; % if the server restarts while a client is still running
                    
                    % Save it back into the jobs hashmap
                    jobs(request.hash) = job;
                end
                
            case 'finish_job'
                % Load the job that we finished
                job = request.job;
                
                % Save the result
                jobmgr.store(job.config.solver, job.hash, request.result);
                job.complete = true;
                job.config.input = 0;
                delete(append(pwd,'/wait_for_process/',job.hash,'T1','.mat'));
                delete(append(pwd,'/wait_for_process/',job.hash,'T1post','.mat'));
                delete(append(pwd,'/wait_for_process/',job.hash,'T2','.mat'));
                delete(append(pwd,'/wait_for_process/',job.hash,'FLAIR','.mat'));
                delete(append(pwd,'/wait_for_process/',job.hash,'.mat'));
                %Remove it from the store
                if jobs.isKey(job.hash)
                    jobs.remove(job.hash);
                end
                
                % Update the stats
                stats.jobs_completed = stats.jobs_completed + 1;
                
            otherwise
                fprintf('Received an unknown message: %s\n', request.msg);
        end
        
        % Update the display
        print_status();
    end

    function print_status(timer, ~)
        persistent last_print;
        if isempty(last_print)
            last_print = tic();
        end
        
        if toc(last_print) < 2 && ~quitting
            return;
        end

        clc;

        fprintf('Job Server. Listening on port %i. Press Ctrl+C to quit.\n', jobmgr.server.tcp_port);

        if quitting
            fprintf('*** Telling workers to quit ***\n');
        end

        if quit_when_idle
            fprintf('Will quit workers when idle\n');
        end
        
        % print info on the running jobs
        hashes = sort(jobs.keys);
        
        % Figure out the width of table to use
        run_name_length = 0;
        jobs_running = 0;
        for k = hashes
            job = jobs(k{1});
            run_name_length = max(run_name_length, numel(job.run_name));
            if job.running
                jobs_running = jobs_running + 1;
            end
        end  

        fprintf('[%i running / %i queued] [%.1f TPS] [%i completed] [Worker timeout=%s]\n', ...
            jobs_running, jobs.Count, transaction_count/toc(last_print), stats.jobs_completed, ...
            jobmgr.lib.seconds_to_readable_time(timeout_seconds));
        last_print = tic();
        transaction_count = 0;

        run_name_format = sprintf('%%-%is ', run_name_length);

        % Print them out
        fprintf(['%-7s %13s ' run_name_format 'Status\n'], 'Hash', 'Last contact', 'Name');
        N_printed = 0;
        N_to_print = 24;
        for k = hashes
            job = jobs(k{1});
            if ~job.running && jobs_running > 0 && jobs.Count > N_to_print
                continue;
            end

            fprintf('%s ', job.hash(1:12));
            age = (now() - job.last_touch) * 24 * 60 * 60;
            fprintf('%6.0fs', age);
            if age > timeout_seconds && job.running
                fprintf('? ');
            else
                fprintf('  ');
            end
            fprintf(run_name_format, job.run_name);

            if ~job.running
                fprintf('(in queue)');
            elseif isfield(job, 'status')
                fprintf('%s', job.status);
            end

            fprintf('\n');

            N_printed = N_printed + 1;
            if N_printed >= N_to_print
                break;
            end
        end
        if numel(hashes) > N_printed
            fprintf(' ++ plus %i more\n', numel(hashes) - N_printed);
        end
    end


end
