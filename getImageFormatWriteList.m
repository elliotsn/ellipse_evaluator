% Function to return the list of image formats available to write plots to.
%
%  Copyright 2016  Elliot Sefton-Nash
function [desc, ext] = getImageFormatWriteList()
    desc = {'PNG', 'JPEG', 'TIFF', 'BMP'};
    ext = {'png', 'jpg', 'tif', 'bmp'};
end