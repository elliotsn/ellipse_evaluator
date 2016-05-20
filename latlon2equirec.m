%
% Convert to lat lon to x and y coordinates in equirectangular.
%
% Inputs:
%   lat,lon
%   r - planetary radius   
%   lat1 - latitude of standard parallel (latitude of true scale)
%   lon0 - center longitude of projection
%
%   For plate carree lat1=0 & lon0=0
%
% Outputs:
%   x - equirectangular x coordinate
%   y - equirectangular y coordinate
%
%  Copyright 2016  Elliot Sefton-Nash
function [x, y] = latlon2equirec(lat, lon, r, lat1, lon0)
    x = r*deg2rad(lon-lon0)*cosd(lat1);
    y = r*deg2rad(lat);
end