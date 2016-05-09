%
% Class for results.
% 
classdef resultObj
   
    properties(GetAccess = 'public', SetAccess = 'public')
    
        % Note that DIMS is an ND array containing the dimensions of the
        % results over which ellipses were evaulated. For 2 spatial
        % dimensions DIMS is [grid.nx grid.ny]. For one dimension DIMS is
        % simply a vector of azimiuth values.
        
        % Array of size nlayers x DIMS. 
        % For placement of an ellipse centre at (x,y), 
        % ellLayerFrac(x,y) is the fraction of the ellipse
        % that is covered by the layer. This can be used as a
        % metric of confidence, for example to show that even
        % though 50% of the ellipse is true for some layer,
        % only 50% of the ellipse is covered by the layer, so
        % there is 50% area within the ellipse with no data coverage, 
        % where it is unknown if the layer meets the
        % constraints or not.
        ellLayerFrac;

        % Array of size nlayers x DIMS, i.e. one slice for each 
        % layer. It contains the fraction of the ellipse at each point in
        % parameter space that meets the constraints for each layer.           
        ellLayerTrueFrac;

        % Array the same size as DIMS. E.g. for placement of the ellipse
        % centre at (x,y), ellTrueFrac(x,y) is the fraction of all pixels 
        % in all layers that meet the defined numeric constraints 
        % AND are within the ellipse. This is a sum of
        % ellLayerTrueFrac down the layer dimension.
        ellTrueFrac;

        grid; % Grid object used for this evaluation (grdObj.m). Empty if 
              % results are evaluated over an azimuth vector.
        azvec; % Vector of azimuths over which this ellipse is evaluated 
               % (radians). Empty array if results are calculated over a 
               % grid object.
        azvecd; % (degrees)
        ellipse % Ellipse object used for this evaluation (ellipseObj.m).
        
        lfname; % Cell array of layer file names.
        lfpath; % Cell array of file paths.
    end
    
    
    % Methods, including the constructor are defined in this block.
    methods
        
        % Constructor method.
        function obj = resultObj(ellipse, grid, azvec, ellLayerFrac,...
                ellLayerTrueFrac, ellTrueFrac, lfname, lfpath)
            obj.ellipse = ellipse;
            obj.grid = grid;
            obj.azvec = azvec;
            % Get azvec in degrees, for ease of plotting.
            [label, ~, mult] = getAngUnitList();
            obj.azvecd = obj.azvec/mult(find(strcmpi(label,'deg')));
            obj.ellLayerFrac = ellLayerFrac;
            obj.ellLayerTrueFrac = ellLayerTrueFrac;
            obj.ellTrueFrac = ellTrueFrac;
            obj.lfname = lfname;
            obj.lfpath = lfpath;
        end
        
        % Method to write the results package according to the required
        % format.
        function success = write(obj, fmt, fpath)
            
            switch fmt
                case 'tif'
                    
                    % Write a tiff+tfw, this functionality means we don't
                    % need the mapping toolbox (geotiffwrite would
                    % otherwise be used).
                    %imwrite(
                    
                    
                    % Write the bsq file.
                    multibandwrite(im, bsqfpath, 'bsq', 'machfmt', 'ieee-be', 'precision', 'uint8');

                    % Get params for header and write header file, assuming equidistant
                    % cylindrical and that latvec and lonvec represent the lower left of
                    % pixels.

                    % Get upper left of map in plate carree, assumes east longitude.
                    [xmap, ymap] = latlon2platecaree(latvec, lonvec, rp);
                    ulxmap = min(xmap);
                    ulymap = max(ymap);

                    % Pixel size in plate carree, based on average max,min difference
                    s = size(im);
                    ydim = mean(diff(ymap));
                    xdim = mean(diff(xmap));

                    %% Write header file
                    % Open the ASCII file for writing
                    hdrfpath= [bsqfpath(1:end-3), 'hdr'];
                    fid = fopen(hdrfpath, 'w');

                    % Write the values.
                    fprintf(fid, ['nrows ', num2str(s(1)), ' \n']);
                    fprintf(fid, ['ncols ', num2str(s(2)), ' \n']);
                    fprintf(fid, 'nbands 1\n');
                    fprintf(fid, 'byteorder M\n');
                    fprintf(fid, 'layout bsq\n');
                    fprintf(fid, 'nbits 8\n');
                    fprintf(fid, ['xdim ', num2str(xdim),'\n']); % dimensions of pixels in map units
                    fprintf(fid, ['ydim ', num2str(ydim),'\n']);
                    fprintf(fid, ['ulxmap ', num2str(ulxmap), '\n']);
                    fprintf(fid, ['ulymap ', num2str(ulymap), '\n']);

                    fclose(fid);
                    
                    
                    
                    
                case 'png'
                    
                case 'jpg'
                        
                case 'jp2'
                    
                case 'bsq'
                    [~, ~] = writeGeoBsq(latvec, lonvec, im, fpath, rp);
                    
                    
            end
            
        end
        
        
    end
end
