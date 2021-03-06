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

% Compile for Windows

% Change dir
this_dir = fileparts(mfilename('fullpath'));
cd(this_dir);

% Check for the required files
requirements = {'zmq.h', 'libzmq.lib', 'libzmq.exp', 'libzmq.dll'};
libpath = 'zeromq_windows_x64';
for r = requirements'
    if 0 == exist(fullfile(libpath, r{1}), 'file')
        error('Please download ZeroMQ 4.2.0 or later and place the following files in the %s folder: %s', libpath, strjoin(requirements, ', '));
    end
end

% Compile
mexargs = {'-largeArrayDims', ['-I' libpath], ['-L' libpath], '-lzmq'};

% Copy the DLL to the root directory so it can be found by the mex file
copyfile(fullfile(libpath, 'libzmq.dll'), this_dir);

mex( mexargs{:}, 'client_communicate.cpp' );
mex( mexargs{:}, 'server_communicate.cpp' );

disp('Done.');
