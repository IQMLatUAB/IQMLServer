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

function r = method_job_server(run_opts, configs, config_hashes, run_names)
% METHOD_JOB_SERVER Run using the job server

    M = numel(configs);
    r = cell(M, 1);

    fprintf('Job Manager: Using the job server to run %i items\n', M);

    % Queue each job
    for a = 1:M
        % make the network request to send to the server
        request = struct();
        request.msg = 'enqueue_job';
        request.job.hash = config_hashes{a};
        request.job.config = configs{a};
        request.job.run_name = run_names{a};

        try
            response = jobmgr.netsrv.make_request(request);
        catch E
            if strcmp(E.identifier, 'MATLAB:client_communicate:need_init')
                fprintf('Job Manager: Assuming job server is running on localhost.\nIf this is incorrect, pass the server hostname to jobmgr.netsrv.start_client\n');
                % add remote server
                %jobmgr.netsrv.start_client('138.26.170.137', jobmgr.server.tcp_port);
                %jobmgr.netsrv.start_client('35.192.100.249', jobmgr.server.tcp_port);
                %jobmgr.netsrv.start_client('localhost', jobmgr.server.tcp_port);
                jobmgr.netsrv.start_client(jobmgr.server.tcp_ip, jobmgr.server.tcp_port);
                response = jobmgr.netsrv.make_request(request);
            else
                rethrow(E);
            end
        end
        
        % unpack the computed result
        if strcmp(response.status, 'Error')
            if isfield(response, 'message')
                message = sprintf('\n\tMessage from server: %s', response.message);
            else
                message = '';
            end
            error('Failed to submit job to server.\n\tJob name: %s\n\tHash: %s%s', run_names{a}, config_hashes{a}, message);
        end
        
        if ~isempty(response.result)
            r{a} = response.result;
            jobmgr.store(configs{a}.solver, config_hashes{a}, r{a});
        end
    end
end
