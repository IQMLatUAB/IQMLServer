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

function result = solver(custom_config, custom_display_config)
% SOLVER Example framework code for how to write a solver.

if nargin < 1
    custom_config = struct();
end
if nargin < 2
    custom_display_config = struct();
end

% File dependencies, for the purposes of checking whether the
% memoised cache is valid. List here all the functions that the solver
% uses. If any of these change, the cache of previously computed results
% will be discarded.
%
% +FILE_DEPENDENCY +jobmgr/+example/*.m
%
% Specify multiple lines beginning with "+FILE_DEPENDENCY" if necessary.
% The cache manager scans the file looking for entries like this.

% Set default config values that will be used unless otherwise specified
config = struct();
config.solver = @jobmgr.example.solver;

% our "solver" requires two parameters:
config.mode = 'image_processing';
config.input = cell(1,1);
config.softnum = 0;
config.date = datenum(datetime);

% Set default display settings
display_config = struct();
display_config.run_name = '';  % label for this computational task
display_config.animate = true; % whether to display progress

% Handle input. Allow custom values to override the default options above.
config = jobmgr.apply_custom_settings(config, custom_config, ...
    struct('config_name', 'config'));
display_config = jobmgr.apply_custom_settings(display_config, custom_display_config, ...
    struct('config_name', 'display_config'));

% Do the work
statusline('Starting ...');
disp('----------------------------------------------');
disp('----------------------------------------------');
disp('----------------------------------------------');
disp('----------------------------------------------');
switch config.mode
    case 'image_processing'
        addpath DeepBT_Function
        addpath DeepNI_Function
        addpath DICOM2Nifti
        [~, num_data] = size(config.input); % Read the number of img_data
        if num_data == 4 % DeepBT
            fileID = fopen(append(pwd,'/wait_for_process/input_T1.nii'),'w+');
            rawdata = config.input{1};
            fwrite(fileID, rawdata,'*int8');
            fclose(fileID);
            fileID = fopen(append(pwd,'/wait_for_process/input_T1post.nii'),'w+');
            rawdata = config.input{2};
            fwrite(fileID, rawdata,'*int8');
            fclose(fileID);
            fileID = fopen(append(pwd,'/wait_for_process/input_T2.nii'),'w+');
            rawdata = config.input{3};
            fwrite(fileID, rawdata,'*int8');
            fclose(fileID);
            fileID = fopen(append(pwd,'/wait_for_process/input_FLAIR.nii'),'w+');
            rawdata = config.input{4};
            fwrite(fileID, rawdata,'*int8');
            fclose(fileID);
        elseif num_data == 1 % DeepNI
            fileID = fopen(append(pwd,'/wait_for_process/temptest.nii'),'w+');
            rawdata = config.input{1};
            fwrite(fileID, rawdata,'*int8');
            fclose(fileID);
        end
        
        % DeepBT software...
        if config.softnum ==1
            % IQML model
            result{1} = IQML_Model();
            
        elseif config.softnum ==2
            %deep brain seg model
            result{1} = IQML_Model(); 
            %result{1} = DeepBrainSeg(); Temporarily repaired
            
        elseif config.softnum ==3
            % isen-20 model
            result{1} = Isen20();
            
        elseif config.softnum ==4
            % mic-dkfz model
            result{1} = Mic_dkfz();
            
        elseif config.softnum ==5
            % zyx_2019 model
            result{1} = Zyx_2019();
            
        % DeepNI software...
        elseif config.softnum == 1000
            % Fastsurfer
            result{1} = Fastsurfer();
            
        elseif config.softnum == 1001
            % DARTS
            result{1} = Darts();
            
        elseif config.softnum == 1002
            % Inhomonet
            result{1} = Inhomonet();
            
        end
        
        
        
    otherwise
        error('Unknown mode setting.');
end
statusline('Finished.');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Print status
    function statusline(varargin)
        % The job manager sets a global variable statusline_hook_fn if running
        % remotely. This function provides a mechanism to update the job server
        % on the status of the job. As shown below, call this function with a
        % single string argument (typically one line long), to be displayed on
        % the job server against this particular task. Display a percentage
        % complete or other metric as appropriate. Periodic updates (via this
        % mechanism) are used to detect that the remote worker is still
        % running. Jobs can be resent if no updates have been received within a
        % configured time window.
        global statusline_hook_fn;
        
        % Use printf style formatting to process the input
        status = sprintf(varargin{:});
        % Prepend the run name and print
        fprintf('%s  %s\n', display_config.run_name, status);
        
        % Pass to the job manager (if running)
        if ~isempty(statusline_hook_fn)
            feval(statusline_hook_fn, status);
        end
    end

end
