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

function run_opts = default_run_opts()

run_opts = struct();
run_opts.config_hashes = {}; % if config hashes are already known, save time by not
                             % computing them again.
run_opts.no_return_value = false; % run the results but don't actually return the
                                  % results. This is useful when there is too much data to
                                  % fit it all in memory at once.
run_opts.skip_cache_check = false; % skip the jobmgr.check_cache call. (Use with caution.)
run_opts.silent = false;
run_opts.run_names = {};
run_opts.display_config.animate = false;
run_opts.execution_method = 'parfeval'; % the method used to run the jobs. Valid options:
                % 'parfor' - use parfor loop
                % 'parfeval' - use the parfeval() function
                % 'qsub' - submit each config to qsub (return
                % immediately; this option is asynchronous)
                % 'none' - don't actually run the configs that aren't
                % already cached
run_opts.allow_partial_result = true; % if qsub jobs are still in progress, return only those which have completed so far
run_opts.configs_per_job = 1; % the number of configs to process in a single job
