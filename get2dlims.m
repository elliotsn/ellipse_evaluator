%
% Funciton to return the min and max values for a set of points in 2D.
%
%  Copyright 2016  Elliot Sefton-Nash
function [xlims, ylims] = get2dlims(x,y)
    xlims = [min(x(:)) max(x(:))];
    ylims = [min(y(:)) max(y(:))];
end