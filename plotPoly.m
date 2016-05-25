% Function to plot an object with lat,lon fields on the axes hAx.
%
%  Copyright 2016  Elliot Sefton-Nash
function plotPoly(x, y, hAx)
    plot(hAx, x, y,...
                'Linestyle','-','Color',[0 0 0]);
    axis xy equal
end