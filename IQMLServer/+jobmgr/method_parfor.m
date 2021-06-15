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

function r = method_parfor(run_opts, configs, config_hashes, run_names)
% METHOD_PARFOR Run using the parallel computing toolbox's parfor loop

% The memoisation store is done inside the parfor loop, which assumes
% that all workers share a common filesystem.

    M = numel(configs);
    r = cell(M, 1);

    % Run the parfor loop
    if M > 1
        parfor a = 1:M
            display_config = run_opts.display_config;
            display_config.run_name = run_names{a};
            r{a} = jobmgr.run_without_cache(configs{a}, display_config);
            jobmgr.store(configs{a}.solver, config_hashes{a}, r{a});
            if run_opts.no_return_value
                r{a} = true; % save memory
            end
        end
    else
        % Only one config: run it here in the main thread, because this allows the solver the run
        % its own parfor loops
        display_config = run_opts.display_config;
        display_config.run_name = run_names{1};
        r{1} = jobmgr.run_without_cache(configs{1}, display_config);
        jobmgr.store(configs{1}.solver, config_hashes{1}, r{1});
    end

end
