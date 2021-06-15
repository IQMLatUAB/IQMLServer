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

function run_client

try
    netsrv.start_client('localhost', 9967);

    request = struct();
    request.msg = 'echo';
    request.data = '=====>> netsrv test passed! <<=====';
    disp(netsrv.make_request(request));
    disp(netsrv.make_request(request));
    disp(netsrv.make_request(request));
    
    obj = netsrv.unit_test.HardToSerialise();
    request.data = obj;
    response = netsrv.make_request(request);
    if response.number == obj.number
        disp('=====>> class serialisation test passed! <<=====');
    else
        disp('=====>> class serialisation test FAILED! <<=====');
    end

    request = struct();
    request.msg = 'quit';
    netsrv.make_request(request);

    pause(1.5); % wait for server to quit

    exit();

catch E
    disp(E.getReport());
    exit();
end



end
