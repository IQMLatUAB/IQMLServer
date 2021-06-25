function result = Darts()
addpath DeepBT_Function
addpath DeepNI_Function
addpath DICOM2Nifti
input_path = fullfile(pwd, 'wait_for_process');
output_path = fullfile(pwd, 'Image_Analysis_Result/Output/mri');
output_file_path = fullfile(output_path, 'aparc.DKTatlas+aseg.deep.mgz');
input_file_path = fullfile(input_path, 'temptest.nii');
converted_file_path = fullfile(pwd, 'Image_Analysis_Result/Output/DARTS/converted_seg_label.nii');

cmd1 = ['docker run --gpus all -v ', input_path, ':/data -v ', output_path, ...
    ':/output --rm darts:1.0 --input_image_path /data/temptest.nii --segmentation_dir_path', ...
    '/output --file_name input_T1 --model_wts_path /DARTS/saved_model_wts/dense_unet_back2front_non_finetuned.pth'];

cmd2 = ['mri_label2vol --seg ', output_file_path, ' --temp ', input_file_path, ' --o ', converted_file_path, ...
    ' --regheader ', output_file_path];

cmd3 = ['mri_convert --in_type nii --out_type nii --out_orientation RAS ', converted_file_path, ' ', converted_file_path];

cmd4 = ['rm -rf ', output_file_path];


% DARTS
[status msg] = system(cmd1, '-echo');  %DARTS
[status msg] = system(cmd2, '-echo'); % convert label back to original space
[status msg] = system(cmd3, '-echo'); % transform to RAS coordination
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
