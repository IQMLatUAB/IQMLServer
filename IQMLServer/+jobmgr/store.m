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

function store(fn, key, value)
% STORE Save a computed value in the cache.
%
% STORE(FN, K, V) saves the value V under key K for memoised function FN. The key can be a
% configuration structure or a hash calculated with the struct_hash function.
% Calculating structure hashes is computationally expensive for big datasets, so
% it is recommended to calculate the hashes once and use these throughout.

% Generate the memoised hash
if ischar(key)
    hash = key; % the hash is provided directly
else
    hash = jobmgr.struct_hash(key);
    warning('memoise:no_key', sprintf(...
        ['A structure (not a hash) was passed as the memoise key.\n'...
         'Calculating hashes is computationally expensive for big datasets, so\n'...
         'it is recommended that you precompute the hashes with the struct_hash\n'...
         'function and pass the hash instead.']));
end

% Generate the filename
[output_file,dir] = make_cache_filename(fn, hash);

% Make the directory if it does not exist
if 7 ~= exist(dir, 'dir')
    [~, ~, ~] = mkdir(dir);
end

% Save the result

% Work around Matlab bug: MAT file export on NFS filesystems is
% horrifyingly slow.
use_NFS_workaround = true;

if use_NFS_workaround
    tfile = [tempname() '.mat']; % on /tmp which is assumed to be a
                                 % fast local filesystem
    save(tfile, 'value');
    [success,msg] = movefile(tfile, output_file);
    if ~success
        fprintf('memoise: failed to move:\n%s\nto:\n%s\n', tfile, output_file);
        fprintf('%s\n', msg);
    end
else
    save(output_file, 'value');
end

end
