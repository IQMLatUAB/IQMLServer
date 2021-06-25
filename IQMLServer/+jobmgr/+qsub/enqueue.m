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

function enqueue(configs, config_hashes, run_names)
% ENQUEUE Run the specified job(s) using PBS
%
% ENQUEUE(configs, config_hashes) runs the cell array of configs
% which have the hashes in config_hashes.


    % Make sure that the directories exist
    batch_config = jobmgr.qsub.batch_system_config();
    stream_folder = fullfile(batch_config.job_root, 'streams');
    [~,~,~] = mkdir(stream_folder);
    % Make a directory for each config
    for i = 1:numel(configs)
        job_name = config_hashes{i};
        job_folder = fullfile(batch_config.job_root, job_name);
        [~,~,~] = mkdir(job_folder);
    end

    % Use the directory of the first config in the array to store the configs and
    % to run the job out of
    job_name = config_hashes{1};
    job_folder = fullfile(batch_config.job_root, job_name);
    filename = fullfile(job_folder, 'input.mat');
    save(filename, 'configs', 'config_hashes', 'run_names');

    % Enqueue the job
    stdout = fullfile(stream_folder, [job_name '.stdout']);
    stderr = fullfile(stream_folder, [job_name '.stderr']);
    vars = sprintf('job_name=%s', job_name);

    qsub_cmd = sprintf('qsub -d "%s" -e "%s" -o "%s" -N "%s" -v "%s" "./+jobmgr/+qsub/qsub-job.sh"', pwd(), stderr, stdout, job_name, vars);
    fprintf('%s\n', qsub_cmd);
    system(qsub_cmd);

    fprintf('Enqueued job %s\n', job_name);
end
