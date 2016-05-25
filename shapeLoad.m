%
% Function to load the polygons in a shapefile and return them as a cell
% array of polygon objects. Nothing is returned the shapefile contains
% points or lines.
%
function poly = shapeLoad()

    poly = {};
    
    filterSpec = {'*.shp','*.shp - Shapefile containing polygons to evaluate.'};

    [fName, dirPath, ~] = uigetfile(filterSpec,'Load Shapefile',...
            'MultiSelect','off');
    
    % Readem
    if ~isnumeric(dirPath) && ~isnumeric(fName)
        
        fPath = [dirPath, fName];
        
        if exist(fPath,'file')
            try
                s = shaperead(fPath);
            catch
                % If file is invalid.
                return
            end
            % Make a cell array of polygon objects.
            counter = 0;
            for i = 1:numel(s)
                if strcmpi(s(1).Geometry,'polygon')
                    counter = counter + 1;
                    poly{counter} = polyObj(s(i));
                end
            end
        end
    end
end
