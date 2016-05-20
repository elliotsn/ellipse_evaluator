%
% Find the limits of the most eastward, westward, northward and southward
% ellipses placed at the corners of the grid object passed.
%
% Inputs:
%   ellipse - ellipse object to place at the corners of the grid
%   grid    - grid Object
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
%   x,y - polygon of union shape. Rectangle is the simple way, union of
%         polygons is the thorough way.
%
%  Copyright 2016  Elliot Sefton-Nash
function [x, y] = getEllipseExtentOnGrid(ellipse, grid, re, lat1, lonO)

    % Figure out how many ellipses are along the edges, if this is above
    % the threshold then just evaluate the corners to the find the extremes
    % and don't return an outline polygon in x and y.
    ellThresh = getEllipseDrawThresh();
    % Number of ellipses on perimeter of grid
    nEllipses = (grid.nx*2 + (grid.ny-2)*2);
    
	if nEllipses > ellThresh
        fast = 1;
        % Fast way, just corners.
        [xc, yc] = boundingRect(grid.xgc(:), grid.ygc(:));
    else
        fast = 0;
        % Thorough way, every ellipse on the perimiter of the grid.
        xc = arr2DEdge(grid.xgc);
        yc = arr2DEdge(grid.ygc);
    end

    % Assumption that yc is same length
    np = numel(xc);
    xCumu = [];
	yCumu = [];
    
    for i=1:np
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

        % Make sure CW
        [elx, ely] = poly2cw(elx, ely);
        % Add this ellipse to the cumulative outline.
        [xCumu, yCumu] = polybool('union',xCumu,yCumu,elx,ely);
    end
    
    % Just return a rectangle from spatial extremes of corner ellipses.
    if fast
        [x, y] = boundingRect(xCumu, yCumu);
    else
        x = xCumu; y = yCumu;
    end
end