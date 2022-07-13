%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Function that transforms the advantage/disadvantage values to          %
%  new controlled ones through a sigmoid                                  %
%                                                                         % 
%              new_map = clip_function(  map, ...                         %
%                                 clip_value, ...                         %
%                           type_of_function, ...                         %
%                                          GA)                            %
%                                                                         %
%  inputs:  - map: advantage/disadvantage values to tune T1/T2 maps       %
%           - clip_value: Control value set to not deviate T1/T2 values   %
%                         more than a specific percentage. 'adapt' option %
%                         takes the clip value from a list derived from   %
%                         analyzing the contrast of the subject which is  %
%                         being simulated.                                %
%           - GA: gestational age of the fetus (in weeks)                 %
%                                                                         %
%                                                                         %
%  outputs: - new_map: Controlled advantage/disadvantage values           %
%                                                                         %
%                                                                         %
%  le Boeuf Andrés, 2022-07-13                                            %
%  andres.le.boeuf@estudiantat.upc.edu                                    %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function new_map = clip_function(map,clip_value, GA)

% Input check
if nargin < 3
    error('Missing input(s).');
elseif nargin > 3
    error('Too many inputs!');
end

%Clipping value selection
if isequal(clip_value,'adapt')
    clip_values = [0.25, 0.28, 0.33, 0.4, 0.45, 0.48, 0.47, 0.49, 0.49, 0.49, 0.45, 0.47, 0.53, 0.51, 0.46, 0.42, 0.41, 0.32];
    clip_value_r = clip_values(GA-20);

elseif (clip_value>=0 && clip_value<=1)
    clip_value_r = clip_value; 

else
    error("Wrong clip value")

end
fprintf("Current clipping value: %f\n", clip_value_r)

% Apply the clipping value to the advantage/disadvantage values
map = clip_value_r*(2./(1 + exp((-2/clip_value_r)*map)) - 1);
new_map = map + 1; 

    
end