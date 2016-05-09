%
% Class for an ellipse.
% 
classdef ellipseObj
   
    properties(GetAccess = 'public', SetAccess = 'public')
       x;   % Vector of x coordinates of ellipse vertices.
       y;   % Vector of y coordinates of ellipse vertices.
       lat; % Vector of latitude coordinates of ellipse vertices.
       lon; % Vector of longitude coordinates of ellipse vertices.
       azimuth;  % Rotation of ellipse in CCW direction from +ve y-axis in radians.
       azimuthd; % Rotation of ellipse in CCW direction from +ve y-axis in degrees.
       majoraxis; % In metres
       minoraxis; % In metres
       semimajoraxis; % In metres
       semiminoraxis; % In metres
       nvertices; % Number of vertices
       eccentricity;
       xa;  % Original x-axis length passed to create ellipse
       ya;  % Original y-axis length passed to create ellipse
       xc;  % x - Coordinate of centroid
       yc;  % y - Coordinate of centroid
       latc; % latitude of centroid
       lonc; % longitude of centroid
       angRes;  % Angular resolution of vertices around origin in radians.
       areaTrue;  % Area of ellipse of the dimensions specified.
       areaPoly;  % Area of polygon: undersamples area of true ellipse.
    end
    
    % Methods, including the constructor are defined in this block.
    methods
        % Constructor method.
        % angRes must be in radians.
        function obj = ellipseObj(xa,ya,r,angRes,xc,yc)
            [obj.x, obj.y] = getEllipseVertices(xa,ya,r,angRes);
            obj.xa = xa;
            obj.ya = ya;
            obj.angRes = angRes;
            obj.xc = xc;
            obj.yc = yc;
            obj.x = obj.x + obj.xc;
            obj.y = obj.y + obj.yc;
            % Note that maj and minor axes are not tied to either x or y,
            % hence obj.xa and obj.ya are required to be stored.
            obj.majoraxis = max([xa ya]);
            obj.minoraxis = min([xa ya]);
            obj.nvertices = numel(obj.x);
            obj.azimuthd = r*180/pi;
            obj.azimuth = r;
            obj.semimajoraxis = obj.majoraxis/2;
            obj.semiminoraxis = obj.minoraxis/2;
            obj.eccentricity = sqrt(1 - obj.semiminoraxis^2/obj.semimajoraxis^2);
            obj.areaTrue = pi*xa*ya;  % True area, calculated using ellipse formula. Assumes flat ellipse projected onto surface.
            obj.areaPoly = polyarea(obj.x, obj.y); % Area of the polygon that approximates the ellipse.
        end
        
        % Function to calculate lat-lon coordinates for the ellipse assuming that the 
        % xy coordinates that describe the ellipse are equal-area cylindrical coordinates.
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
