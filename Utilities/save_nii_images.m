%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Function that saves the T2w simulation of the fetal brain along with   %
%  its label map according to the gestational age of the fetus and to     %
%  the acquisition plane                                                  %
%                                                                         %
%                save_nii_images(FSE_Images, ...                          %
%                           Label_Map_recon, ...                          %
%                                        GA, ...                          %
%                               orientation, ...                          %
%                             output_folder)                              %
%                                                                         %
%  inputs:  - FSE_images: simulated T2-weighted MR images of the fetal    %
%                         brain based on the acquisition scheme of FSE    %
%                         sequences                                       %
%           - Label_Map_recon: Simulation's label map derived from the    %
%                              reference model                            %
%           - GA: gestational age of the fetus (in weeks)                 %
%           - orientation: strict acquisition plane (axial, coronal or    %
%                          sagittal)                                      %
%           - output_folder: folder where the simulated images are saved  %
%                                                                         %
%                                                                         %
%                                                                         %
%  le Boeuf Andrés, 2022-07-13                                            %
%  andres.le.boeuf@estudiantat.upc.edu                                    %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function save_nii_images(FSE_Images, ...
                    Label_Map_recon, ...
                    GA, ...
                    orientation, ...
                    output_folder)

% Input check
if nargin < 5
    error('Missing input(s).');
elseif nargin > 5
    error('Too many inputs.');
end

switch orientation
    case 1
        acq_plane = 'sagittal';
    case 2
        acq_plane = 'coronal';
    case 3
        acq_plane = 'axial';
end

% Histogram normalization between 0 and 255 of simulated SS-FSE images
norm_HASTE_Images = FSE_Images * 255 / max(max(max(abs(FSE_Images))));

% Only keep the magnitude image
HASTE_im = abs(norm_HASTE_Images);

% Define final paths of the images
output_file_path = strcat(output_folder, 'sub-',sprintf('%01s', num2str(GA)),'_T2w.nii');
output_file_label_path = strcat(output_folder, 'sub-',sprintf('%01s', num2str(GA)),'_labels.nii');

% Save images
gzip(mat2nii_res_reorient(HASTE_im, output_file_path, acq_plane, [FOVRead/reconMatrix FOVPhase/reconMatrix SliceThickness+SliceGap]));
gzip(mat2nii_res_reorient(Label_Map_recon, output_file_label_path, acq_plane, [FOVRead/reconMatrix FOVPhase/reconMatrix SliceThickness+SliceGap]));


end     