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

function memoised = is_memoised(fn, key)
% IS_MEMOISED Check whether a result has been memoised.
%
% M = IS_MEMOISED(FN, KEY) tests whether a memoised value under KEY exists for memoised function
% FN. The key can be a configuration structure or a hash calculated with the struct_hash function.
% M = true if the relevant item exists, or false otherwise
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
filename = make_cache_filename(fn, hash);

% Does the file exist?
if 2 == exist(filename)
    memoised = true;
else
    memoised = false;
end

end
