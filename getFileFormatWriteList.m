% Function to return the list of supported file formats and thier 
% extensions. Accepts evalMode, an integer denoting the mode of evaluation.
function [desc, ext, aux] = getFileFormatWriteList(evalMode)
    
    evalModes = getEvaluateModes();
    
    switch evalModes{evalMode}
        case 'lat-lon'
            desc = {'IMG', 'TIFF','PNG', 'JP2', 'Matlab', 'Band-sequential'};
            ext = {'img', 'tif', 'png', 'jp2', 'mat', 'bsq'};
            % Empty string means no auxilliary file written.
            aux = {'lbl', 'tfw', 'pgw', '', '', 'hdr'};
            
        case 'azimuth'
            desc = {'Textfile', 'TIFF','PNG', 'Matlab', 'Band-sequential'};
            ext = {'.txt',      'tif', 'png', 'mat',    'bsq'};
            aux = {'',          'tfw', 'pgw', '',       'hdr'};
    end
end