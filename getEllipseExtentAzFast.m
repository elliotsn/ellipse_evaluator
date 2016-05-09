%
% Find the coordinate extremeties of a set of ellipses, drawn according to
% the properties in the ellipse object passed, but with one ellipse drawn
% for each azimuth in azvec.
%
% Inputs:
%   ellipse - ellipse object to place at the corners of the grid
%   azvec   - vector of azimuths at which to draw ellipses
%
%  -The following arguments may be passed if the lat-lon of the grid
%   coordinates is required. The grid must be accordingly defined in lat-lon.
%   If map-projected coordinates are required, then these values may be
%   passed as empty, [].
%   re      - equatorial radius
%   lat1    - latitude of standard parallel
%   lonO    - longitude of prime meridian of projection
%
% Author : Elliot Sefton-Nash
% Date   : 20160502
%
function [mingrdx, maxgrdx, mingrdy, maxgrdy] = getEllipseExtentAzFast(...
    ellipse, azvec, re, lat1, lonO)

    naz = numel(azvec);
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
            
        minelx = min(elx);
        maxelx = max(elx);
        minely = min(ely);
        maxely = max(ely);
        if i == 1
            mingrdx = minelx;
            maxgrdx = maxelx;
            mingrdy = minely;
            maxgrdy = maxely;
        else
            % Test if this ellipse has more extreme extremes than current
            % limits. If so, set new limit.
            if minelx < mingrdx
                mingrdx = minelx;
            end
            if maxelx > maxgrdx
                maxgrdx = maxelx;
            end
            if minely < mingrdy
                mingrdy = minely;
            end
            if maxely > maxgrdy
                maxgrdy = maxely;
            end
        end
    end 
end