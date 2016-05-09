% Function to plot the footprints of all the loaded raster layer objects 
% onto the axis handle passed in hAx.
function plotLayerFootprints(layers, hAx)

    % Get color pallette to plot layers.
    cols = {'r','g','b','c','m','y','k'};

    % Calculate footprint for each layer loaded.
    for i = 1:numel(layers)
        % Make a footprint patch using lat lon layer limits as
        % vertices. CW from top left.
        [thisx,thisy] = getxyRectFromLims(layers{i}.lonlims, layers{i}.latlims);

        % Cycles around again if more layers than unique colours.
        thisCol = cols{mod(i,numel(cols))};
        patch(thisx, thisy, thisCol, 'EdgeColor', thisCol,...
                          'LineStyle', '-', 'EdgeAlpha', 0.7, 'FaceAlpha', 0.1,...
                          'Parent', hAx);
        % Label this layer
        text(mean(layers{i}.lonlims), mean(layers{i}.latlims),...
             layers{i}.fname, 'Parent', hAx, 'Interpreter', 'none',...
             'BackgroundColor', thisCol);
        
        % Place all patch objects on the same axes without clearing. Hold
        % on first time round.
        if i==1
            hold(hAx, 'on');
        end
    end
    hold(hAx, 'off');
    % Turn off hold for now, remember to turn on again if other layers are
    % to be plotted over the footprints.
end