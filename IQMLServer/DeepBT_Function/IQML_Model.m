function result = IQML_Model()
addpath DeepBT_Function
addpath DeepNI_Function
addpath DICOM2Nifti
% FSL processing and deep learning model
segment_PGBM();
result_nii_path = fullfile(pwd, 'Image_Analysis_Result/Output/IQML_Model/Seg_results_inverted.nii');
result_niigz_path = fullfile(pwd, 'Image_Analysis_Result/Output/IQML_Model/Seg_results_inverted.nii.gz');
try
    img = niftiread(result_niigz_path);
catch ME
    disp('Error Message:')
    disp(ME.message)
end

info = niftiinfo(result_niigz_path);
img = round(img/1000);
niftiwrite(img, result_nii_path, info);
Results = result_nii_path;

try
    fileID = fopen(Results, 'r');
    result = fread(fileID,'*bit8');
    fclose(fileID);
catch ME
    disp('Error Message:')
    disp(ME.message)
end
% delete result file   
cmd1 = ['rm -rf ', result_niigz_path];
system(cmd1, '-echo');