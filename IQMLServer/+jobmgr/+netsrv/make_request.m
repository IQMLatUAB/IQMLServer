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

function response = make_request(request)
% MAKE_REQUEST(request) sends the supplied request data to the
% previously opened client socket.

    if nargin < 1
        error(sprintf(['Usage:\n'...
                       'make_request(request)']));
    end

    % Constants
    CLIENT_INIT = uint32(0);
    CLIENT_REQUEST = uint32(1);

    % Serialise the message
    request_s = getByteStreamFromArray(request);

    % Send the message
    [success, response_s] = client_communicate(CLIENT_REQUEST, request_s);
    if ~success
        error('netsrv:failed_to_communicate', 'Netsrv: Failed to send message to server.');
    end

    % Deserialise
    response = getArrayFromByteStream(response_s);

end
