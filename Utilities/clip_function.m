function map = clip_function(map,clip_value,type_of_function, GA)

if nargin < 4
    error('Missing input(s).');
elseif nargin > 4
    error('Too many inputs!');
end

if isequal(clip_value,'adapt')
    %clip_values = [0.25, 0.28, 0.33, 0.4, 0.45, 0.48, 0.47, 0.49, 0.49, 0.49, 0.45, 0.47, 0.53, 0.51, 0.46, 0.42, 0.41, 0.32];
    clip_values = [0.2, 0.23, 0.26, 0.32, 0.36, 0.38, 0.37, 0.39, 0.39, 0.39, 0.36, 0.37, 0.43, 0.4, 0.37, 0.33, 0.32, 0.26];
    clip_value_r = clip_values(GA-20);

elseif (clip_value>=0 && clip_value<=1)
    clip_value_r = clip_value; 

else
    error("Wrong clip value")

end
fprintf("Current clipping value: %f\n", clip_value_r)

if isequal(type_of_function,'hard')
    map(map>clip_value_r ) = clip_value_r;
    map(map<(-1)*clip_value_r) = (-1)*clip_value_r;
    map = map + 1; 
	
elseif isequal(type_of_function,'sigmoid')
    map = clip_value_r*(2./(1 + exp((-2/clip_value_r)*map)) - 1);
    map = map + 1; 

else
    error("Wrong type of clipping function")
    
end