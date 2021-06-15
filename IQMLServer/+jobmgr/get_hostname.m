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

function hostname = get_hostname()
%GET_HOSTNAME Return the current computer host name

% Try the hostname utility
[retval, hostname] = system('hostname');

% If that didn't work, try something else 
if retval ~= 0 || isempty(hostname)
    % Try the Windows environment variable
    if ispc
        hostname = getenv('COMPUTERNAME');
    end

    % The fallback option is to use Java.
    if isempty(hostname)
        try
            % This might fail depending upon DNS settings, etc.
            % It didn't work out of the box for me on Mac OS 10.12.
            hostname = char(java.net.InetAddress.getLocalHost.getHostName);
        catch
            hostname = 'localhost';
        end
    end
end

% Ensure that the hostname contains only legal characters for filenames.
% (e.g. if it comes from the hostname utility then there might a linefeed)
hostname = regexprep(hostname, '[^A-Za-z0-9\.]', '');
