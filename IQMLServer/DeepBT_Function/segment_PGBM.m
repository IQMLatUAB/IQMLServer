function segment_PGBM()
tic
datestr(now)
addpath DICOM2Nifti
addpath files
spgr_path = fullfile(pwd, 'files/spgr.nii');
spgr_unstrip_path = fullfile(pwd, 'files/spgr_unstrip.nii');
t1_path = fullfile(pwd, 'wait_for_process/input_T1.nii');
t2_path = fullfile(pwd, 'wait_for_process/input_T2.nii');
t1c_path = fullfile(pwd, 'wait_for_process/input_T1post.nii');
fla_path = fullfile(pwd, 'wait_for_process/input_FLAIR.nii');
flirt_t1_path = fullfile(pwd, 'files/flirt_out_T1');
flirt_t2_path = fullfile(pwd, 'files/flirt_out_T2');
flirt_t1c_path = fullfile(pwd, 'files/flirt_out_T1post');
flirt_fla_path = fullfile(pwd, 'files/flirt_out_FLAIR');
flirtmat_path = fullfile(pwd, 'files/flirt_mat.mat');
bet_path = fullfile(pwd, 'files/bet_out');

% spatial normalization. flirt is a function in FSL
cmd1 = ['bash --login -c "flirt -ref ', spgr_unstrip_path, ' -in ', t1_path, ' -dof 12 -out ', ...
    flirt_t1_path, ' -omat ', flirtmat_path, '"'];
system(cmd1);

cmd2 = ['bash --login -c "flirt -ref ', spgr_unstrip_path, ' -in ', t1c_path, ' -applyxfm -out ', ...
    flirt_t1c_path, ' -init ', flirtmat_path, '"'];
cmd3 = ['bash --login -c "flirt -ref ', spgr_unstrip_path, ' -in ', t2_path, ' -applyxfm -out ', ...
    flirt_t2_path, ' -init ', flirtmat_path, '"'];
cmd4 = ['bash --login -c "flirt -ref ', spgr_unstrip_path, ' -in ', fla_path, ' -applyxfm -out ', ...
    flirt_fla_path, ' -init ', flirtmat_path, '"'];

parfor idx = 1:3
    if idx == 1
        system(cmd2);
    elseif idx == 2
        system(cmd3);
    else
        system(cmd4);
    end
end
toc

% Brain extraction. bet is also a function in FSL
cmd5 = ['bash --login -c "/usr/local/fsl/bin/bet ', [flirt_t1_path, '.nii.gz '], bet_path, ' -f 0.5 -g 0 -s -R', '"'];
system(cmd5);
gunzip([bet_path, '.nii.gz'], fullfile(pwd, 'files'));

bet_out_T1 = niftiread([bet_path, '.nii']);
ref_img = niftiread(spgr_path);
mask1 = (bet_out_T1>0).*(ref_img>0); mask1 = imfill(mask1, 'holes');

img_MR(:,:,:,1) = bet_out_T1.*mask1;

V = niftiread([flirt_t2_path, '.nii.gz']);img_MR(:,:,:,2) = V.*mask1;
V = niftiread([flirt_t2_path, '.nii.gz']);img_MR(:,:,:,3) = V.*mask1;
V = niftiread([flirt_fla_path, '.nii.gz']);img_MR(:,:,:,4) = V.*mask1;

% do the segmentation now
[out1 labeled] = MR_brain_tumor_seg_function(img_MR, 'trained3DUNetValid-18-Jan-2021-17-15-47-Epoch-1');%

% assume out1 is the results of segmentation
info = niftiinfo([bet_path, '.nii']);

% delete temp bet_out.nii to avoid multiple files confusion error
delete([bet_path, '.nii']);
delete([bet_path, '.nii.gz']);

niftiwrite(single(double(out1)*1000), fullfile(pwd, 'files/Seg_results'), info);

cmd6 = ['bash --login -c "convert_xfm -inverse ', flirtmat_path, ' -omat ', fullfile(pwd, 'files/inv_flirt_mat.mat'), '"'];
cmd7 = ['bash --login -c "flirt -interp nearestneighbour -ref ', t1_path, ' -in ', fullfile(pwd, 'files/Seg_results.nii'), ...
    ' -applyxfm -out ', fullfile(pwd, 'Image_Analysis_Result/Output/IQML_Model/Seg_results_inverted'), ' -init ', ...
    fullfile(pwd, 'files/inv_flirt_mat.mat'), '"'];
system(cmd6);
system(cmd7);
                   
