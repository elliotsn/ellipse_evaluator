%
% Class for a polygon.
% 
%  Copyright 2016  Elliot Sefton-Nash
classdef polyObj
   
    properties(GetAccess = 'public', SetAccess = 'public')
       x;   % Vector of x coordinates of vertices.
       y;   % Vector of y coordinates of vertices.
       lat; % Vector of latitude coordinates of vertices.
       lon; % Vector of longitude coordinates of vertices.
       nvertices; % Number of vertices
       xc;  % x - Coordinate of centroid
       yc;  % y - Coordinate of centroid
       latc; % latitude of centroid
       lonc; % longitude of centroid
       areaPoly;  % Area of polygon
    end
    
    % Methods, including the constructor are defined in this block.
    methods
        
        function obj = polyObj(shp)
            
            % If this is not empty, then shp contains a structure
            % containing a single polygon as returned by shaperead.
            if ~isempty(shp)
                if strcmpi(shp.Geometry,'polygon')
                    obj.nvertices = numel(shp.X);
                    % Last vertex is NaN, polygon must be at least a triangle.
                    if obj.nvertices < 4
                        obj = [];
                        return
                    end
                    obj.x = shp.X;
                    obj.y = shp.Y;
                    %obj.xc = shp.Xcenter;
                    %obj.yc = shp.Ycenter;
                    % Typically the last element of polygon
                    % vertices is NaN, ignore those.
                    obj.areaPoly = polyarea(shp.X(1:end-1), shp.Y(1:end-1));
                else
                    obj = [];
                end
            else    
                obj = [];
            end
        end
        
        % Function to calculate lat-lon coordinates for the vertices 
        % assuming that the xy coordinates that describe the polygon are 
        % equal-area cylindrical coordinates.
        %
        % Inputs:
        %   lat1 - latitude of first standard parallel
        %   lonO - longitude of origin
        %      r - radius of spherical body in map-units.
        function obj = getLatLonFromEqaXY(obj ,r,lat1,lonO)
            fe=0; fn=0;
            [obj.lonc, obj.latc] = eqa2latlon(obj.xc,obj.yc,fe,fn,r,lat1,lonO);
            [obj.lon, obj.lat] = eqa2latlon(obj.x,obj.y,fe,fn,r,lat1,lonO);
        end
        
    end
end
