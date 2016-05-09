%
% Convert to lat lon to x and y coordinates in equirectangular.
%
% Inputs:
%   x - equirectangular x coordinate
%   y - equirectangular y coordinate
%   r - planetary radius   
%   lat1 - latitude of standard parallel (latitude of true scale)
%   lonO - center longitude of projection, origin.
%
%   For Plate Carrée lat1=0 & lon0=0
%
% Outputs:
%   lat,lon
%
% Author: Elliot Sefton-Nash    Date: 20160209
%
function [lat, lon] = equirec2latlon(x, y, r, lat1, lonO)
    lat = rad2deg(y/r);
    lon = mod(lonO + rad2deg(x/r/cosd(lat1)), 360);
end