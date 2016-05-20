% Function to read from tif and world file.
%
% Inputs:
%   fpath        - path to tif.
%   fpathworld   - path to world file.
%
% Outputs:
%   im           - image array
%   x            - array same size as im containing map-projected x
%                  coordinates.
%   y            - array same size as im containing map-projected y
%                  coordinates.
%   R            - 3x2 raster spatial reference matrix.
%
%
%  Copyright 2015-2016  Elliot Sefton-Nash
%
function [im, x, y, R] = readTifAndWorld(fpath, fpathworld)
    % Test
    im = imread(fpath);
    % Tif must be monochromatic.
    if numel(size(im)) > 2
        msgbox(['tif must be monochromatic (not RGB). ',fpath,' not loaded.'],'Warning','warn');
    else
        % Read world file to get 3x2 referencing matrix. Allows
        % images to be rotated from map coordinates.
        R = worldfileread(fpathworld);

        % Return arrays of x and y coordinates for each pixel in the
        % image. These are then used to map the image onto the grid
        % specified.
        s = size(im);

        % pix2map is the same as pix2latlon, except that pix2latlon
        % can also accept geographic raster reference objects in addition to 3x2 
        % referencing matrices. When R is a referencing matrix,
        % then pix2latlon actually calls pix2map. This means that
        % if the values in the worldfile already convert pixel numbers to latlon 
        % then pix2map does the same job as pix2latlon. The key
        % here is to make sure that all the layers have referencing
        % matrices or projections that convert them into the same
        % map units, where they be lat-lon or some screen
        % coordinate.
        [col,row] = meshgrid(s(2):-1:1,1:s(1));
        [y,x] = pix2map(R,col,row);
    end
end