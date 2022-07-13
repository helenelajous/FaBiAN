 % Save data
% Histogram normalization between 0 and 255 of simulated SS-FSE images
norm_HASTE_Images = HASTE_Images * 255 / max(max(max(abs(HASTE_Images))));

% Only keep the magnitude image
HASTE_im = abs(norm_HASTE_Images);
output_path = 'C:\Users\admin\Desktop\auto_execution_w_noise\FAST_02\';

switch orientation
    case 1
        gzip(mat2nii_res_reorient(HASTE_im, strcat(output_path, 'sub-GA',sprintf('%02s', num2str(GA)),'_V1.nii'), 'sagittal', [FOVRead/reconMatrix FOVPhase/reconMatrix SliceThickness+SliceGap]));
    case 2
        gzip(mat2nii_res_reorient(HASTE_im, strcat(output_path, 'sub-GA',sprintf('%02s', num2str(GA)),'_V1.nii'), 'coronal', [FOVRead/reconMatrix FOVPhase/reconMatrix SliceThickness+SliceGap]));
    case 3
        gzip(mat2nii_res_reorient(HASTE_im, strcat(output_path, 'sub-GA',sprintf('%02s', num2str(GA)),'_F02.nii'), 'axial', [FOVRead/reconMatrix FOVPhase/reconMatrix SliceThickness+SliceGap]));
end     