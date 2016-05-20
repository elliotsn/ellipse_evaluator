% Function to validate a numeric value of a string. Let str2double do the hard
% work in figuring if something is a valid number format or not.
% Returns a double that is either empty or full.
%
%  Copyright 2016  Elliot Sefton-Nash
function sout = validNumeric(s)
    sout = str2double(s);
    if isempty(sout) || isnan(sout)
        sout = [];
    end
end