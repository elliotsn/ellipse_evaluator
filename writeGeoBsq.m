%
% Function to write an arc-friendly BSQ from a 2D image array and it's lat
% and lonvec.
%
% rp is the radius of the planet
%
% Elliot Sefton-Nash 20150909
%
function [bsqfpath, hdrfpath] = writeGeoBsq(latvec, lonvec, im, bsqfpath, rp)

    % Write the bsq file.
    multibandwrite(im, bsqfpath, 'bsq', 'machfmt', 'ieee-be', 'precision', 'uint8');
    
    % Get params for header and write header file, assuming equidistant
    % cylindrical and that latvec and lonvec represent the lower left of
    % pixels.
    
    % Get upper left of map in plate carree, assumes east longitude.
    [xmap, ymap] = latlon2platecaree(latvec, lonvec, rp);
    ulxmap = min(xmap);
    ulymap = max(ymap);
    
    % Pixel size in plate carree, based on average max,min difference
    s = size(im);
    ydim = mean(diff(ymap));
    xdim = mean(diff(xmap));
    
    %% Write header file
    % Open the ASCII file for writing
    hdrfpath= [bsqfpath(1:end-3), 'hdr'];
    fid = fopen(hdrfpath, 'w');

    % Write the values.
    fprintf(fid, ['nrows ', num2str(s(1)), ' \n']);
    fprintf(fid, ['ncols ', num2str(s(2)), ' \n']);
    fprintf(fid, 'nbands 1\n');
    fprintf(fid, 'byteorder M\n');
    fprintf(fid, 'layout bsq\n');
    fprintf(fid, 'nbits 8\n');
    fprintf(fid, ['xdim ', num2str(xdim),'\n']); % dimensions of pixels in map units
    fprintf(fid, ['ydim ', num2str(ydim),'\n']);
    fprintf(fid, ['ulxmap ', num2str(ulxmap), '\n']);
    fprintf(fid, ['ulymap ', num2str(ulymap), '\n']);
    
    fclose(fid);
end