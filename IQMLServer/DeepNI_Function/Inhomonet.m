function result = Inhomonet()
addpath DeepBT_Function
addpath DeepNI_Function
addpath DICOM2Nifti
input_path = fullfile(pwd, 'wait_for_process');
input_file_path = fullfile(input_path, 'temptest.nii');
input_png_path = fullfile(pwd, 'png_path');
output_path = fullfile(pwd, 'Image_Analysis_Result/Output/InhomoNet/output');
output_orig_path = fullfile(pwd, 'Image_Analysis_Result/Output/InhomoNet/orig');
output_nii_path = fullfile(pwd, 'Image_Analysis_Result/Output/InhomoNet/InhomoNet_orig.nii');
output_corrected_path = fullfile(pwd, 'Image_Analysis_Result/Output/InhomoNet/InhomoNet_corrected.nii');

cmd1 = ['docker run --gpus all -v ', input_png_path, ':/InhomoNet/data -v ', output_path, ...
    ':/InhomoNet/Datasets/Demo_datasets/Brain_Out -v ', output_orig_path, ...
    ':/InhomoNet/Datasets/Demo_datasets/Brain_Orig --rm inhomonet:1.0 python main_V1.py'];
cmd2 = ['rm -rf ', input_png_path];
cmd3 = ['rm -rf ', output_path];
cmd4 = ['rm -rf ', output_orig_path];
cmd5 = ['rm -rf ', output_corrected_path];

% Inhomonet
nii2png(input_file_path); %the result png in the IQMLServer/wait_for_process/png
system(cmd1, '-echo');
[status, container_name] = system('docker container ls -a -q');
msg2 = strcat('docker rm -f', 32, container_name);
system(msg2,'-echo');

% convert png to nii

addpath(output_orig_path);

f = fullfile(output_orig_path,'*.png');
files = dir(f);
for i = 1:length(files)
    img(:,:,i) = imread(sprintf('%d',i)+".png");
end
nii = nii_tool('init', img);
nii_tool('save', nii, output_nii_path);

addpath(output_path);

f = fullfile(output_path,'*.png');
files = dir(f);
for i = 1:length(files)
    img(:,:,i) = imread(sprintf('%d',i)+".png");
end
nii = nii_tool('init', img);
nii_tool('save', nii, output_corrected_path);

% delete png folders and create back
system(cmd2, '-echo');
system(cmd3, '-echo');
system(cmd4, '-echo');
mkdir(output_path);
mkdir(output_orig_path);

Results = output_corrected_path;

try
    fileID = fopen(Results, 'r');
    result{1} = fread(fileID,'*bit8');
    fclose(fileID);
catch ME
    disp('Error Message:')
    disp(ME.message)
end
% delete result file         
system(cmd5, '-echo');
