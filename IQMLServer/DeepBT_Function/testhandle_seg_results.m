function testhandle_seg_results()

info1=niftiinfo('/root/DeepBrainSeg/Seg_Result/coreg/registered/t1.nii.gz');
img1 =niftiread('/root/DeepBrainSeg/Seg_Result/coreg/registered/t1.nii.gz');

info2=niftiinfo('/root/DeepBrainSeg/Seg_Result/coreg/isotropic/t1.nii.gz');
img2 =niftiread('/root/DeepBrainSeg/Seg_Result/coreg/isotropic/t1.nii.gz');

%%
Mtf  = info1.Transform.T';
Mdti = info2.Transform.T';
M =  inv(Mtf) * Mdti;
M = M';
tform = affine3d(M);
[img_T1post,~] = imwarp(img2,tform,'Interp','cubic','FillValues',0,'OutputView',imref3d(size(img1)));

%%
info3=niftiinfo('/root/DeepBrainSeg/Seg_Result/segmentation/DeepBrainSeg_Prediction.nii.gz');
img3 =niftiread('/root/DeepBrainSeg/Seg_Result/segmentation/DeepBrainSeg_Prediction.nii.gz');

Mdti = info3.Transform.T';
M =  inv(Mtf) * Mdti;
M = M';
tform = affine3d(M);
% note that i am using nearest interpolation here
[seg_label,~] = imwarp(img3,tform,'Interp','nearest','FillValues',0,'OutputView',imref3d(size(img1)));
niftiwrite(seg_label, '/root/DeepBrainSeg/Seg_Result/segmentation/DeepBrainSeg_Prediction_inverted.nii');
info4 = niftiinfo('/root/DeepBrainSeg/Seg_Result/segmentation/DeepBrainSeg_Prediction_inverted.nii');

%%
% figure
% imagesc(seg_label(:,:,15))



