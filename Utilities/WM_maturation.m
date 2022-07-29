%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Function that implements white matter maturation processes tuning      %
%  the T1 and T2 values from the reference maps. 2 methods are available: %
%  GMM 2 classes segmentation and FAST-FSL 3 classes one.                 %
%                                                                         % 
% [WM_T1map, WM_T2map] = WM_maturation(  ref_T1map, ...                   %
%                                        ref_T2map, ...                   %
%                                               GA, ...                   %
%                                     segmentation, ...                   %
%                                       orientation)                      %
%                                                                         %
%  inputs:  - ref_T1map: reference T1 map of the fetal brain              %
%           - ref_T2map: reference T2 map of the fetal brain              %
%           - GA: gestational age of the fetus (in weeks)                 %
%           - segmentation: 2 ways of improving white matter              %
%                           heterogeneity: 'FAST' or 'GMM'                %
%           - orientation: strict acquisition plane (axial, coronal or    %
%                          sagittal)                                      %
%                                                                         %
%  outputs: - WM_T1map: tuned T1 map of the fetal brain                   %
%           - WM_T2map: tuned T2 map of the fetal brain                   %
%                                                                         %
%                                                                         %
%  le Boeuf Andrés, 2022-03-23                                            %
%  andres.le.boeuf@estudiantat.upc.edu                                    %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%sss

function [WM_T1map, WM_T2map] = WM_maturation(        ref_T1map, ...
                                                      ref_T2map, ...
                                                             GA, ...
                                                   segmentation, ...
                                                     orientation)
                                               
% Input check
if nargin < 5
    error('Missing input(s).');
elseif nargin > 5
    error('Too many inputs!');
end

tic;
% Flatten T1 and T2 3D maps 
unwrap_ref_T1map = ref_T1map(:);
unwrap_ref_T2map = ref_T2map(:);

if isequal(segmentation,'FAST')
    %Import and set up Partial Volume Maps from FAST segmentation tool
    path = '.\data\atlas_fast_clustering';
    pve0 = niftiread(strcat(path, '\STA', sprintf('%02s', num2str(GA)), '\STA', sprintf('%02s', num2str(GA)), '_WM_pve_0.nii.gz'));
    pve1 = niftiread(strcat(path, '\STA', sprintf('%02s', num2str(GA)), '\STA', sprintf('%02s', num2str(GA)), '_WM_pve_1.nii.gz'));
    pve2 = niftiread(strcat(path, '\STA', sprintf('%02s', num2str(GA)), '\STA', sprintf('%02s', num2str(GA)), '_WM_pve_2.nii.gz'));
    
    pve0 = volume_reorient(pve0, orientation);
    pve1 = volume_reorient(pve1, orientation);
    pve2 = volume_reorient(pve2, orientation);
    
    %Build advantage/disadvantage values
    pos_reward = pve0(:)-pve1(:);
    neg_reward = pve1(:)-pve2(:);
    
    pos_reward(pos_reward<0)=0;
    neg_reward(neg_reward>0)=0;
    
    %Out boundaries control of the advantage/disadvantage values
    clip_value = 'adapt';
    pos_reward = clip_function(pos_reward,clip_value, GA);
    neg_reward = clip_function(neg_reward,clip_value, GA);
    
    fprintf('Applying T1 and T2 values variation through the white matter...\n');
    pos_ind = find(pos_reward~=1);
    neg_ind = find(neg_reward~=1);
    
    % Wheigth T1 and T2 reference values with the new advantage/disadvantage
    % values
    for i=1:length(pos_ind)
        unwrap_ref_T1map(pos_ind(i)) = unwrap_ref_T1map(pos_ind(i))*pos_reward(pos_ind(i));
        unwrap_ref_T2map(pos_ind(i)) = unwrap_ref_T2map(pos_ind(i))*pos_reward(pos_ind(i));
    end
    
    for i=1:length(neg_ind)
        unwrap_ref_T1map(neg_ind(i)) = unwrap_ref_T1map(neg_ind(i))*neg_reward(neg_ind(i));
        unwrap_ref_T2map(neg_ind(i)) = unwrap_ref_T2map(neg_ind(i))*neg_reward(neg_ind(i));
    end
 elseif isequal(segmentation,'GMM')
     %Import and set up Partial Volume Maps from GMM segmentation 
     path = '.\data\atlas_gmm_clustering';
     WM_hyd = niftiread(strcat(path, '\STA', sprintf('%02s', num2str(GA)), '\STA', sprintf('%02s', num2str(GA)), '_map1.nii'));
     WM_non_hyd = niftiread(strcat(path, '\STA', sprintf('%02s', num2str(GA)), '\STA', sprintf('%02s', num2str(GA)), '_map2.nii'));

     % We convert the unsigned integer values to doubles (uint16 --> maxvalue =
     % 2`16 - 1 = 65535
     WM_hyd = double(WM_hyd(:))./(2^16 - 1);
     WM_non_hyd = double(WM_non_hyd(:))./(2^16 - 1);

     %Searching for non background voxels
     pos_non_background = find((WM_hyd+WM_non_hyd)~=0);

     %if >0: T1 and T2 values will increase, otherwise decrease (as the WM is more dense, therefore "darker" white matter)
     reward_map = zeros(size(pos_non_background));
     for i=1:length(reward_map)
         reward_map(i)=WM_hyd(pos_non_background(i)) - WM_non_hyd(pos_non_background(i));
     end

     %We clip the change values to don't get outboundaries T1/T2 values
     clip_value = 'adapt';
     reward_map = clip_function(reward_map,clip_value,'sigmoid', GA);

     fprintf('Applying T1 and T2 values variation through the white matter...\n');
    
     for i=1:length(reward_map)
         unwrap_ref_T1map(pos_non_background(i)) = unwrap_ref_T1map(pos_non_background(i))*reward_map(i);
         unwrap_ref_T2map(pos_non_background(i)) = unwrap_ref_T2map(pos_non_background(i))*reward_map(i);
     end
end


WM_T1map = reshape(unwrap_ref_T1map, size(ref_T1map));
WM_T2map = reshape(unwrap_ref_T2map, size(ref_T2map));
fprintf('Temporal Resolution improved in %0.5f seconds ! :D\n', toc);


end