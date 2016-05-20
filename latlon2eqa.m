%
% Convert lat,lon to Lambert Cylindrical Equal Area (Spherical)
%   lat  - latitude in degrees
%   lon  - longitude in degrees
%   r    - radius of planetary body (assumed to be sphere)
%   lat1 - latitude of first standard parallel in degrees
%   lonO - longitude of origin in degrees
%
%  Copyright 2016  Elliot Sefton-Nash
function [easting, northing] = latlon2eqa(lat,lon,r,lat1,lonO)
    
    lat = deg2rad(lat);
    lon = deg2rad(lon);
    lat1 = deg2rad(lat1);
    lonO = deg2rad(lonO);
    
    easting  = r.*(lon - lonO).*cos(lat1);
    northing = r.*sin(lat)./cos(lat1);