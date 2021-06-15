function result = DeepBrainSeg()
addpath DeepBT_Function
addpath DeepNI_Function
addpath DICOM2Nifti
%deep brain seg model
system('cd /root/DeepBrainSeg; python DBsegmentation.py;','-echo');
testhandle_seg_results();
try
    img = niftiread('/root/DeepBrainSeg/Seg_Result/segmentation/DeepBrainSeg_Prediction_inverted.nii');
catch ME
    disp('Error Message:');
    disp(ME.message);
end

info = niftiinfo('/root/DeepBrainSeg/Seg_Result/segmentation/DeepBrainSeg_Prediction_inverted.nii');
img(img==4) = 3;
niftiwrite(img,'/root/DeepBrainSeg/Seg_Result/segmentation/DeepBrainSeg_Prediction_inverted.nii',info);
Results = '/root/DeepBrainSeg/Seg_Result/segmentation/DeepBrainSeg_Prediction_inverted.nii';

try
    fileID = fopen(Results, 'r');
    result = fread(fileID,'*bit8');
    fclose(fileID);
catch ME
    disp('Error Message:')
    disp(ME.message)
end
% delete result file         
system('rm -rf /root/DeepBrainSeg/Seg_Result/segmentation/DeepBrainSeg_Prediction_inverted.nii','-echo');
