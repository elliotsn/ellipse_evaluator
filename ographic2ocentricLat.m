%
% Function to convert an ographic latitude in degrees to an ocentric one in
% degrees.
%
% ographicLat - latitude in degrees
% radiusE     - equatorial radius
% radiusP     - polar radius
%
% Elliot Sefton-Nash 03/02/2016
function ocentricLat = ographic2ocentricLat(ographicLat,radiusE,radiusP)
    % Doesn't correct for phase, just return original if outside bounds.
    if abs(ographicLat) < 90
        ocentricLat = atand(tand(ographicLat).*(radiusE/radiusP)^2);
    else
        ocentricLat = ographicLat;
    end
end