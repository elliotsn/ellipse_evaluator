% Function to make x,y coordinate vectors for 1x2 vectors of min,max x and y to plot a 
% rectangle.
%
%  Copyright 2016  Elliot Sefton-Nash
function [x, y] = getxyRectFromLims(xlims, ylims)
    x = [ xlims(1) xlims(2) xlims(2) xlims(1) xlims(1) ];
    y = [ ylims(2) ylims(2) ylims(1) ylims(1) ylims(2) ];
end