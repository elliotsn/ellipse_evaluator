%
% Function to evaluate the total true pixels (those that meet the
% threshold specification) inside an ellipse object, evaluated where the
% ellipse centre is systematically placed at the center of each pixel in a grid object.
%
% Area covered does not consider partial pixels. Uncertainty in the value
% of p is therefore larger when pixel sizes in layers are larger relative to the
% ellipse.
%
% Whether a pixel is within the ellipse or not is determined by determining
% if the pixel centre lies within the ellipse boundary.
%
% Inputs:
%   ellipse - ellipse object (ellipseObj.m)
%   grid    - grid object (grdObj.m)
%   layers  - cell array of rasterLayer objects (rasterLayerObj.m)
%   waitbar - boolean that is true if a progress bar is desired. The
%             progress bar has a cancel button.
%
% Outputs:
%   result  - a result object that contains result arrays, grid, ellipse and other 
%             variables used for this evaluation.

%   Importantly:  
%
%     result.ellLayerFrac - Array of size [nlayers grid.nx grid.ny], i.e. one slice
%                           for each layer. For placement of an ellipse centre at (x,y), 
%                           ellLayerFrac(x,y) is the fraction of the ellipse
%                           that is covered by the layer. This can be used as a
%                           metric of confidence, for example to show that even
%                           though 50% of the ellipse is true for some layer,
%                           only 50% of the ellipse is covered by the layer, so
%                           there is 50% area within the ellipse with no data coverage, 
%                           where it is unknown if the layer meets the
%                           constraints or not.
%                 
%     result.ellLayerTrueFrac  - Array of size [nlayers grid.nx grid.ny], i.e. one slice
%                                for each layer. It contains the fraction of the ellipse
%                                placed at x,y that meets the constraints
%                                for each layer.
%
%     result.ellTrueFrac - Array the same size as grid. For placement of the ellipse
%                          centre at (x,y), ellTrueFrac(x,y) is the fraction of all pixels 
%                          in all layers that meet the defined numeric constraints 
%                          AND are within the ellipse. This is a sum of
%                          ellLayerTrueFrac down the layer dimension.
%
% Author : Elliot Sefton-Nash
% Date   : 20151209
%
function result = evaluateXYCore(ellipse, grid, layers, wb)

    if wb
        hWb = waitbar(0,'Initialising...',...
            'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
        setappdata(hWb,'canceling',0)
    end

    % Make a boolean mask for each layer where values are for true for
    % pixels inside the specified threshold. Method in rasterLayer class.
    nlayers = numel(layers);
    for i = 1:nlayers
        layers{i} = layers{i}.calcMask();
    end
    
    % For each layer, select only the sub-frame that includes all the
    % positions of the ellipse for this optimization. Exclude all pixels outside the 
    % rectangular region that include the ellipse extremes in the x & y
    % direction. This will dramatically reduce the processing time
    % occupied by inpolygon.
    
    if wb
        waitbar(0, hWb, 'Calculating work area...');
    end
    
    % Get extent in lat lon of ellipse grid. Make some
    % vectors that define the corners of the grid in
    % map coordinates. Note that these properties must have already been
    % populated outside of this function.
    grdcornerx = [grid.xlims(1) grid.xlims(1) grid.xlims(2) grid.xlims(2)];
    grdcornery = [grid.ylims(1) grid.ylims(2) grid.ylims(2) grid.ylims(1)];

    % Find extent of corner ellipses (spatial extremes)
    % in map coords.   
    [xEllPoly, yEllPoly] = getEllipseExtentOnGrid(ellipse,...
        grid, [],[],[]);
    
    if wb
        waitbar(0, hWb, 'Extracting work area from layers...');
    end
    
    % Find the subframe in each raster layer that all possible ellipses in this 
    % optimization intersect with.
    layerMask = true(1,nlayers);
    
    % Polygon of rectangular work area.
    % Vector of points making bounding box in this arrangement:  2 3
    % i.e. CW from lower left                                    1 4    
    [xPolyWorkArea, yPolyWorkArea] = boundingRect(xEllPoly, yEllPoly);
    
    for il = 1:nlayers
        
        % Note this assumes that xvec and yvec are pixel registered, not
        % gridline registered. maxgrd[x|y] are discrete locations that define the ellipse 
        % edge, not pixels.
        
        % Find the intersection of the work area and the layer footprint.
        
        % If there is no intersection of the work area with this
        % layer then two empty arrays are returned. Exclude this layer.
        [xInt, ~] = polybool('intersection',...
                                          xPolyWorkArea, yPolyWorkArea,...
                                   layers{il}.xPolyFoot, layers{il}.yPolyFoot);

        % If xInt is empty then yInt must be. We don't even get yInt from polybool.
        if isempty(xInt)
            layerMask(il) = false;
        else
            
            % Define a subframe of the raster based on the grid limits
            % found. A rasterObj's getSubFrame() method populates the appropriate
            % properties.
            layers{il} = layers{il}.getSubFramexy(...
                min(xPolyWorkArea(:)), max(xPolyWorkArea(:)),...
                min(yPolyWorkArea(:)), max(yPolyWorkArea(:)));
                  
            % Calculate the precise area of each pixel in the subFrame
            layers{il} = layers{il}.calcAreaSubFEqa();
        end
    end
    
    %% Setup output variables

    % The following 2 arrays are of dimensions: nlayers x grid.nx x grid.ny
    
    % The fractional area of the ellipse placed at this pixel centre that is covered by 
    % the layer. Essentially this is a measure of significance of the results, as it
    % shows the proportion of the ellipse in which data was included.
    ellLayerFrac = zeros(nlayers, grid.nx, grid.ny);
    
    % The fraction of the ellipse in which layer(mask) is true with an ellipse centre
    % placed at this pixel centre.
    ellLayerTrueFrac = zeros(nlayers, grid.nx, grid.ny);

    %% Optimize
    if wb
        waitbar(0, hWb, 'Calculating: 0%');
    end
    
    nTotal=grid.nx*grid.ny*nlayers;
    n=0;
    % Move ellipse center to xc,yc for each pixel in this grid
    for ix = 1:grid.nx
        for iy = 1:grid.ny
            
            % Make temporary ellipse with centre at grid using
            % existing properties in ellipse object.
            % angRes in radians given by: 2*pi/(ellipse.nvertices-1)
            ell = ellipseObj(ellipse.xa, ellipse.ya, ellipse.azimuth,...
                ellipse.angRes, grid.xgc(iy,ix), grid.ygc(iy,ix));
            % polybool produces a warning unless we order the ellipse vertices CW.
            [ell.x, ell.y] = poly2cw(ell.x,ell.y);
            
            for il = 1:nlayers
                if layerMask(il)
                    
                    % Update progress bar and check for cancel request
                    if wb
                        if getappdata(hWb,'canceling')
                            % Cancel button has been pressed: delete waitbar and return 
                            % empty arrays.
                            delete(hWb);
                            result = {};
                            return
                        else
                            fracDone = n/nTotal;
                            waitbar(fracDone, hWb,...
                                ['Calculating: ',sprintf('%5.2f', fracDone*100),'%']);
                        end
                    end
                    
                    % Find the fraction of the ellipse that is covered by
                    % this layer.
                    [xInt,yInt] = polybool('intersection',...
                                     layers{il}.xPolyFoot, layers{il}.yPolyFoot,...
                                     ell.x, ell.y);
                                 
                    % Area of intersection/area of ellipse. Must be
                    % non-zero because layerMask(il) == true if we are in
                    % this condition block.
                    ellLayerFrac(il,ix,iy) = polyarea(xInt,yInt)/ell.areaTrue;
                    
                    % Now we need to determine the fraction of the raster
                    % that is true within the intersecting area. We already
                    % have the subFrame in the rasterLayer object, so we
                    % must query it.
                    
                    % To really test
                    % this accurately we would draw pixel edges as polygons
                    % and test intersection with each, but since raster
                    % pixels are likely to be much smaller than ellipse
                    % size, a faster way is to count the number of cells
                    % that are both in the ellipse and true in the mask.
                    
                    % Find the true part of the subframe within the ellipse
                    % and calculate its area.
                    
                    % First we test if the corners of the subframe are
                    % entirely inside the ellipse, in which case we don't
                    % need to run inpolygon. We just make the right hand term == true.
                    if inpolygon(layers{il}.xPolySubf, layers{il}.yPolySubf, ell.x, ell.y)
                        subMask = layers{il}.mask(ySubInds,xSubInds);
                    else
                        subMask = layers{il}.mask(layers{il}.yvIndsSubf, layers{il}.xvIndsSubf)...
                                  &...
                                  inpolygon(...
                                  layers{il}.xg(layers{il}.yvIndsSubf, layers{il}.xvIndsSubf),...
                                  layers{il}.yg(layers{il}.yvIndsSubf, layers{il}.xvIndsSubf),...
                                  ell.x, ell.y);
                    end
                    
                    % Calculate the total fractional area of the ellipse
                    % that is true in subMask.
                    ellLayerTrueFrac(il, ix, iy) = ...
                        sum(layers{il}.areaSubf(subMask)) / ell.areaTrue;
                    
                    % Increment job number.
                    n = n + 1;
                end
            end
        end
    end
    
    % Sum ellLayerTrueFrac down the layer dimension to retrieve the total
    % score for all layers. Squeeze to remove singleton dimension.
    ellTrueFrac = squeeze(sum(ellLayerTrueFrac, 1));
    
    % Get cell arrays of files in layers, used for titling outputs.
    for il = 1:nlayers
        lfname{il} = layers{il}.fname;
        lfpath{il} = layers{il}.fpath;
    end
    
    % Make results object.
    azvec = [];
    result = resultObj(ellipse, grid, azvec, ellLayerFrac, ellLayerTrueFrac, ellTrueFrac, lfpath, lfname);
    
    % Remove progress bar.
    if wb
        delete(hWb);
    end
end