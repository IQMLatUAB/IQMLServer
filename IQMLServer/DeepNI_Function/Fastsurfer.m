function result = Fastsurfer()
addpath DeepBT_Function
addpath DeepNI_Function
addpath DICOM2Nifti
input_path = fullfile(pwd, 'wait_for_process');
output_path = fullfile(pwd, 'Image_Analysis_Result');
output_file_path = fullfile(output_path, 'Output/mri/aparc.DKTatlas+aseg.deep.mgz');
input_file_path = fullfile(input_path, 'temptest.nii');
converted_file_path = fullfile(output_path, 'Output/Fastsurfer/converted_seg_label.nii');

cmd1 = ['docker run --gpus all -v ', input_path, ':/data -v ', output_path, ...
    ':/output --rm fastsurfercnn:gpu --i_dir /data --in_name ', ...
    '/data/temptest.nii --o_dir /Output --out_name /output/Output/mri/aparc.DKTatlas+aseg.deep.mgz --simple_run'];

cmd2 = ['mri_label2vol --seg ', output_file_path, ' --temp ', input_file_path, ' --o ', converted_file_path, ...
    ' --regheader ', output_file_path];

cmd3 = ['mri_convert --in_type nii --out_type nii --out_orientation RAS ', converted_file_path, ' ', converted_file_path];

cmd4 = ['rm -rf ', output_file_path];

% Fastsurfer
[status msg] = system(cmd1, '-echo'); %Fast server
[status msg] = system(cmd2, '-echo');
[status msg] = system(cmd3, '-echo');
Results = converted_file_path;

try
    fileID = fopen(Results, 'r');
    result = fread(fileID,'*bit8');
    fclose(fileID);
catch ME
    disp('Error Message:')
    disp(ME.message)
end
% delete result file         
system(cmd4,'-echo');
disp('Finish FastSurfer processing!');
