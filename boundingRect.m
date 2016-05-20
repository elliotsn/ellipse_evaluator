%
% Function to build a bounding rectangle (CW polygon) with 2 vectors
% containg a point cloud.
%
%  Copyright 2016  Elliot Sefton-Nash
function [x, y] = boundingRect(xv, yv)
    xlims = [min(xv(:)) max(xv(:))];
    ylims = [min(yv(:)) max(yv(:))];
    %     UL       UR       LR       LL
    x = [xlims(1) xlims(2) xlims(2) xlims(1)];
    y = [ylims(2) ylims(2) ylims(1) ylims(1)];
end