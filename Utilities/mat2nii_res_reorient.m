%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Function that converts a matlab matrix into an image in .nifti format. %
%                                                                         %
%        varargout = mat2nii(I, outFilename, orientation, varargin)       %
%                                                                         %
%  inputs:  - I: simulated HASTE images stored as .mat files              %
%           - outFilename: output directory where nifti images will be    %
%                          stored                                         %
%           - orientation: selected orientation of acquisition of the     %
%                          images                                         %
%           - other possible input arguments                              %
%                                                                         %
%  output: The Matlab matrix I is saved in nifti format in outFilename.   %
%                                                                         %
%  NB: The sign of the voxSize() and centCoord() components of the first  %
%  and second columns of the orientation matrix have been changed to the  %
%  opposite signs compared to the previous implementation of the          %
%  mat2nii_res.m function in order to automatically reorient the          %
%  simulated images, respectively LR and AP, in the same physical space   %
%  as the atlas and FeTA images (e.g., RAI instead of LPI in the axial    %
%  view).                                                                 %
%                                                                         %
%                                                                         %
%  Adapted from Yasser Aleman-Gomez, 2021-05-12                           %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function varargout = mat2nii_res_reorient(I, outFilename, orientation, voxSize, varargin)

addpath('C:\Users\admin\Documents\MATLAB\spm12')
%% ====================== Checking input parameters ===================== %

if nargin < 3   %Indispensable input arguments are not provided
    error('Three input arguments are mandatory');
else
    % Parameters
    dimG = size(I); %Image dimension
    if length(dimG) == 3
        dimG(4) = 1;
    end
%     conv   = {@uint8, @int16, @int32, @single, @double, @int8, @uint16, @uint32};
%     types  = [     2       4       8       16       64    256      512      768];
    dtype = [16 1]; %Data type
end

% Deal with the input arguments
if nargin < 3   %Indispensable input arguments are not provided
    error('Three inputs are mandatory');
else
    if numel(varargin) > 0  %Optional input arguments are provided
        while ~isempty(varargin)
            if numel(varargin) < 2
                error('You need to provide optional input arguments as ''ParameterName''-''ParameterValue'' pairs.');
            end
            switch varargin{1}
%                 case 'voxSize'  %Voxel size
%                     voxSize=varargin{2};
                case 'dtype'    %Data type
                    dtype=varargin{2};
                otherwise
                    error('Unexpected ''ParameterName'' input: %s\n',varargin{1});
            end
            varargin(1:2) = []; %This pair of optional input arguments has been dealt with -- remove...
        end
    end
end

%% ================== End of checking input parameters ================== %

centCoord = dimG(1:3).*voxSize*1/2;

%% ======================= Main program ================================= %

% Creating an empty header
switch orientation
    case 'axial'
        dimG = size(I);
        if length(dimG) == 3
            dimG(4) = 1;
        end
        centCoord = dimG(1:3).*voxSize*1/2;
        orientMat = [-voxSize(1) 0 0 centCoord(1); 0 -voxSize(2) 0 centCoord(2); 0 0 voxSize(3) -centCoord(3); 0 0 0 1];
    case 'coronal'
        orientMat = [-voxSize(1) 0 0 centCoord(1); 0 0 -voxSize(3) centCoord(3); 0 voxSize(2) 0 -centCoord(2); 0 0 0 1];
    case 'sagittal'
        orientMat = [0 0 -voxSize(3) centCoord(3); -voxSize(1) 0 0 centCoord(1); 0 voxSize(2) 0 -centCoord(2); 0 0 0 1];
    otherwise
        error('Please enter a correct orientation');
end

Vol = struct(  'fname',            '', ...
                 'dim',     dimG(1:3), ...
                 'mat',     orientMat, ...
               'pinfo',      [1 0 0]', ...
             'descrip', 'Description', ...
                  'dt',         dtype);
Vol = Vol(ones(dimG(4), 1));

% Creating the volume
for i = 1:dimG(4)
    Vol(i).fname = outFilename;
    Vol(i).n = [i 1];
end
Vol = spm_create_vol(Vol);

% Writing the volume
for i = 1:dimG(4)
    disp(['Writing volume: Number ' num2str(i) ' of ' num2str(dimG(4))]);
    spm_write_vol(Vol(i), I(:,:,:,i));
end

fclose('all');

%% ================ End of Main program ================================= %

% Outputs
varargout{1} = outFilename;

return;