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

function re_msg = control(msg, argument)

    valid_messages = {'accept_workers', 'quit_workers', 'quit_workers_when_idle', 'set_timeout','check_job','check_server_connection'};

    if nargin < 1 || ~any(strcmp(msg, valid_messages))
        error(sprintf(['Usage: jobmgr.server.control(message)\n'...
                       'where message is one of:\n'...
                       '  ''quit_workers'' Quit workers when they finish their current task\n'...
                       '  ''quit_workers_when_idle'' Quit workers when all queued tasks are complete\n'...
                       '  ''accept_workers'' Undo a previous call to quit_workers, allowing new workers to connect\n'...
                       '  ''set_timeout N'' Workers whose last communication was N seconds ago are considered to have crashed\n'...
                      ]));
    end

    request = struct();
    request.msg = msg;
    if nargin >= 2
        request.argument = argument;
    end

    try
        response = jobmgr.netsrv.make_request(request);
        fprintf('Response from server: %s\n', response.status);
        re_msg = response.status;
    catch E
        if strcmp(E.identifier, 'MATLAB:client_communicate:need_init')
            fprintf('Job Manager: Assuming job server is running on localhost.\n');

            jobmgr.netsrv.start_client('localhost', jobmgr.server.tcp_port);
            response = jobmgr.netsrv.make_request(request);
            fprintf('Response from server: %s\n', response.status);
        else
            rethrow(E);
        end
    end

end
