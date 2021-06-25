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

function start_server(request_callback, port)
% START_SERVER Start the network server.
%
% START_SERVER(request_callback) starts a server on TCP port 8148.
% Requests are handled by the supplied callback function.
%
% START_SERVER(request_callback, port) starts a server on the specified port.

    if nargin < 2
        port = 8148;
    end
    if nargin < 1
        error(sprintf(['Usage:\n'...
                       'start_server(request_callback)\n'...
                       'start_server(request_callback, port)']));
    end

    fprintf('Starting server on port %i ...\n', port);

    % Prepare the config structure
    config = struct();
    config.port = uint16(port);
    config.timeout = uint32(1000); % milliseconds to wait before
                                   % returning to MATLAB

    % Constants
    SERVER_INIT = uint32(0);
    SERVER_RECV = uint32(1);
    SERVER_SEND = uint32(2);

    % Call the mex function that wraps ZMQ
    try
        [success, ~] = server_communicate(SERVER_INIT, config);
    catch E
        if strcmp(E.identifier, 'MATLAB:UndefinedFunction')
            error('You need to compile the MEX files in +netsrv/private');
        else
            rethrow(E);
        end
    end
    if ~success
        error('netsrv:init_failed', 'Netsrv: Failed to initialise server.');
    end

    while true
        % This call periodically returns to MATLAB so that the
        % program can be interrupted with ctrl+c
        [have_msg, msg_serialised] = server_communicate(SERVER_RECV, config);

        % Did we receive a message?
        if have_msg
            % Deserialise
            msg = getArrayFromByteStream(msg_serialised);

            % Run the callback
            response = request_callback(msg);

            % Serialise
            response_serialised = getByteStreamFromArray(response);

            % Send the response
            [~, ~] = server_communicate(SERVER_SEND, response_serialised);
        end
    end
end
