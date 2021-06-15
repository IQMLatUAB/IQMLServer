function [Results, img_file] = process_MR_data_after_conversion(ori_img_file, argument, softnum)
% clear all; close all;


display('----------------------------------------------');
display('----------------------------------------------');
display('----------------------------------------------');
display('----------------------------------------------');

%ori_img_file = /root/DeepNI/temptest.nii

% do SW Command
if softnum ==1
    [status msg] = system(argument,'-echo'); %Fast server
    %[status msg] = system('mri_convert --in_type nii --out_type mgz /root/DeepNI/temptest.nii /root/DeepNI/temptest.mgz','-echo');
    [status msg] = system('mri_label2vol --seg /root/Image_Analysis_Result/Output/mri/aparc.DKTatlas+aseg.deep.mgz --temp /root/DeepNI/temptest.nii --o /root/DeepNI/converted_seg_label.nii --regheader /root/Image_Analysis_Result/Output/mri/aparc.DKTatlas+aseg.deep.mgz','-echo');
    [status msg] = system('mri_convert --in_type nii --out_type nii --out_orientation RAS /root/DeepNI/converted_seg_label.nii /root/DeepNI/converted_seg_label.nii','-echo');
    Results = '/root/DeepNI/converted_seg_label.nii';
    img_file = '/root/DeepNI/orimg.nii';
%     spatial_affine_transform('/root/DeepNI/temptest.nii', Results);
elseif softnum ==2
    [status msg] = system(argument, '-echo');  %DARTS
    %[status msg] = system('mri_convert --in_type nii --out_type mgz /root/DeepNI/temptest.nii /root/DeepNI/temptest.mgz','-echo');
    [status msg] = system('mri_label2vol --seg /root/Image_Analysis_Result/Output/mri/aparc.DKTatlas+aseg.deep.mgz --temp /root/DeepNI/temptest.nii --o /root/DeepNI/converted_seg_label.nii --regheader /root/Image_Analysis_Result/Output/mri/aparc.DKTatlas+aseg.deep.mgz','-echo');
    [status msg] = system('mri_convert --in_type nii --out_type nii --out_orientation RAS /root/DeepNI/converted_seg_label.nii /root/DeepNI/converted_seg_label.nii','-echo');
    Results = '/root/DeepNI/converted_seg_label.nii';
    img_file = '/root/DeepNI/orimg.nii';
%     spatial_affine_transform('/root/DeepNI/temptest.nii', Results);
    
elseif softnum ==3
    addpath('/root/DeepNI/DICOM2Nifti');
    nii2png('/root/DeepNI/temptest.nii'); %the result png in the /root/DeepNI/png
    
    % InhomoNet
    system('docker run --gpus all --user 0000 -v /root/DeepNI/png:/InhomoNet/data -v /root/InhomoNet/Datasets/Demo_datasets/Brain_Out:/InhomoNet/output -v /root/InhomoNet/Datasets/Demo_datasets/Brain_Orig:/InhomoNet/orig inhomonet:1.0 python main_V1.py', '-echo');
    [status, container_name] = system('docker container ls -a -q');
    msg2 = strcat('docker rm -f', 32, container_name);
    system(msg2,'-echo');
    
    % convert png to nii
    
    addpath('/root/InhomoNet/Datasets/Demo_datasets/Brain_Orig')
    
    f = fullfile('/root/InhomoNet/Datasets/Demo_datasets/Brain_Orig','*.png');
    files = dir(f);
    for i = 1:length(files)
        img(:,:,i) = imread(sprintf('%d',i)+".png");
    end
    nii = nii_tool('init', img);
    nii_tool('save', nii, '/root/Image_Analysis_Result/Output/InhomoNet/InhomoNet_orig.nii');
    
    addpath('/root/InhomoNet/Datasets/Demo_datasets/Brain_Out')
    f = fullfile('/root/InhomoNet/Datasets/Demo_datasets/Brain_Out','*.png');
    files = dir(f);
    for i = 1:length(files)
        img(:,:,i) = imread(sprintf('%d',i)+".png");
    end
    nii = nii_tool('init', img);
    nii_tool('save', nii, '/root/Image_Analysis_Result/Output/InhomoNet/InhomoNet_corrected.nii');
    % delete png folders and create back
    system('rm -rf /root/DeepNI/png','-echo');
    system('rm -rf /root/InhomoNet/Datasets/Demo_datasets/Brain_Out','-echo');
    system('rm -rf /root/InhomoNet/Datasets/Demo_datasets/Brain_Orig','-echo');
    mkdir /root/InhomoNet/Datasets/Demo_datasets/Brain_Out;
    mkdir /root/InhomoNet/Datasets/Demo_datasets/Brain_Orig;
   
    Results = '/root/Image_Analysis_Result/Output/InhomoNet/InhomoNet_corrected.nii';
    img_file = '';
    
end
%%softnum == 4
% system('cp /root/DeepNI/temptest.nii /root/DeepBrainNet/input_nii/temptest.nii')
% system('docker run --gpus all --user 0000 -v /root/DeepBrainNet/input_nii:/DeepBrainNet/input_nii -v /root/Image_Analysis_Result/Output/DeepBrainNet:/DeepBrainNet/output deepbrainnet:1.0 ./test.sh -d /DeepBrainNet/input_nii/ -o /DeepBrainNet/output/ -m /DeepBrainNet/Models/DeepBrainNet_DenseNet169.h5', '-echo');
% [status, container_name] = system('docker container ls -a -q');
% msg2 = strcat('docker rm -f', 32, container_name);
% system(msg2,'-echo');

% Results = '/root/Image_Analysis_Result/Output/mri/aparc.DKTatlas+aseg.deep.mgz';
% 
% img_file = '/root/DeepNI/orig.mgz';


return;
%% load results and show them
% [vol2, M2, mr_parms2, volsz] = load_mgz(img_file);
% [vol4, M4, mr_parms2, volsz] = load_mgz(FAST_results);
% now_label = 50;
% mask2 = vol4==now_label;
% img1 = squeeze(vol2(:,110,:));
% mask2t = squeeze(mask2(:,110,:));
% imgtemp2 = fuse_img(img1, mask2t);
% figure
% imagesc(imgtemp2);  axis off; title('FASTsurfer');
