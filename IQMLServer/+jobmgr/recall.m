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

function [value, memoised] = recall(fn, key)
% RECALL Recall a value previously saved in the cache.
%
% [V, M] = RECALL(FN, KEY) recall the value previously saved for the function FN
% under the key KEY. The key can be a configuration structure or a hash calculated
% with the struct_hash function.
% V = the value, or [] if no such item exists.
% M = true if the relevant item exists
% Calculating structure hashes is computationally expensive for big datasets, so
% it is recommended to calculate the hashes once and use these throughout.

% Generate the memoised hash
if ischar(key)
    hash = key; % the hash is provided directly
else
    hash = jobmgr.struct_hash(key); % generate the hash ourselves
    warning('memoise:no_key', sprintf(...
        ['A structure (not a hash) was passed as the memoise key.\n'...
         'Calculating hashes is computationally expensive for big datasets, so\n'...
         'it is recommended that you precompute the hashes with the struct_hash\n'...
         'function and pass the hash instead.']));
end

% Generate the filename
filename = make_cache_filename(fn, hash);

% Try to load the previously saved item
try
    memory = load(filename);
    % Success
    memoised = true;
    value = memory.value;
catch E
    if strcmp(E.identifier, 'MATLAB:load:couldNotReadFile')
        % File does not exist. Item has not been saved.
        memoised = false;
        value = [];
    else
        disp('Error reading saved file under hash:');
        disp(hash);
        throw(E);
    end
end
