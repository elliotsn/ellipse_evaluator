% Function to return the list of supported file formats and thier extensions.
function [desc, ext, aux] = getFileFormatList(evalMode)
    
    evalModes = getEvaluateModes();
    switch evalModes{evalMode}
        case 'lat-lon'
            desc = {'IMG', 'TIFF','PNG', 'JP2', 'Matlab', 'Band-sequential'};
            ext = {'img', 'tif', 'png', 'jp2', 'mat', 'bsq'};
            % Empty string means no auxilliary file needed.
            aux = {'lbl', 'tfw', 'pgw', '', '', 'hdr'};
            
        case 'azimuth'
            
            
    end

    
end