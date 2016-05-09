%
% Find the limits of the most eastward, westward, northward and southward
% ellipses placed at the corners of the grid object passed.
%
% Inputs:
%   ellipse - ellipse object to place at the corners of the grid
%   xvc     - xcoordinates of ellipse centre
%   yvc     - ycoordinates of ellipse centre
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
% Date   : 20160113
%
function [mingrdx, maxgrdx, mingrdy, maxgrdy] = getEllipseExtentOnGridFast(ellipse, xvc, yvc,...
    re, lat1, lonO)

    xlims = [min(xvc) max(xvc)];
    ylims = [min(yvc) max(yvc)];
    %     UL       UR       LR       LL
    xc = [xlims(1) xlims(2) xlims(2) xlims(1)];
    yc = [ylims(2) ylims(2) ylims(1) ylims(1)];
    for i=1:4
        ell = ellipseObj(ellipse.xa, ellipse.ya, ellipse.azimuth,...
                ellipse.angRes, xc(i), yc(i));
  
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