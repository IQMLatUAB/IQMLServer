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

function desc = seconds_to_readable_time(t)
%SECONDS_TO_READABLE_TIME Converts time in seconds to human-readable time

if t < 0
    desc = '-';
    t = abs(t);
else
    desc = '';
end

if isinf(t)
    desc = 'infinite';
    return;
end

% Hours?
hours = floor(t / 3600);
if hours > 0
    if hours == 1
        plural = '';
    else
        plural = 's';
    end
    desc = sprintf('%s%i hour%s, ', desc, hours, plural);
    t = t - hours*3600;
end

% Minutes
minutes = floor(t / 60);
desc = sprintf('%s%i min, ', desc, minutes);
t = t - minutes*60;

% Seconds
desc = sprintf('%s%i sec', desc, round(t));

end
