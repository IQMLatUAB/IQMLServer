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

function start_client(server, port, timeout)
% START_CLIENT open a connection to a ZMQ server.
%
% START_CLIENT(server) connects to the specified server on port 8148.
%
% START_CLIENT(server, port) connects to the specified server on the requested port.
%
% START_CLIENT(..., timeout) additionally specifies the timeout in milliseconds
% after which an error will be raised in the case of communication failure.
%

    if nargin < 3
        timeout = 10000; % milliseconds to wait before returning to MATLAB
                         % in the case of communication failure.
    end
    if nargin < 2
        port = 8148;
    end
    if nargin < 1
        error(sprintf(['Usage:\n'...
                       'start_client(server)\n'...
                       'start_client(server, port)']));
    end

    % Prepare the config structure
    config = struct();
    config.endpoint = sprintf('tcp://%s:%i', server, port);
    config.timeout = uint32(timeout); 

    % Constants
    CLIENT_INIT = uint32(0);
    CLIENT_REQUEST = uint32(1);

    % Call the mex function that wraps ZMQ
    try
        [success, ~] = client_communicate(CLIENT_INIT, config);
    catch E
        if strcmp(E.identifier, 'MATLAB:UndefinedFunction')
            error('You need to compile the MEX files in +netsrv/private');
        else
            rethrow(E);
        end
    end
    if ~success
        error('netsrv:init_failed', 'Netsrv: Failed to initialise client.');
    end

end
