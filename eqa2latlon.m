%
% Convert Lambert Cylindrical Equal Area x,y to lat,lon
%
% Inputs:
%   r    - radius of planetary body (assumed to be sphere)
%   lat1 - latitude of first standard parallel
%   lonO - longitude of origin
%   fn   - false northing
%   fe   - false easting
%   easting - x coordinate
%   northing - y coordinate
%
% Outputs:
%   lon  - longitude in degrees.
%   lat  - latitude in degrees.
%
%  Copyright 2016  Elliot Sefton-Nash
function [lon, lat] = eqa2latlon(easting,northing,fe,fn,r,lat1,lonO)
    
    lat1 = deg2rad(lat1);
    lonO = deg2rad(lonO);

    % We must correct for phase. Normally we could just do this after
    % lat-lon have been calculated. For lon we do this, but for lat the
    % arcsine returns a complex answer if ~[-1 <
    % ((northing-fn)./r).*cos(lat1) < 1]. So we need to do something more
    % clever.
    y = ((northing-fn)./r).*cos(lat1); % tmp must be -1 to 1.
    
    % Find where y coords are outside the grid.
    mask = y > 1 | y < -1;
    
    % The following function is eqaul to either -1 or 1. It corrects the sign of
    % coordinates when they cross a pole, i.e. the y-coord doesn't invert
    % instead it, e.g. after crossing the north pole, stays n the N. hemisphere but 
    % descends on the other side. So we must also invert the longitude.
    %%%  floor(mod((x-1)/2,2))-.5)*2
    
    % This function constrains the value of the y-coord to the domain -1 to 1
    %%%  mod(tmp(mask)-1,2)-1
    
    % By multiplying the two we constrain y-coordinates to one phase.
    y(mask) = (mod(y(mask)-1,2)-1) .* (floor(mod((y(mask)-1)/2,2))-.5)*2;
    lat = rad2deg( asin(y) );
    
    
    lon = rad2deg( (easting-fe)./(r*cos(lat1)) + lonO );
    % Invert longitude for points that have crossed a pole.
    lon(mask) = lon(mask) + 180;
    % Longitude is easier to correct for phase.
    lon = mod(lon, 360);