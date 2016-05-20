% Function to validate and return a string and a value for 0-360 longitude.
%
%  Copyright 2016  Elliot Sefton-Nash
function [s, v] = validLon(s)
    v = validNumeric(s);
    if isempty(v)
        s = '';
    else
        if v >= 360 || v < 0
            v = mod(v, 360);
        end
        s = num2str(v); % Do anyway to remove untidiness, e.g. tailing decimal point.
    end
end