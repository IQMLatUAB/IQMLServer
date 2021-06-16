function result = Zyx_2019()
addpath DeepBT_Function
addpath DeepNI_Function
addpath DICOM2Nifti

setenv('LD_PRELOAD', '/usr/lib/x86_64-linux-gnu/libstdc++.so.6');
setenv('PATH', [getenv('PATH') '/opt/ANTs/bin/']);
[IQML_path, ~, ~] = fileparts(pwd);
BTK_path = fullfile(IQML_path, 'BraTS-Toolkit');
input_t1_path = fullfile(pwd, 'Image_Analysis_Result/Input/Subject1/input_t1.nii.gz');
GenericAffine_path = fullfile(pwd, ...
    'Image_Analysis_Result/Output/BTK_preprocessor/Subject1/registrations/Subject1_native_t1_to_brats_0GenericAffine.mat');
output_file_path = fullfile(pwd, 'Image_Analysis_Result/Output/BTK_segmentor/zyx_2019.nii.gz');
inverted_filegz_path = fullfile(pwd, 'Image_Analysis_Result/Output/BTK_segmentor/zyx_2019_inverted.nii.gz');
inverted_file_path = fullfile(pwd, 'Image_Analysis_Result/Output/BTK_segmentor/zyx_2019_inverted.nii');

cmd1 = ['cd ', BTK_path, '; python 0_preprocessing_batch.py'];
cmd2 = ['cd ', BTK_path, '; python segmentation_zyx_2019.py'];
cmd3 = ['antsApplyTransforms -d 3 -r ', input_t1_path, ' -t [ ', GenericAffine_path, ', 1] -n NearestNeighbor -i ', ...
    output_file_path, ' -o ', inverted_filegz_path];

% zyx_2019 model
system(cmd1, '-echo');
system(cmd2, '-echo');
system(cmd3, '-echo');
img = niftiread(inverted_filegz_path);
info = niftiinfo(inverted_filegz_path);
img(img==4) = 3;
niftiwrite(img, inverted_file_path, info);
Results = inverted_file_path;

try
    fileID = fopen(Results, 'r');
    result = fread(fileID,'*bit8');
    fclose(fileID);
catch ME
    disp('Error Message:')
    disp(ME.message)
end
% delete result files         
system(['rm -rf ', inverted_file_path], '-echo');
system(['rm -rf ', fullfile(pwd, 'Image_Analysis_Result/Output/BTK_preprocessor/Subject1/hdbet_brats-space')], '-echo');           
