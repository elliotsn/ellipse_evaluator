% Plots a patch on some axes, gray, 70% transparent with a dotted border.
function plotExtentPatch(hAx,x,y)
    hold(hAx, 'on');
    patch(x, y, 'k', 'EdgeColor', 'k',...
      'LineStyle', '--', 'EdgeAlpha', 0.7, 'FaceAlpha', 0.1,...
      'Parent', hAx);
    hold(hAx, 'off');
end