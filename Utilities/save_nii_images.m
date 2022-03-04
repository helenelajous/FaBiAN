% Save data

% Histogram normalization between 0 and 255 of simulated SS-FSE images
norm_HASTE_Images = HASTE_Images * 255 / max(max(max(abs(HASTE_Images))));

% Only keep the magnitude image
HASTE_im = abs(norm_HASTE_Images);
output_path = './data/ITK_images/';

switch orientation
    case 1
        gzip(mat2nii_res_reorient(HASTE_im, strcat(output_path, 'sub-xx_T2w.nii'), 'sagittal', [FOVRead/reconMatrix FOVPhase/reconMatrix SliceThickness+SliceGap]));
    case 2
        gzip(mat2nii_res_reorient(HASTE_im, strcat(output_path, 'sub-xx_T2w.nii'), 'coronal', [FOVRead/reconMatrix FOVPhase/reconMatrix SliceThickness+SliceGap]));
    case 3
        gzip(mat2nii_res_reorient(HASTE_im, strcat(output_path, 'sub-xx_T2w.nii'), 'axial', [FOVRead/reconMatrix FOVPhase/reconMatrix SliceThickness+SliceGap]));
end     