% Function to determine if a vector of azimuths in radians is valid and return it if
% so. f is the factor required to convert the azimuths to radians.
%
%  Copyright 2016  Elliot Sefton-Nash
function azVec = validAzVec(minAz,stepAz,maxAz,f)

    % Make a vector of azimuths.
    % TODO - Check for cases where 0 phase is crossed, this is still valid.
    azVec = f.*(minAz:stepAz:maxAz);
end