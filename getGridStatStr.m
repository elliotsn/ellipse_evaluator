% Function to return the statistics for this grid using the pixel center
% vectors, becasue number of elements == number of pixels.
function str = getGridStatStr(xvc,yvc)
    nx = numel(xvc);
    ny = numel(yvc);
    
    str = ['Grid Dimensions',char(10),char(10),...
           'Width  : ', num2str(nx), ' pixels',char(10),...
           'Height : ', num2str(ny), ' pixels',char(10),...
           'Memory : ', getByteStr(nx*ny)];
end