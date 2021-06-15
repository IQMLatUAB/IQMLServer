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

function [path,dir] = make_cache_filename(fn, hash)
% MAKE_FILENAME Calculate the filename for storing a memoised result.
% This is an internal function, only intended to be used by code in the jobmgr package.
% PATH = MAKE_FILENAME(FN, HASH) returns the filename for storing a key HASH
% for the memoised function handle FN.
% [PATH,DIR] = MAKE_FILENAME(FN, HASH) also returns the directory.


% Get the memoise config structure, cached.
% (Yes, it does help when processing big datasets. I profiled
% this!)
persistent configs;
if isempty(configs)
    configs = containers.Map;
end

fn_name = char(fn);
if configs.isKey(char(fn_name))
    c = configs(fn_name);
else
    c = memoise_config(fn);
    configs(fn_name) = c;
end

% To keep the filesystem running smoothly, avoid placing too many
% files in the same folder. For this reason, generate
% subdirectories based on the first two characters of the hash.
subdir = hash(1:2);

% Generate the path
dir = fullfile(c.cache_dir, subdir);
path = fullfile(dir, [hash '.mat']);

end
