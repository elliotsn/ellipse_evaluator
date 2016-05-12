%
% Function to plot compliant ellipse fraction for each layer as a function
% of azimuth, on the axes hAx. layers is a cell array of layer objects.
% result is a single result object calculated in azimuth evaluation mode.
%
function [hAx, hTitle, hXLab, hYLab, hLeg] = ...
    plotEllFracVsAz(hAx, layers, result)

    nlayers = numel(layers);
    % Plot lines for ellLayerTrueFrac for each layer. ellLayerTrueFrac
    % should be an nlayer x naz.
    legStr = cell(1,nlayers+1);
    for il = 1:nlayers         
        plot(result.azvecd, squeeze(result.ellLayerTrueFrac(il, :)),...
        'Parent',hAx,...
        'Marker','^');
        if il == 1
            hold on
        end
        legStr{il} = layers{il}.fname;
    end
    
    legStr{end} = 'Total compliant ellipse fraction';
    
    plot(result.azvecd, result.ellTrueFrac,...
    'Parent',hAx, 'LineWidth', 2,...
    'Color','k','Marker','+');
    
    set(hAx, 'XLim',[min(result.azvecd) max(result.azvecd)]);
    hXLab = xlabel('Azimuth$^\circ$','Interpreter','latex');
    hYLab = ylabel('Ellipse fraction','Interpreter','latex');
    hTitle = title('Ellipse fraction at azimuth that meets layer constraints');
    
    hold off
    hLeg = legend(legStr);