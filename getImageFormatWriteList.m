% Function to return the list of image formats available to write plots to.
function [desc, ext] = getImageFormatWriteList()
    desc = {'PNG', 'JPEG', 'TIFF', 'BMP'};
    ext = {'png', 'jpg', 'tif', 'bmp'};
end