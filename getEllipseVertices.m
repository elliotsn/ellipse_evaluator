%
% Function to calculate vertices on an ellipse defined by its major & minor
% axes and rotation (CCW from +ve y direction in radians).
%
% Inputs:
%   xa - ellipse size in x-direction.
%   ya - ellipse size in y-direction
%   r - rotation counter-clockwise from +ve y direction in radians
%   angRes - angular resolution at which to calculate vertices.
%
% Outputs:
%   xout,yout - vectors of points describing ellipse. Origin, centre of ellipse is at 0,0.
%
%  Copyright 2016  Elliot Sefton-Nash
function [xout, yout] = getEllipseVertices(xa, ya, r, angRes)
    
    % Vector of angles for which to calculate ellipse x,y vertices.
    % Measured CCW from -ve y axis in radians.
    angVec = -pi:angRes:pi;
    
    x = xa * cos(angVec);
    y = ya * sin(angVec);
    
    % Rotate vertices by specified angle around origin.
    [xout,yout] = rotPoint2D(x, y, 0, 0, r);
    
end