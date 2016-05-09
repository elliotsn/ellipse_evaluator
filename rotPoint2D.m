%
% Function to rotate a set of 2D points around an origin.
%
% Inputs:
%   x   - vector of x coordiantes of points
%   y   - vector of y coordiantes of points
%   xo  - x-coordinate to rotate about
%   yo  - y-coordinate to rotate about
%   ang - angle in radians to rotate
%
% Outputs:
%   x, y - vectors of rotated output points
%   
% Author : Elliot Sefton-Nash (e.sefton-nash@uclmail.net)
% Date   : 20151125
%
function [xout,yout] = rotPoint2D(x, y, xo, yo, ang)

    % Make 2 x 2 rotation matrix.
    R = [cos(ang) -sin(ang); sin(ang) cos(ang)];
    % 2 x n matrix of points for multiplication with R.
    p = [x;y];
    % 2 x n origin matrix.
    o = repmat([xo;yo], 1, length(x));
    % Shift points so centre of rotation is at origin, rotate, then put rotated points 
    % back where they where.
    s = R*(p-o) + o;
    
    % Place in output variables.
    xout = s(1,:);
    yout = s(2,:);
end