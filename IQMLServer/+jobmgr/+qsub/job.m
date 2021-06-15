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

function job(job_name)
% JOB The code that runs to execute the actual job

    fprintf('Running on host: %s\n', char(java.net.InetAddress.getLocalHost.getHostName));

    % Load basic settings
    batch_config = jobmgr.qsub.batch_system_config();

    % Generate file paths
    job_folder = fullfile(batch_config.job_root, job_name);

    % Load the configuration
    try
        configs_struct = load(fullfile(job_folder, 'input.mat'));
    catch E
        % Allow for slow network filesystems to catch up.
        % Sometimes the file takes a second to appear on the NFS
        % filesystem
        pause(3);
        configs_struct = load(fullfile(job_folder, 'input.mat'));
    end

    configs = configs_struct.configs;
    hashes =  configs_struct.config_hashes;
    run_names =  configs_struct.run_names;

    % Run the simulation, saving the results into the memoise cache
    run_opts.silent = false;
    run_opts.execution_method = 'for';
    for i = 1:numel(configs)
        config = configs{i};
        fprintf('Running job %i of %i: %s\n', i, numel(configs), run_names{i});
        run_opts.run_names = {run_names{i}};
        jobmgr.run(config, run_opts);

        % Remove the flag directories that indicate a job in progress (only
        % for the 2nd and higher job in this package; the first folder
        % contains the input file and is deleted by the shell script).
        if i > 1
            config_hash = hashes{i};
            job_dir = [batch_config.job_root config_hash '/'];

            [status, message] = rmdir(job_dir);
            if ~status
                fprintf('Failed to remove directory\n%s\n%s\n', job_dir, message);
            end
        end

    end
end
