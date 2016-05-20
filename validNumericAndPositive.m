% Function to validate a numeric value of a string. Built on validNumeric
% but constrains to positive real numbers.
% Returns a double that is either empty or full.
%
%  Copyright 2016  Elliot Sefton-Nash
function out = validNumericAndPositive(s)
    out = validNumeric(s);
    if out <= 0
        out = [];
    end
end