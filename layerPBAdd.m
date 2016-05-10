%
% Function that is called by layerPBAdd_Callback when the Add pushbutton is pressed in the 
% Layer panel. rasterLayers is returned either as an empty array or a cell
% array of rasterLayer objects corresponding to the loaded raster layers.
%
function rasterLayers = layerPBAdd()

    % Open the file selection dialogue, allowing only these files to be
    % selected for opening.
    % Function to return the list of supported file formats and thier extensions.
    [desc, ext, ~] = getFileFormatReadList();
    ext = cellfun(@(x) ['*.' x], ext, 'UniformOutput', false);
    filterSpec = [ext', desc'];
    
    % Open the dialogue.
    % TODO, make work for multiselect = 'on'
    [fileName, pathName, ~] = uigetfile(filterSpec,'Add Raster Layer',...
        'MultiSelect','off');

    % If files were selected, try to open them.
    if ~isnumeric(fileName)
        % Just one file, convert to 1x1 cell array to pass to layer adding
        % function.
        if ischar(fileName)
            fileName = cellstr(fileName);
        end
        if ischar(pathName)
            pathName = cellstr(pathName);
        end
        nFiles = numel(fileName);
        for i = 1:nFiles

            thisfpath=strcat(pathName{i},fileName{i});
            if exist(thisfpath,'file')
                % Create a new rasterLayer object. Read the file and add it to the 
                % array of raster layers.
                tmp = rasterLayerObj(thisfpath);
                if ~isempty(tmp)
                    rasterLayers{i} = tmp;
                end
            else
                warning([thisfpath, ' does not exist. Unable to add layer.']);
            end
        end
    else
       % No files were selected.
       rasterLayers = {};
    end
end
