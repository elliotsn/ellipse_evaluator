% Function to plot the ellipse in the ellipse object ellipse on the axes
% hAx.
function plotEllipse(ellipseObj, hAx)
    plot(hAx, ellipseObj.lon, ellipseObj.lat,...
                'Linestyle','-','Color',[0 0 0]);
    axis xy equal
end