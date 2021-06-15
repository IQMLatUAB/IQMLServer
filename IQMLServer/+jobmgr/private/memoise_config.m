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

function c = memoise_config(fn_handle)
% MEMOISE_CONFIG Generate a struct containing settings for memoisation
% C = MEMOISE_CONFIG(FN) Returns the config valid for memoised function handle FN.

    c = struct();

    % Sanity check that the handle refers to a function implemented in a M-file
    fn_struct = functions(fn_handle);
    assert(strcmp(fn_struct.type, 'simple') || strcmp(fn_struct.type, 'classsimple'),...
           'Can only memoise functions that are stored in M-files');

    % Find the filename corresponding to the handle fn_handle, converting package names to their
    % appropriate subdirectories.
    c.filename = '';
    fn_fullname = char(fn_handle);
    packages = regexp(fn_fullname, '([^.]+)\.', 'tokens');
    for p = packages
        c.filename = [c.filename '+' p{1}{1} filesep()];
    end
    fn_name = regexp(fn_fullname, '[^.]+$', 'match');
    c.filename = [c.filename fn_name{1} '.m'];

    % Calculate the memoised name, which has dots replaced with dashes
    c.memoised_name = strrep(c.filename, '.', '-');

    % Determine the directory to place the cache in

    % Detect OS
    if ispc()
        % Windows. Use tempdir
        base_dir = fullfile(tempdir(), 'matlab-job-manager', 'memoise');
    else
        % Linux or Mac. Use ~/scratch if it exists, otherwise use ~/temp
        if isdir('~/scratch/')
            base_dir = fullfile('~/scratch/cache/matlab-job-manager/memoise/');
        else
            base_dir = fullfile('~/temp/matlab-job-manager/memoise/');
        end
    end

    % Set the directories in the config structure
    c.cache_root = fullfile(base_dir, c.memoised_name);
    c.cache_dir = fullfile(c.cache_root, 'cache');

end
