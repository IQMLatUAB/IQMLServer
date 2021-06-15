%% assume out1 is the results of segmentation
info = niftiinfo('C:\temp\bet_out.nii');

niftiwrite(single(double(out1)*1000), 'c:\temp\Seg_results', info);

system('bash -c "cp /mnt/c/temp/Seg_results.nii /home/yfang/data"');


system('bash --login -c "convert_xfm -inverse /home/yfang/data/flirt_mat.mat -omat /home/yfang/data/inv_flirt_mat.mat"');
system('bash --login -c "flirt -interp nearestneighbour -ref /home/yfang/data/test_now_T1.nii -in /home/yfang/data/Seg_results.nii -applyxfm -out /home/yfang/data/Seg_results_inverted -init /home/yfang/data/inv_flirt_mat.mat"');
system('bash -c "cp /home/yfang/data/Seg_results_inverted.nii.gz /mnt/c/temp/"');

V = niftiread('C:\temp\Seg_results_inverted.nii.gz');
V = round(V/1000);
Vtemp1 = niftiread('c:\temp\input_T1_original.nii');

V_seg_results_nifti = V(row_start:(row_start+size(Vtemp1,1)-1), col_start:(col_start+size(Vtemp1,2)-1),:);

V_seg_results_ori_T1 = flip(permute(V_seg_results_nifti,[2 1 3]),1); % now it is back to the original T1 orientation


%%
% 
% dicomrt_hdr = dicominfo('D:\Data\NCKU_period\KC_Lung\14-21237320\20100813\LI_XI_HAI_21237320\__20100813_105421_000000\TRUED_RTSS_0001\LI_XI_HAI.RTSTRUCT._.0001.0000.2013.04.25.14.32.27.685193.34040635.IMA');
% 
% dicomimg_hdr = dicominfo('D:\Data\NCKU_period\KC_Lung\14-21237320\20100813\LI_XI_HAI_21237320\__20100813_105421_000000\PET_AC_2D_AVGCT_E_0003\LI_XI_HAI.PT._.0003.0001.2013.04.25.14.32.27.685193.28211921.IMA');


%%
target_img_dir = img_dir{sub_idx}{1};
file_info = ori_T1_fileinfo;

for idx = 1:length(file_info)
    
    %temp1 = double(dicomread(file_info{idx}));
    
    temp2 = dicominfo(file_info{idx});
    mat_pos(:,idx) = temp2.ImagePositionPatient;
    orientation_matrix{idx} = reshape(temp2.ImageOrientationPatient, [3 2]).*[temp2.PixelSpacing temp2.PixelSpacing temp2.PixelSpacing]';
    
    target_img_hdr = temp2;
end

%%
dicomrt_hdr.StudyInstanceUID = target_img_hdr.StudyInstanceUID;
%dicomrt_hdr.SeriesInstanceUID = target_img_hdr.SeriesInstanceUID;
dicomrt_hdr.PatientName = target_img_hdr.PatientName;
dicomrt_hdr.PatientID = target_img_hdr.PatientID;
dicomrt_hdr.StructureSetLabel = 'Tumor_contour';
dicomrt_hdr.StructureSetName = 'Tumor';
dicomrt_hdr.StructureSetDate = '20200624';
dicomrt_hdr.StructureSetTime = '162300.000000';
dicomrt_hdr.StudyDate = target_img_hdr.StudyDate;
dicomrt_hdr.SeriesDate = target_img_hdr.SeriesDate;

%dicomrt_hdr.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.ReferencedSOPInstanceUID= target_img_hdr.StudyInstanceUID;
dicomrt_hdr.ReferencedFrameOfReferenceSequence.Item_1.FrameOfReferenceUID = target_img_hdr.FrameOfReferenceUID;
dicomrt_hdr.PatientPosition = target_img_hdr.PatientPosition;
dicomrt_hdr.ROIContourSequence.Item_1.ContourSequence.Item_1.ContourImageSequence.Item_1.ReferencedSOPClassUID = ...
    target_img_hdr.SOPClassUID;
dicomrt_hdr.ROIContourSequence.Item_1.ContourSequence.Item_1.ContourImageSequence.Item_1.ReferencedSOPInstanceUID = ...
    target_img_hdr.SOPInstanceUID;
dicomrt_hdr.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.ContourImageSequence.Item_1.ReferencedSOPClassUID = ...
    target_img_hdr.SOPClassUID;
dicomrt_hdr.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.ContourImageSequence.Item_1.ReferencedSOPInstanceUID = ...
    target_img_hdr.SOPInstanceUID;
dicomrt_hdr.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.SeriesInstanceUID = ...
    target_img_hdr.SeriesInstanceUID;
dicomrt_hdr.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.ContourImageSequence.Item_1=rmfield(dicomrt_hdr.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.ContourImageSequence.Item_1,'ReferencedFrameNumber');

%%
%dicomrt_hdr.ROIContourSequence = rmfield(dicomrt_hdr.ROIContourSequence,'Item_2');
%dicomrt_hdr.ROIContourSequence = rmfield(dicomrt_hdr.ROIContourSequence,'Item_3');
%dicomrt_hdr.ROIContourSequence = rmfield(dicomrt_hdr.ROIContourSequence,'Item_4');

%dicomrt_hdr.StructureSetROISequence = rmfield(dicomrt_hdr.StructureSetROISequence,'Item_2');
%dicomrt_hdr.StructureSetROISequence = rmfield(dicomrt_hdr.StructureSetROISequence,'Item_3');
%dicomrt_hdr.StructureSetROISequence = rmfield(dicomrt_hdr.StructureSetROISequence,'Item_4');

%dicomrt_hdr.RTROIObservationsSequence = rmfield(dicomrt_hdr.RTROIObservationsSequence,'Item_2');
%dicomrt_hdr.RTROIObservationsSequence = rmfield(dicomrt_hdr.RTROIObservationsSequence,'Item_3');
%dicomrt_hdr.RTROIObservationsSequence = rmfield(dicomrt_hdr.RTROIObservationsSequence,'Item_4');

%%
for idx = 2:9
    dicomrt_hdr.ROIContourSequence.Item_1.ContourSequence = rmfield(dicomrt_hdr.ROIContourSequence.Item_1.ContourSequence,['Item_' num2str(idx)]);
end
for idx = 2:8
    dicomrt_hdr.ROIContourSequence.Item_2.ContourSequence = rmfield(dicomrt_hdr.ROIContourSequence.Item_2.ContourSequence,['Item_' num2str(idx)]);
end
for idx = 2:7
    dicomrt_hdr.ROIContourSequence.Item_3.ContourSequence = rmfield(dicomrt_hdr.ROIContourSequence.Item_3.ContourSequence,['Item_' num2str(idx)]);
end
dicomrt_hdr.ROIContourSequence.Item_5 = dicomrt_hdr.ROIContourSequence.Item_4;
dicomrt_hdr.ROIContourSequence.Item_5.ReferencedROINumber = 5;
dicomrt_hdr.StructureSetROISequence.Item_5 = dicomrt_hdr.StructureSetROISequence.Item_4;
dicomrt_hdr.StructureSetROISequence.Item_5.ROINumber = 5;
for idx = 2
    dicomrt_hdr.ROIContourSequence.Item_4.ContourSequence = rmfield(dicomrt_hdr.ROIContourSequence.Item_4.ContourSequence,['Item_' num2str(idx)]);
    dicomrt_hdr.ROIContourSequence.Item_5.ContourSequence = rmfield(dicomrt_hdr.ROIContourSequence.Item_5.ContourSequence,['Item_' num2str(idx)]);
end
for idx = 2:299
    dicomrt_hdr.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.ContourImageSequence = ...
        rmfield(dicomrt_hdr.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.ContourImageSequence,['Item_' num2str(idx)]);
end
dicomrt_hdr.ROIContourSequence.Item_1.ContourSequence.Item_1.ContourImageSequence.Item_1 = ...
    rmfield(dicomrt_hdr.ROIContourSequence.Item_1.ContourSequence.Item_1.ContourImageSequence.Item_1,'ReferencedFrameNumber');
dicomrt_hdr.ROIContourSequence.Item_2.ContourSequence.Item_1.ContourImageSequence.Item_1 = ...
    rmfield(dicomrt_hdr.ROIContourSequence.Item_2.ContourSequence.Item_1.ContourImageSequence.Item_1,'ReferencedFrameNumber');
dicomrt_hdr.ROIContourSequence.Item_3.ContourSequence.Item_1.ContourImageSequence.Item_1 = ...
    rmfield(dicomrt_hdr.ROIContourSequence.Item_3.ContourSequence.Item_1.ContourImageSequence.Item_1,'ReferencedFrameNumber');

dicomrt_hdr.ROIContourSequence.Item_4.ContourSequence.Item_1.ContourImageSequence.Item_1 = ...
    rmfield(dicomrt_hdr.ROIContourSequence.Item_4.ContourSequence.Item_1.ContourImageSequence.Item_1,'ReferencedFrameNumber');
dicomrt_hdr.ROIContourSequence.Item_5.ContourSequence.Item_1.ContourImageSequence.Item_1 = ...
    rmfield(dicomrt_hdr.ROIContourSequence.Item_5.ContourSequence.Item_1.ContourImageSequence.Item_1,'ReferencedFrameNumber');
% dicomrt_hdr.ROIContourSequence.Item_5.ContourSequence.Item_1.ContourImageSequence.Item_1 = ...
%     rmfield(dicomrt_hdr.ROIContourSequence.Item_3.ContourSequence.Item_1.ContourImageSequence.Item_1,'ReferencedFrameNumber');


%%
dicomrt_hdr.ROIContourSequence.Item_1.ROIDisplayColor = [255 0 0]';
dicomrt_hdr.ROIContourSequence.Item_2.ROIDisplayColor = [255 0 255]';
dicomrt_hdr.ROIContourSequence.Item_3.ROIDisplayColor = [255 128 255];
dicomrt_hdr.ROIContourSequence.Item_4.ROIDisplayColor = [255 255 0];
dicomrt_hdr.ROIContourSequence.Item_5.ROIDisplayColor = [0 0 255];

for idx_target = 1:5
    if idx_target==1
        mask1 = flip(((V_seg_results_ori_T1==1) + (V_seg_results_ori_T1==3))>0,3); % img_T1 has been flipped in the 3rd dimension
        now_ROI_name = 'NE+E Tumor';
    elseif idx_target==2
        mask1 = flip((V_seg_results_ori_T1>=1),3); % img_T1 has been flipped in the 3rd dimension
        now_ROI_name = 'Edema+NE+E Tumor';
    elseif idx_target==3
        mask1 = flip(V_seg_results_ori_T1==1,3); % img_T1 has been flipped in the 3rd dimension
        now_ROI_name = 'NE Tumor';
    elseif idx_target==4
        mask1 = flip(V_seg_results_ori_T1==3,3); % img_T1 has been flipped in the 3rd dimension
        now_ROI_name = 'E Tumor';
    else        
        mask1 = flip(V_seg_results_ori_T1==2,3); % img_T1 has been flipped in the 3rd dimension
        now_ROI_name = 'Edema';
    end
    
    slices_to_do = find(sum(mipdim(mask1,1))>0);
    n_slices = length(slices_to_do);
    
    now_item = 0;
    
    for idx1 = 1:n_slices
        now_slice = slices_to_do(idx1);
        tempmask4 = mask1(:,:,now_slice);
        
        label1 = bwlabel(tempmask4);
        label1(find(tempmask4==0)) = -1;
        label_vec = unique(label1(:));
        
        A = zeros(4,4); A(4,4) = 1; A(1:3,4) = mat_pos(:,now_slice);
        A(1:3,1:2) = orientation_matrix{now_slice};
        
        for idx_label = 2:length(label_vec)
            now_item=now_item+1;
            tempmask = label1== label_vec(idx_label);
            [r c] = mask2poly(tempmask);
            pos_vertices = zeros(length(r), 3);
            
            for idx = 1:length(r)
                now_ijk = [c(idx)-1 r(idx)-1 now_slice-1 1]';
                temp1 = A*now_ijk;
                pos_vertices(idx, :) = temp1(1:3)';
            end
            
            tempmat = pos_vertices';
            eval(['dicomrt_hdr.ROIContourSequence.Item_' num2str(idx_target) '.ContourSequence.Item_' num2str(now_item) '.ContourData = tempmat(:);']);
            eval(['dicomrt_hdr.ROIContourSequence.Item_' num2str(idx_target) '.ContourSequence.Item_' num2str(now_item) '.NumberOfContourPoints = length(r);']);
            if now_item >1
                eval(['dicomrt_hdr.ROIContourSequence.Item_' num2str(idx_target) '.ContourSequence.Item_' num2str(now_item) '.ContourGeometricType = dicomrt_hdr.ROIContourSequence.Item_' num2str(idx_target) '.ContourSequence.Item_1.ContourGeometricType;']);
                eval(['dicomrt_hdr.ROIContourSequence.Item_' num2str(idx_target) '.ContourSequence.Item_' num2str(now_item) '.ContourImageSequence = dicomrt_hdr.ROIContourSequence.Item_' num2str(idx_target) '.ContourSequence.Item_1.ContourImageSequence;']);
            end
        end
    end
    eval(['dicomrt_hdr.StructureSetROISequence.Item_' num2str(idx_target) '.ROIName = ''' now_ROI_name ''';']);
end



% %%
% mask1 = flip(V_seg_results_ori_T1==1,3); % img_T1 has been flipped in the 3rd dimension
% 
% slices_to_do = find(sum(mipdim(mask1,1))>0);
% n_slices = length(slices_to_do);
% 
% now_item = 0;
% 
% for idx1 = 1:n_slices
%     now_slice = slices_to_do(idx1);
%     tempmask4 = mask1(:,:,now_slice);
%         
%     label1 = bwlabel(tempmask4);
%     label1(find(tempmask4==0)) = -1;
%     label_vec = unique(label1(:));
%     
%     A = zeros(4,4); A(4,4) = 1; A(1:3,4) = mat_pos(:,now_slice);
%     A(1:3,1:2) = orientation_matrix{now_slice};
%     
%     for idx_label = 2:length(label_vec)
%         now_item=now_item+1;
%         tempmask = label1== label_vec(idx_label);
%         [r c] = mask2poly(tempmask);
%         pos_vertices = zeros(length(r), 3);
%         
%         for idx = 1:length(r)
%             now_ijk = [c(idx)-1 r(idx)-1 now_slice-1 1]';
%             temp1 = A*now_ijk;
%             pos_vertices(idx, :) = temp1(1:3)';
%         end
%         
%         tempmat = pos_vertices';
%         eval(['dicomrt_hdr.ROIContourSequence.Item_1.ContourSequence.Item_' num2str(now_item) '.ContourData = tempmat(:);']);
%         eval(['dicomrt_hdr.ROIContourSequence.Item_1.ContourSequence.Item_' num2str(now_item) '.NumberOfContourPoints = length(r);']);
%         if now_item >1
%             eval(['dicomrt_hdr.ROIContourSequence.Item_1.ContourSequence.Item_' num2str(now_item) '.ContourGeometricType = dicomrt_hdr.ROIContourSequence.Item_1.ContourSequence.Item_1.ContourGeometricType;']);
%             eval(['dicomrt_hdr.ROIContourSequence.Item_1.ContourSequence.Item_' num2str(now_item) '.ContourImageSequence = dicomrt_hdr.ROIContourSequence.Item_1.ContourSequence.Item_1.ContourImageSequence;']);
%         end
%     end
% end
% dicomrt_hdr.StructureSetROISequence.Item_1.ROIName = 'AI_NonEnhancingTumor';
% 
% %%
% mask2 = flip(V_seg_results_ori_T1==2,3); % img_T1 has been flipped in the 3rd dimension
% 
% slices_to_do = find(sum(mipdim(mask2,1))>0);
% n_slices = length(slices_to_do);
% now_item = 0;
% 
% for idx1 = 1:n_slices
%     now_slice = slices_to_do(idx1);
%     tempmask4 = mask2(:,:,now_slice);
%     tempmask4 = tempmask4>0.5;
%     
%     
%     label1 = bwlabel(tempmask4);
%     label1(find(tempmask4==0)) = -1;
%     label_vec = unique(label1(:));
%     A = zeros(4,4); A(4,4) = 1; A(1:3,4) = mat_pos(:,now_slice);
%     A(1:3,1:2) = orientation_matrix{now_slice};
%     
%     for idx_label = 2:length(label_vec)
%         now_item=now_item+1;
%         tempmask = label1== label_vec(idx_label);
%         [r c] = mask2poly(tempmask);
%         pos_vertices = zeros(length(r), 3);
%         
%         for idx = 1:length(r)
%             now_ijk = [c(idx)-1 r(idx)-1 now_slice-1 1]';
%             temp1 = A*now_ijk;
%             pos_vertices(idx, :) = temp1(1:3)';
%         end
%         
%         tempmat = pos_vertices';
%         
%         eval(['dicomrt_hdr.ROIContourSequence.Item_2.ContourSequence.Item_' num2str(now_item) '.ContourData = tempmat(:);']);
%         eval(['dicomrt_hdr.ROIContourSequence.Item_2.ContourSequence.Item_' num2str(now_item) '.NumberOfContourPoints = length(r);']);
%         if now_item >1
%             eval(['dicomrt_hdr.ROIContourSequence.Item_2.ContourSequence.Item_' num2str(now_item) '.ContourGeometricType = dicomrt_hdr.ROIContourSequence.Item_2.ContourSequence.Item_1.ContourGeometricType;']);
%             eval(['dicomrt_hdr.ROIContourSequence.Item_2.ContourSequence.Item_' num2str(now_item) '.ContourImageSequence = dicomrt_hdr.ROIContourSequence.Item_2.ContourSequence.Item_1.ContourImageSequence;']);
%         end
%     end
% end
% dicomrt_hdr.StructureSetROISequence.Item_2.ROIName = 'AI_Edema';
% 
% %%
% mask3 = flip(V_seg_results_ori_T1==3,3); % img_T1 has been flipped in the 3rd dimension
% 
% slices_to_do = find(sum(mipdim(mask3,1))>0);
% n_slices = length(slices_to_do);
% now_item = 0;
% 
% for idx1 = 1:n_slices
%     now_slice = slices_to_do(idx1);
%     tempmask4 = mask3(:,:,now_slice);
%     tempmask4 = tempmask4>0.5;
%     
%     
%     label1 = bwlabel(tempmask4);
%     label1(find(tempmask4==0)) = -1;
%     label_vec = unique(label1(:));
%     A = zeros(4,4); A(4,4) = 1; A(1:3,4) = mat_pos(:,now_slice);
%     A(1:3,1:2) = orientation_matrix{now_slice};
%     
%     for idx_label = 2:length(label_vec)
%         now_item=now_item+1;
%         tempmask = label1== label_vec(idx_label);
%         [r c] = mask2poly(tempmask);
%         pos_vertices = zeros(length(r), 3);
%         
%         for idx = 1:length(r)
%             now_ijk = [c(idx)-1 r(idx)-1 now_slice-1 1]';
%             temp1 = A*now_ijk;
%             pos_vertices(idx, :) = temp1(1:3)';
%         end
%         
%         tempmat = pos_vertices';
%         
%         eval(['dicomrt_hdr.ROIContourSequence.Item_3.ContourSequence.Item_' num2str(now_item) '.ContourData = tempmat(:);']);
%         eval(['dicomrt_hdr.ROIContourSequence.Item_3.ContourSequence.Item_' num2str(now_item) '.NumberOfContourPoints = length(r);']);
%         if now_item >1
%             eval(['dicomrt_hdr.ROIContourSequence.Item_3.ContourSequence.Item_' num2str(now_item) '.ContourGeometricType = dicomrt_hdr.ROIContourSequence.Item_3.ContourSequence.Item_1.ContourGeometricType;']);
%             eval(['dicomrt_hdr.ROIContourSequence.Item_3.ContourSequence.Item_' num2str(now_item) '.ContourImageSequence = dicomrt_hdr.ROIContourSequence.Item_3.ContourSequence.Item_1.ContourImageSequence;']);
%         end
%     end
% end
% dicomrt_hdr.StructureSetROISequence.Item_3.ROIName = 'AI_EnhancingTumor';
% 
%%
output_filename = fullfile('D:\Data\Brain tumor MRI cases\test_0112_2021', 'RTSS_output.dcm');

dicomwrite([], output_filename, dicomrt_hdr, 'CreateMode', 'copy')



