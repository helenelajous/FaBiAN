

% LABEL 1 (Red) -> Non mature white matter
% LABEL 2 (Green) -> Mature white matter
%path = 'C:\Users\admin\Desktop\GMM and FAST segmentations on White matter\GMM Clustering'

function [WM_T1map, WM_T2map] = WM_maturation(        ref_T1map, ...
                                                      ref_T2map, ...
                                                      path, ...
                                                      segmentation, ...
                                                      GA)
                                               
% Input check
if nargin < 5 
    error('Missing input(s).');
elseif nargin > 5
    error('Too many inputs!');
end
tic;
unwrap_ref_T1map = ref_T1map(:);
unwrap_ref_T2map = ref_T2map(:);

if isequal(segmentation,'GMM')
    WM_hyd = niftiread(strcat(path, '\STA', sprintf('%02s', num2str(GA)), '\STA', sprintf('%02s', num2str(GA)), '_map1.nii'));
    WM_non_hyd = niftiread(strcat(path, '\STA', sprintf('%02s', num2str(GA)), '\STA', sprintf('%02s', num2str(GA)), '_map2.nii'));

    % We convert the unsigned integer values to doubles (uint16 --> maxvalue =
    % 2`16 - 1 = 65535
    WM_hyd = double(WM_hyd(:))./(2^16 - 1);
    WM_non_hyd = double(WM_non_hyd(:))./(2^16 - 1);

    %Searching for non background voxels
    pos_non_background = find((WM_hyd+WM_non_hyd)~=0);

    %if >0: T1 and T2 values will increase, otherwise decrease (as the WM is more dense)
    reward_map = zeros(size(pos_non_background));
    for i=1:length(reward_map)
        reward_map(i)=WM_hyd(pos_non_background(i)) - WM_non_hyd(pos_non_background(i));
    end
    %reward_map = WM_hyd - WM_non_hyd; 

    %We clip the change values to don't get outboundaries T1/T2 values
    clip_value = 'adapt';
    reward_map = clip_function(reward_map,clip_value,'sigmoid', GA);

%     clip_value = 0.3;
%     reward_map(reward_map>clip_value ) = clip_value;
%     reward_map(reward_map<(-1)*clip_value) = (-1)*clip_value;
%     reward_map = reward_map + 1; 

    
    fprintf('Applying T1 and T2 values variation through the white matter...\n');
    %prob_variation = find(reward_map~=1);
    
    for i=1:length(reward_map)
        unwrap_ref_T1map(pos_non_background(i)) = unwrap_ref_T1map(pos_non_background(i))*reward_map(i);
        unwrap_ref_T2map(pos_non_background(i)) = unwrap_ref_T2map(pos_non_background(i))*reward_map(i);
    end

elseif isequal(segmentation,'FAST')
    %%% FOR GHOLIPOUR ATLAS
%     pve0 = niftiread(strcat(path, '\STA', sprintf('%02s', num2str(GA)), '\STA', sprintf('%02s', num2str(GA)), '_WM_pve_0.nii.gz'));
%     pve1 = niftiread(strcat(path, '\STA', sprintf('%02s', num2str(GA)), '\STA', sprintf('%02s', num2str(GA)), '_WM_pve_1.nii.gz'));
%     pve2 = niftiread(strcat(path, '\STA', sprintf('%02s', num2str(GA)), '\STA', sprintf('%02s', num2str(GA)), '_WM_pve_2.nii.gz'));
    %%% FOR FETA DATASET
    pve0 = niftiread(strcat(path, '\', sprintf('%02s', num2str(GA)), '\', sprintf('%02s', num2str(GA)), '_WM_pve_0.nii.gz'));
    pve1 = niftiread(strcat(path, '\', sprintf('%02s', num2str(GA)), '\', sprintf('%02s', num2str(GA)), '_WM_pve_1.nii.gz'));
    pve2 = niftiread(strcat(path, '\', sprintf('%02s', num2str(GA)), '\', sprintf('%02s', num2str(GA)), '_WM_pve_2.nii.gz'));
    
    pos_reward = pve0(:)-pve1(:);
    neg_reward = pve1(:)-pve2(:);
    
    pos_reward(pos_reward<0)=0;
    neg_reward(neg_reward>0)=0;
    
    clip_value = 'adapt';
    pos_reward = clip_function(pos_reward,clip_value,'sigmoid', GA);
    neg_reward = clip_function(neg_reward,clip_value,'sigmoid', GA);
    
    fprintf('Applying T1 and T2 values variation through the white matter...\n');
    pos_ind = find(pos_reward~=1);
    neg_ind = find(neg_reward~=1);
    
    for i=1:length(pos_ind)
        unwrap_ref_T1map(pos_ind(i)) = unwrap_ref_T1map(pos_ind(i))*pos_reward(pos_ind(i));
        unwrap_ref_T2map(pos_ind(i)) = unwrap_ref_T2map(pos_ind(i))*pos_reward(pos_ind(i));
    end
    
    for i=1:length(neg_ind)
        unwrap_ref_T1map(neg_ind(i)) = unwrap_ref_T1map(neg_ind(i))*neg_reward(neg_ind(i));
        unwrap_ref_T2map(neg_ind(i)) = unwrap_ref_T2map(neg_ind(i))*neg_reward(neg_ind(i));
    end

end

WM_T1map = reshape(unwrap_ref_T1map, size(ref_T1map));
WM_T2map = reshape(unwrap_ref_T2map, size(ref_T2map));
fprintf('Temporal Resolution improved in %0.5f seconds ! :D\n', toc);

% diff_images2;

end