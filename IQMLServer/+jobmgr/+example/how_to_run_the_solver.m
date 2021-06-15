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

%% How to run the solver

%% Simple example using the default settings
config = struct();
config.solver = @jobmgr.example.solver;
r = jobmgr.run(config);
disp(r);

%% Run two configs in parallel with parfor
config = struct();
config.solver = @jobmgr.example.solver;

c1 = config;
c1.input = [10 11 12];

c2 = config;
c2.input = [100 200];
c2.mode = 'triple';

configs = {c1, c2};

run_opts = struct();
run_opts.run_names = {'c1', 'c2'};

r = jobmgr.run(configs, run_opts);
disp(r{1});
disp(r{2});

%% Run two configs on the job server
% You must start the job server and workers separately. See the README
% file.
config = struct();
config.solver = @jobmgr.example.solver;

c1 = config;
Test = fopen('input_T1.nii');
c1.input = Test;

c2 = config;
c2.input = 1:11;

c2.mode = 'triple';

c4 = config;
c4.input = 1:15;

configs = {c1, c2, c4};

run_opts = struct();
run_opts.execution_method = 'job_server';
run_opts.run_names = {'c1', 'c2', 'c4'};

r = jobmgr.run(configs, run_opts);
disp(r{1});
disp(r{2});
disp(r{3});

%% Submit a job with qsub
config = struct();
config.solver = @jobmgr.example.solver;
config.input = 1:30;

run_opts = struct();
run_opts.execution_method = 'qsub';

r = jobmgr.run({config}, run_opts);
disp(r);