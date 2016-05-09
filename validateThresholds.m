%
% Function to validate a numeric value of a string. Let str2double do the hard
% work in figuring if something is a valid number format or not.
%
function sout = validNumeric(s)
    t = str2double(s);
    if isempty(t)
        sout = '';
    else
        sout = t;
    end
end