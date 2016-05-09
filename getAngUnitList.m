% Returns two cell arrays of strings an an array of reals. Label contains short strings 
% for use in list boxes. desc contains the description of the unit. mult is
% a vector of factors to convert each unit into radians.
function [label, desc, mult] = getAngUnitList()
    label = {'deg', 'rad', 'mrad'};
    desc = {'Degrees', 'Radians', 'Milliradians'};
    % Factors to convert units into radians.
    mult = [pi/180 1 1e-3];
end