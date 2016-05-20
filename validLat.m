% Function to validate and return a string and a value for -90 to 90
% latitude passed as a string.
%
%  Copyright 2016  Elliot Sefton-Nash
function [s, v] = validLat(s)
    v = mod(validNumeric(s)+90, 180)-90;
    if isempty(v)
        s = '';
    elseif v > 90 || v < -90
        v = 0; s='0';
	end
end