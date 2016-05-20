%
% Find the coordinate extremeties of a set of ellipses, drawn according to
% the properties in the ellipse object passed, but with one ellipse drawn
% for each azimuth in azvec.
%
% Inputs:
%   ellipse - ellipse object to place at the corners of the grid
%   azvec   - vector of azimuths at which to draw ellipses, in radians.
%
%  -The following arguments may be passed if the lat-lon of the grid
%   coordinates is required. The grid must be accordingly defined in lat-lon.
%   If map-projected coordinates are required, then these values may be
%   passed as empty, [].
%   re      - equatorial radius
%   lat1    - latitude of standard parallel
%   lonO    - longitude of prime meridian of projection
%
% Outputs:
%   x,y - vectors of polygon coordinates for union shape.
%
%  Copyright 2016  Elliot Sefton-Nash
function [x, y] = getEllipseExtentAz(ellipse, azvec, re, lat1, lonO)

    naz = numel(azvec);
    x = [];
    y = [];
    for i=1:naz
        ell = ellipseObj(ellipse.xa, ellipse.ya, azvec(i),...
                ellipse.angRes, ellipse.xc, ellipse.yc);
  
        % If the map projection parameters are not passed empty then we
        % require the coordinates to be returned as lat-lon. For this to
        % work we need to know the map-projection parameters for the
        % inverse transform from equal area to lat-lon.
        if ~isempty(lat1) && ~isempty(lonO) && ~isempty(re)
            ell = ell.getLatLonFromEqaXY(re,lat1,lonO);
            elx = ell.lon;
            ely = ell.lat;
        else
            elx = ell.x;
            ely = ell.y;
        end
        
        % Make sure CW
        [elx, ely] = poly2cw(elx, ely);
        % Add this ellipse to the cumulative outline.
        [x, y] = polybool('union',x,y,elx,ely);
    end
end