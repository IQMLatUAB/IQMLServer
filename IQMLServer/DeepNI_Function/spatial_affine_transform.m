function spatial_affine_transform(org_img, contour)
% 
% info1=niftiinfo('/root/DeepBrainSeg/Seg_Result/coreg/registered/t1.nii.gz');
% img1 =niftiread('/root/DeepBrainSeg/Seg_Result/coreg/registered/t1.nii.gz');
% 
% info2=niftiinfo('/root/DeepBrainSeg/Seg_Result/coreg/isotropic/t1.nii.gz');
% img2 =niftiread('/root/DeepBrainSeg/Seg_Result/coreg/isotropic/t1.nii.gz');
addpath(genpath('/usr/local/freesurfer/matlab')); % Add MRIread function path
% convert 184x512x512 nii to mgz
[status msg] = system('mri_convert --in_type nii --out_type mgz /root/DeepNI/health_input_T1.nii /root/DeepNI/health_input_T1.mgz','-echo');

health_nii_img = '/root/DeepNI/health_input_T1.nii'; % 184x512x512 nii path
orig_mgz = MRIread('/root/DeepNI/orig.mgz'); % conformed 256x256x256 mgz from 512x184x512 mgz
health_mgz = MRIread('/root/DeepNI/health_input_T1.mgz'); % 512x184x512 converted health mgz
health_mgz_vol = health_mgz.vol;
orig_mgz_vol = orig_mgz.vol;

health_nii_info=niftiinfo(health_nii_img);
health_nii_imag =niftiread(health_nii_img);
% convert seg_label and conformed 256x256x256 mgz into native space with
% anatomical information
system('mri_label2vol --seg /root/Image_Analysis_Result/Output/mri/aparc.DKTatlas+aseg.deep.mgz --temp /root/DeepNI/health_input_T1.mgz --o /root/DeepNI/converted_seg_label.mgz --regheader /root/Image_Analysis_Result/Output/mri/aparc.DKTatlas+aseg.deep.mgz','-echo');
system('mri_vol2vol --mov /root/DeepNI/orig.mgz --targ /root/DeepNI/health_input_T1.mgz --regheader --o /root/DeepNI/converted_orig.mgz --no-save-reg','-echo');
converted_mgz = MRIread('/root/DeepNI/converted_orig.mgz'); % converted 512x184x512 mgz
converted_mgz_vol = converted_mgz.vol;
converted_mgz_label = MRIread('/root/DeepNI/converted_seg_label.mgz'); % converted  512x184x512 seg label
converted_mgz_label_vol = health_mgz_label.vol;
%%
% Mtf  = info1.Transform.T';
% Mdti = info2.Transform.T';
% M =  inv(Mtf) * Mdti;
% M = M';
% tform = affine3d(M);
% [img_T1post,~] = imwarp(img2,tform,'Interp','cubic','FillValues',0,'OutputView',imref3d(size(img1)));
% Mtf  = pre2_info.Transform.T';
% Mdti = nii_info.Transform.T';
% M =  inv(Mtf) * Mdti;
% M = M';
% tform = affine3d(M);
% [affresult,~] = imwarp(nii_imag,tform,'Interp','nearest','FillValues',0,'OutputView',imref3d(size(pre2_imag)));
% niftiwrite(affresult, '/root/DeepNI/affresult.nii');

% Mtf  = health_mgz.vox2ras;
% Mdti = orig_mgz.vox2ras;
% M =  inv(Mtf) * Mdti;
% M = M';
% tform = affine3d(M);
% [affresult,~] = imwarp(orig_mgz_vol,tform,'Interp','nearest','FillValues',0,'OutputView',imref3d(size(health_mgz_vol)));
