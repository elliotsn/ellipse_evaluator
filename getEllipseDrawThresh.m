function ellipseDrawThresh = getEllipseDrawThresh()
% The number of ellipses that are allowed to be drawn to determine the 
% precise footprint when previewing evaulations. If the number of ellipses
% to be drawn are above this value then an approximation of the footprint
% is calculated. Yhe corners of the ellipse extents are joined to
% form a rectangle on the map.
    ellipseDrawThresh = 500;
