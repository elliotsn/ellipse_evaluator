%
% Class for a grid in linear lat lon space with properties to also hold map-projected 
% coordinates.
% grd used as name because 'grid' already taken.
% 
classdef grdObj
   
    properties(GetAccess = 'public', SetAccess = 'public')
        
        % Future development: In this class we have grid variables only for one coordinate
        % system, but in the future it may be desirable to have a class
        % that can hold linear vectors of x and y or lat lon that are aligned with grid 
        % axes and grid versions of the other.
        
        xlims;   % x extents
        ylims;   % y extents
        ncells;  % number of grid cells
        nx;      % width of grid in cells
        ny;      % height of grid in cells
        xgc;     % Grid center x coord
        ygc;     % Grid center y coord
        
        latr;    % Resolution in latitude
        lonr;    % Resolution in longitude
        lone;    % Longitude edges
        late;    % Latitude edges
        latc;    % Latitude centres
        lonc;    % Longitude centres
        latlims;
        lonlims;
    end
    
    % Methods, including the constructor are defined in this block.
    methods
        % Constructor method, linear vectors of lat and lon pixel centers are passed.
        function obj = grdObj(lonc,latc)
            if isempty(latc) || isempty(lonc)
                % For invalid grids return an empty cell array.
                obj = {};
            else
                obj.latc = latc;
                obj.lonc = lonc;

                % If not scalars, edges must be monotonic ascending.
                [obj.late, obj.latr] = getVecEdgeAndRes(obj.latc);
                [obj.lone, obj.lonr] = getVecEdgeAndRes(obj.lonc);
                
                [obj.latlims, obj.lonlims] = get2dlims(obj.late,obj.lone);
                
                obj.nx = numel(obj.lonc);
                obj.ny = numel(obj.latc);
                
                obj.ncells = obj.nx*obj.ny; % number of grid cells
            end 
        end
            
        % Function to calculate map projected x y coordinates in cylindrical equal area 
        % projection and populate relevant map properties.
        %
        % Inputs:
        %   lat1 - latitude of first standard parallel
        %   lonO - longitude of origin
        %      r - radius of spherical body in map-units.
        function obj = getEqaXYFromLatLon(obj ,r,lat1,lonO)
            % Grid of lat lon.
            [long, latg] = meshgrid(obj.lonc, obj.latc);
            [obj.xgc, obj.ygc] = latlon2eqa(latg,long,r,lat1,lonO);
            % x and y coords of corners defined by latlims and lonlims
            lattmp = [obj.latlims(1) obj.latlims(2) obj.latlims(2) obj.latlims(1)];
            lontmp = [obj.lonlims(1) obj.lonlims(1) obj.lonlims(2) obj.lonlims(2)];
            [xtmp, ytmp] = latlon2eqa(lattmp,lontmp,r,lat1,lonO);
            obj.xlims = [min(xtmp) max(xtmp)];
            obj.ylims = [min(ytmp) max(ytmp)];
        end
    end
end
