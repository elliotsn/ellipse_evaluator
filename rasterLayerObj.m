%
% Class for a raster layer object. Pixel registered.
% 
classdef rasterLayerObj
   
    properties(GetAccess = 'public', SetAccess = 'public')
       latvec;     % Vector of lat, aligned with y-axis.
       lonvec;     % Vector of lon, aligned with x-axis.
       latlims;    % [minlat, maxlat]
       lonlims;    % [minlon, maxlon] 
       xg;         % 2D array same size as im containing map-projected x coordinates.
       yg;         % 2D array same size as im containing map-projected y coordinates.
       xlims;      % I think you know.
       ylims;      % "
       fname;      % File name, without path.
       fpath;      % Path to the source file.
       fpathanc;   % Path to the ancillliary file.
       ftype;      % File type. Supported types are: img, tif, cub and 
       im;         % rows x columns 2d array of image.
       nodata;     % nodata value in this raster.
       zmin;       % Minimum non-nodata value
       zmax;       % Maximum non-nodata value
       threshmin;  % Minimum data value threshold input by user
       threshmax;  % Maximum data value threshold input by user
       R;          % 3x2 raster reference matrix in map units.
       invert;     % boolean dictating whether a layer's mask should be inverted or not.
       mask;       % A 2D boolean for this raster where pixels meet the constraints
       nx;         % Number of x pixels
       ny;         % Number of y pixels
       xlimsSubf;   % x  limits of a rectangular subframe in this layer.
       ylimsSubf;   % y  limits of a rectangular subframe in this layer.
       xPolySubf;  % Vector of x coordinates for points that draw a polygon of the subframe footprint
       yPolySubf;  % Vector of y coordinates for points that draw a polygon of the subframe footprint
       latlimsSubf; % Latitude limits of a rectangular subframe in this layer.
       lonlimsSubf; % Longitude limits of a rectangular subframe in this layer.
       xlimsIndSubf;  % Array element limits in x of subframe.
       ylimsIndSubf;  % Array element limits in y of subframe.
       xvIndsSubf;  % Vector of x array indices in im of the subframe.
       yvIndsSubf;  % Vector of y array indices in im of the subframe.
       areaSubf;    % Area for the cells contained in the subframe.
       xPolyFoot;   % x coordinates of polygon describing rectangular footprint of layer
       yPolyFoot;   % y coordinates of polygon describing rectangular footprint of layer
       mapunits;    % Name of map units as a string, 'm' or 'km'.
       lines;       % Number of samples (x)
       samples;     % Number of lines (y)
       
       % Map projection parameters for Equal Area Cylindrical.
       % Set here because no access to guidata in class.
       re;          % Mars equatorial radius in IAU2000. Used for equal area map projection.
       lat1;        % Latitude of standard parallel(s).
       lonO;        % Longitude of central meridian.
    end
    
    % Methods, including the constructor are defined in this block.
    methods

        % Constructor method.
        function obj = rasterLayerObj(fpath)
            
            % The image is stored so that map-projected coordinates align
            % with the x and y axes. A grid is therefore needed for
            % lat-lon. Because lines of lat and lon are not aligned with
            % the x and y axes.
            obj.latvec = [];     % Vector of lat. 
            obj.lonvec = [];     % Vector of lon. 
            obj.latlims = zeros(0,2);    
            obj.lonlims = zeros(0,2);
            obj.mapunits = '';
            obj.xg = [];        % Grid of map-projected x coordinates.
            obj.yg = [];        % Grid of map-projected y coordinates.
            obj.xlims = zeros(0,2);       % xlimits
            obj.ylims = zeros(0,2);       % ylimits
            obj.fpath = fpath;    % Path to the source file.
            obj.fpathanc = '';    % Path to the ancilliary file if there is one.
            obj.ftype = '';       % File type. Supported types are: img, tif, cub and 
            obj.im = [];          % image data
            obj.R = [];           % rows x columns 2d array of image.
            obj.nodata = [];      % nodata value
            obj.invert = 0;       % Set mask to normal.
            obj.mask = [];
            obj.nx = [];
            obj.ny = [];
            obj.xlimsSubf = zeros(0,2);
            obj.ylimsSubf = zeros(0,2);
            obj.latlimsSubf = zeros(0,2);
            obj.lonlimsSubf = zeros(0,2);
            obj.xlimsIndSubf = zeros(0,2);
            obj.ylimsIndSubf = zeros(0,2);
            obj.areaSubf = [];
            obj.lines = [];
            obj.samples = [];
            
            obj.re = 3396190;  % Mars equatorial radius in IAU2000. Used for equal area map projection.
            obj.lat1 = 0;      %       
            obj.lonO = 0;
            
            % Read the file and populate the properties
            
            % Check data file exists and has required ancilliary files.
            obj.fpath = fpath;
            obj.ftype = fpath(end-2:end);
            obj.fname = reverse(strtok(reverse(fpath),'/'));
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % We here switch to the appropriate section depending on what kind of raster 
            % the data are stored as.
            
            % The purpose of this switch block is to deal with a case for
            % each supported data format, and within each case, deal with
            % all map projections that the format is likely to occur in.
            % This could probably be coded more neatly for a general case,
            % but the subtleties of PDS labels and differences for each
            % dataset require case by case treatment.
            
            %% TIF + .tfw world file.
            % For any tif raster with a world file, we can only assume that
            % the coordinates in the world file are projected in the working map 
            % projection, lambert equal area cylindrical. There is no reason to assume
            % otherwise because no information on it's projection is stored
            % in the raster or world file, only map projected units.
            % It's also assumed the file is stored in map-units, and that map-units are metres.
            % This is true for tif+tfw, png+pgw and jpg+jpw. It's also
            % assumed that longitude is +/-180 and grid cells are
            % pixel-registered.
            
            %% .IMG + .LBL
            %  - MOLA MEGDRs stored in simple cylindrical.
            
            %% ISIS .cub
            % 
            % - SOCET SET produced cub files
            % For IMGs and ISIS cubs both the map scale (pixels degree^-1) and map
            % resolution (m pix^-1) are stored and the accompanying label
            % file (.lbl) should contain the required mapping parameters to
            % populate the parameters without making any assumptions.
            % Grid cells are pixel registered.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            goflag=true;
            switch lower(obj.ftype)
                
                %% .TIF + .TFW
                case 'tif'
                    % Check for world file.
                    obj.fpathanc = getworldfilename(obj.fpath);
                    if exist(obj.fpathanc,'file')

                        % Read the tif and world file.
                        [obj.im, x, y, obj.R] = readTifAndWorld(obj.fpath,obj.fpathanc);
                        % World files are inherently pixel registered.
                        % The 3x2 matrix R produces the transformation to map coordinates
                        % when multiplied by the matrix [x
                        %                                y
                        %                                1]
                        %
                        %R(1,1) % D - rotation about y-axis
                        %R(1,2) % A - x pixel size
                        %R(2,1) % E - y pixel size
                        %R(2,2) % B - rotation about x-axis
                        %R(3,1) % F - y coordinate of centre of UL pixel
                        %R(3,2) % C - x coordinate of centre of UL pixel
                        halfxres = abs(obj.R(1,2))/2;
                        halfyres = abs(obj.R(2,1))/2;
                        
                        units = 'deg';
                        obj.mapunits = 'm';
                        
                        % Depending on the units that the world file is in
                        % we populate both degree and map units properties.
                        switch units
                            case 'deg'
                                % The image and world file is stored in linear lat lon.
                                obj.lonvec = x(1,:);
                                obj.latvec = y(:,1);
                                % Pixel edges.
                                obj.latlims = [min(obj.latvec)-halfyres max(obj.latvec)+halfyres];
                                obj.lonlims = [min(obj.lonvec)-halfxres max(obj.lonvec)+halfxres];
                                
                            case 'm'
                                % Assume coordinates in world file are
                                % equirectangular meters, and that Mars
                                % equatorial radius is used.
                                [obj.latvec, obj.lonvec] = equirec2latlon(x(1,:), y(:,1), obj.re, obj.lat1, obj.lonO);
                                xlims = [min(x(1,:))-halfxres, max(x(1,:))+halfxres];
                                ylims = [min(y(:,1))-halfyres, max(y(:,1))+halfyres];
                                [obj.latlims, obj.ylims] = equirec2latlon(xlims, ylims, obj.re, obj.lat1, obj.lonO);
                        end
                        [obj.ny, obj.nx] = size(obj.im);
                    else
                        msgbox(['.tif files must have accompanying world files in same directory. ',fpathworld,' not found. Layer not loaded.'],'Warning','warn');
                        goflag = false;
                    end
                    
                % IMG + LBL
                case 'img'
                    
                    % Look for the label. Label path should be same as image path but 
                    % replacing last 3 chars with 'lbl', in same case as img, or default 
                    % to lower case if 'img' is mixed.
                    if isLower(obj.ftype)
                        piece = 'lbl';
                    else
                        piece = 'LBL';
                    end
                    obj.fpathanc = [obj.fpath(1:end-3), piece];
                    
                    % If it exists read it.
                    goflag = false;
                    if exist(obj.fpathanc, 'file') == 2
                        lbl = readPdsLbl(obj.fpathanc);
                        % Check the instrument ID exists
                        if isfield(lbl, 'instrument_id') && isfield(lbl,'image_map_projection') && isfield(lbl,'image')
                            if strcmpi(strRemoveQuotes(lbl.image_map_projection.map_projection_type),'SIMPLE CYLINDRICAL')
                                goflag = true;
                            end
                        end 
                    end
                        
                    if goflag
                        % Check instrument type (assumptions on data type, e.g. MOLA data is always MEGDRs).
                        switch lower(strRemoveQuotes(lbl.instrument_id))
                            case 'mola' % Assume this is a MEGDR
                                
                                % Read map coordinates. MEGDRs are stored in simple cylindrical, which means raster
                                % axes are linear in lat lon.
                                obj.latlims = [str2double(strtok(strtrim(lbl.image_map_projection.minimum_latitude))), str2double(strtok(strtrim(lbl.image_map_projection.maximum_latitude)))];
                                obj.lonlims = [str2double(strtok(strtrim(lbl.image_map_projection.westernmost_longitude))), str2double(strtok(strtrim(lbl.image_map_projection.easternmost_longitude)))];

                                % lat distance divided by pixels is same as distance between pixel centres.
                                latRes = diff(obj.latlims)/str2double(strRemoveQuotes(lbl.image.lines));
                                latResHalf = latRes/2;
                                lonRes = diff(obj.lonlims)/str2double(strRemoveQuotes(lbl.image.line_samples));
                                lonResHalf = lonRes/2;
                                
                                % Vectors of pixel centres. +ve is south,
                                % so latvec increases as y-pixel coordinate decreases.
                                obj.latvec = max(obj.latlims)-latResHalf:-latRes:min(obj.latlims)+latResHalf;
                                obj.lonvec = min(obj.lonlims)+lonResHalf:lonRes:max(obj.lonlims)-lonResHalf;
                                                                
                                % Read raster.
                                obj.ny = str2double(strRemoveQuotes(lbl.image.lines));
                                obj.nx = str2double(strRemoveQuotes(lbl.image.line_samples));
                                
                                endian = get_endian(lbl.image.sample_type);
                                precision = get_precision(lbl.image.sample_bits);  
                                
                                fid = fopen(obj.fpath, 'r', endian);
                                obj.im = fread(fid, [obj.nx, obj.ny], precision);
                                fclose(fid);
                                
                                % fread fills column-wise, so must transpose. 
                                obj.im = obj.im';
                            % case [other instrument]
                            
                            otherwise
                                msgbox('Unsupported file format. Data not loaded.','Warning','warn');
                                goflag = false;
                        end
                    else
                        msgbox('Unsupported file format. Data not loaded.','Warning','warn');
                        goflag = false;
                    end
                    
                case 'cub'
%%                  READ ISIS .cubs - HiRISE and CTX DEMs that are created using Socet Set.
                    
                    % Read using readIsisCub.
                    [label, dn, ~] = readIsisCub(fpath);
                    
                    % Set the nodata value based on the ISIS conventions.                    
                    % Name                                  32-bit          16-bit	8-bit   Monochrome
                    % NULL                                  -3.40282e+38    -32768	0       0
                    % Low Representation Saturation (LRS)	-3.40282e+38	-32767	0       black
                    % Low Instrument Saturation (LIS)	    -3.40282e+38	-32766	0       black
                    % High Instrument Saturation (HIS)   	-3.40282e+38	-32765	255     white
                    % High Representation Saturation (HRS)	-3.40282e+38	-32764	255     white
                    if isempty(label) || isempty(dn)
                        msgbox('Unable to read ISIS .cub file.','Warning','warn');
                        goflag = false;
                    else
                        try
                            [~, pixel_bytes] = get_precision(label.isiscube.core.pixels.type);    
                            switch pixel_bytes
                                case 1 % 8 bit
                                    null_dn = 0;
                                case 2 % 16 bit
                                    null_dn = -32768;
                                case 4 % 32 bit
                                     % This is how the value quoted by the USGS manifests in Matlab.
                                    null_dn = -340282265508890445205022487695511781376;
                                    % null_dn = -realmax('single'); Almost
                                    % the same as the above, but not quite.
                                    % Not sure why..
                                otherwise
                                    null_dn = [];
                            end
                            if isempty(null_dn)
                                % Assume entire core is usable.
                                mask = true(size(dn)); %#ok<*PROP>
                                % Throw an error to be caught.
                                error('');
                            else 
                                mask = ~(dn == null_dn);  % -3.4028227e+38   -3.4028235e+38
                            end
                            % Turn null values to NaN.
                            dn(~mask) = NaN;
                        catch
                            % Catches error if the pixel type is not a
                            % field in the label structure, or if precision
                            % is not in the acceptable list.
                            msgbox('Nodata value in .cub file could not be determined, assuming entire raster contains useable data.','Warning','warn');
                            goflag = false;
                        end
                        
                        % Convert the dn array to science values.
                        offset = str2double(label.isiscube.core.pixels.base);
                        scaling_factor = str2double(label.isiscube.core.pixels.multiplier);
                        obj.im = NaN(size(dn));
                        obj.im(mask) = (double(dn(mask)) * scaling_factor) + offset;
                        
                        % Got data, now get map projection.
                        
                        % Map coordinates stored in the 'mapping' group
                        % refer to the map-projected values for each pixel.
                        % However, the map projection that the cube is
                        % stored in may not be the same as the working
                        % projection.
                        
                        % Raster axes are aligned with map coordinate axes,
                        % so vectors of map-projected coordinates may be
                        % constructed along each edge. Knowing the
                        % projection to lat-lon transformation, lat-lon
                        % values are then calculated for each pixel. Which
                        % are then converted to the working projection,
                        % lambert equal area cylindrical.
                        
                        % So far we allow only for the equirectangular
                        % projection.
                        
                        % Work backwards from label...
                        % deg2rad(maximumlatitude)*equatorialradius = 470548.6285221893;
                        % upperleftcornery = 470549.30249585;
                        % 67.4cm different... curious.
                        
                        % Assuming Mars is a sphere of equatorial radius then 
                        % deg2rad(minimumlongitude-180) * equatorialradius = 9982352.637996323
                        % upperleftcornerx = 9982352.5339656
                        % 10.4 cm out, not bad - but not correct.
                        
                        % Attempting to account for the polar AND
                        % equatorial radii:
                        
                        % Radius as a function of latitude: 
                        % 
                        % f = abs(maximumlatitude)/90;
                        % R = f*polarradius + (1-f)*equatorialradius
                        % deg2rad(maximumlatitude)*R
                        % 470304.3316068953 - 470549.30249585 = -244.9708889547037
                        % 245 m out at 7 degrees latitude - much much
                        % worse!
                        % It's therefore likely that a biaxial ellipsoid is
                        % NOT used to calculate the map-projected
                        % coordinates. Instead the equatorial radius is
                        % probably used, and the few 10s of cm differences
                        % have an unknown cause.
                        
                        % Make lat-lon for supported projection, allowing for ographic or ocentric lat.
                        try
                            switch lower(label.isiscube.mapping.projectionname)
                                case 'equirectangular'
 
                                    % Vecs of map coords.
                                    xlims(1) = str2double(strRemoveQuotes(strtok(label.isiscube.mapping.upperleftcornerx)));
                                    ylims(2) = str2double(strRemoveQuotes(strtok(label.isiscube.mapping.upperleftcornery)));
                                    
                                    % Other ends are the pixel resolution *
                                    % number of pixels in each direction.
                                    mppix = str2double(strRemoveQuotes(strtok(label.isiscube.mapping.pixelresolution)));
                                    obj.nx = str2double(strRemoveQuotes(label.isiscube.core.dimensions.samples));
                                    obj.ny = str2double(strRemoveQuotes(label.isiscube.core.dimensions.lines));
                                    xlims(2) = xlims(1) + mppix*obj.nx;
                                    ylims(1) = ylims(2) - mppix*obj.ny;
                                    
                                    equireclonO=str2double(strRemoveQuotes(strtok(label.isiscube.mapping.centerlongitude)));
                                    equireclat1=str2double(strRemoveQuotes(strtok(label.isiscube.mapping.centerlatitude)));
                                    equatorialradius=str2double(strRemoveQuotes(strtok(label.isiscube.mapping.equatorialradius)));
                                    [obj.latlims, obj.lonlims] = equirec2latlon(xlims, ylims, equatorialradius, equireclat1, equireclonO);
                                    
                                    % Make lat-lon vectors.
                                    latres = diff(obj.latlims)/obj.ny;
                                    lonres = diff(obj.lonlims)/obj.nx;
                                    halflatres = latres/2;
                                    halflonres = lonres/2;
                                    obj.latvec = obj.latlims(1)+halflatres:latres:obj.latlims(2)-halflatres;
                                    obj.lonvec = obj.lonlims(1)+halflonres:lonres:obj.lonlims(2)-halflonres;
                                    
                                    % If latitude is ographic, convert to ocentric
                                    if strfind('ographic',lower(label.isiscube.mapping.latitudetype))
                                        polarradius = str2double(strRemoveQuotes(strtok(label.isiscube.mapping.polarradius)));
                                        obj.latvec = ographic2ocentricLat(obj.latvec, equatorialradius, polarradius);
                                        obj.latlims = ographic2ocentricLat(obj.latlims, equatorialradius, polarradius);
                                    end
                                    
                                otherwise
                                    msgbox('Unsupported map projection. Data not loaded.','Warning','warn');
                            end
                        catch
                            msgbox('Error reading ISIS cub file. Data not loaded.','Warning','warn');
                        end
 
                    end
                    
            end
            
            % If the data and lat lon was successfully extracted from the map projection
            % then populate the other properties: data and equal-area
            % coordinates.
            if goflag
        
                % Transform lat lon to Lambert Equal Area Cylindrical.
                % Raster limits.
                [obj.xlims, obj.ylims] = latlon2eqa(obj.latlims, obj.lonlims, obj.re, obj.lat1, obj.lonO);
                % In case map coord vectors are reversed, sort limits in ascending order.
                obj.xlims = sort(obj.xlims);
                obj.ylims = sort(obj.ylims);
                % Grids of eastings and northings
                [long, latg] = meshgrid(obj.lonvec, obj.latvec);
                [obj.xg, obj.yg] = latlon2eqa(latg,long,obj.re,obj.lat1,obj.lonO);
                clear latg long
                obj.mapunits = 'm';                
                
                % Core data properties
                obj.zmin = min(obj.im(:));
                obj.zmax = max(obj.im(:));
                obj.threshmin = obj.zmin;
                obj.threshmax = obj.zmax;

                % Vector of points making bounding box in this arrangement:  2 3
                % i.e. CW from lower left                                    1 4
                obj.xPolyFoot = [obj.xlims(1) obj.xlims(1) obj.xlims(2) obj.xlims(2)];
                obj.yPolyFoot = [obj.ylims(1) obj.ylims(2) obj.ylims(2) obj.ylims(1)];
            else
                obj = [];
            end
        end
 
        % Function to calculate the mask based on the thresholds entered.
        % Threshmin,max and invert must be set.
        function obj = calcMask(obj)
            obj.mask = obj.im >= obj.threshmin...
                & obj.im <  obj.threshmax;

            % If invert is selected, invert mask.
            if obj.invert == 1
                obj.mask = ~obj.mask;
            end
        end
        
        % Function to retrieve a subFrame from the raster using limits in xy coordinates.
        % If any limits are passed empty, subframe is the entire raster.
        function obj = getSubFramexy(obj,  minx, maxx, miny, maxy)
            
            if any(isempty([minx, maxx, miny, maxy]))
                obj.xlimsIndSubf = [1 obj.nx];
                obj.ylimsIndSubf = [1 obj.ny];
            else
                % getVecPointInd is an appropriate choice if we assume that
                % rasters are pixel registered. It returns the index of the
                % element closest to the point, which should be the pixel
                % that the point is in if the vector is always
                % ascending/descending.
                
                % Get indices in raster at boundaries
                obj.xlimsIndSubf(1) = getVecPointInd(obj.xg(1,:), minx); % left
                obj.xlimsIndSubf(2) = getVecPointInd(obj.xg(1,:), maxx); % right
                obj.ylimsIndSubf(1) = getVecPointInd(obj.yg(:,1), miny); % bottom
                obj.ylimsIndSubf(2) = getVecPointInd(obj.yg(:,1), maxy); % top
                % Correct order of subframe lims, in case map-coord vecs are
                % reversed.
                obj.xlimsIndSubf = sort(obj.xlimsIndSubf,'ascend');
                obj.ylimsIndSubf = sort(obj.ylimsIndSubf,'ascend');

            end
                
            % Temporary vectors to avoid having to make them twice.
            obj.xvIndsSubf = obj.xlimsIndSubf(1):obj.xlimsIndSubf(2);
            obj.yvIndsSubf = obj.ylimsIndSubf(1):obj.ylimsIndSubf(2);

            % xy limits of subframe % TODO make limits gridline registered.
            [obj.xlimsSubf, obj.ylimsSubf] = get2dlims(...
                obj.xg(obj.yvIndsSubf,obj.xvIndsSubf),...
                obj.yg(obj.yvIndsSubf,obj.xvIndsSubf));

            % Polygon of subframe footprint
            obj.xPolySubf = [obj.xlimsSubf(1) obj.xlimsSubf(1) obj.xlimsSubf(2) obj.xlimsSubf(2)];
            obj.yPolySubf = [obj.ylimsSubf(1) obj.ylimsSubf(2) obj.ylimsSubf(2) obj.ylimsSubf(2)];
            
        end
            
        % Function to return an array the same size as the subFrame
        % containing the area of each cell, assuming Lambert Equal Area Cylindrical.
        % Requires other fields to be populated. Assumes equal area coordinates that allow 
        % 2 distances in orthogonal directions to be multiplied to produce
        % numericall correct area.
        function obj = calcAreaSubFEqa(obj)
            
            % Coordinates for the sub-frame are stored as pixel registered.
            % Since we know the projection is Equal Area Cylindrical, we
            % can work out precise edge vectors for the pixels. Pixel area
            % is then multiplication of edge vectors.
            
            % Get vectors of cell length in x and y directions from latvec
            % and lonvecs of edges.
            halflonres = (obj.lonvec(2) - obj.lonvec(1))/2;
            halflatres = (obj.latvec(2) - obj.latvec(1))/2;
            
            lone = [obj.lonvec - halflonres, obj.lonvec(end) + halflonres];
            late = [obj.latvec - halflatres, obj.latvec(end) + halflatres];
            
            % Get eqa coords of cell edges
            [xe, ye] = latlon2eqa(late, lone, obj.re, obj.lat1, obj.lonO);
            
            % Get lengths of each cell edge, allowing for map coordinate
            % vectors in both directions.
            xl = abs(diff(xe));
            yl = abs(diff(ye));
            
            % Make grids of subFrame pixel side lengths, without using
            % significant memory. Go down 1 dimension.
            obj.areaSubf  = zeros(size(obj.im));
            
            for iy = 1:obj.ny
                obj.areaSubf(iy,:) = yl(iy).*xl;
            end
            
        end

    end
end
