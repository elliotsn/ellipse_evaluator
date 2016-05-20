function [id, core, corelonvec, corelatvec]=read_hrsc_img(infile)

% This function reads .IMG PDS files of data from
% the High Resolution Stereo Camera aboard Mars Express.
%
%function [id, core, corelonvec, corelatvec]=read_hrsc_dtm(infile)
%
%Input:
%       -'infile' is the .IMG file to extract the data
%        from. 
%Output:
%       -'id'         is the identifier of the image being processed
%       -'core'       is the actual dtm data
%       -'corelonvec' is the longitude vector for the 'core' data
%       -'corelatvec' is the latitude vector for the 'core' data
%
%  Copyright 2008-2016  Elliot Sefton-Nash
%
% Changelog:
%
% 20/08/2012 Updated so as to read the actual footprint, rather than making a linear grid \
% between the max and min lon and lat.
% 
% 
%

%---------FIRST OPEN FILE AS TEXT TO READ LABEL INFO---------
%
% Define the set of image parameters found in the label/header
% which are needed for Matlab reading and processing of image data.
%
% The structure of a the keys2get array addressing is as follows: 
%   'Parameter Parent1 Parent2 Parent3'
%

keys2get = {'PRODUCT_ID';                                       %  1 Image identifier
	    'RECORD_BYTES';                                         %  2 Number of bytes per record
	    '^IMAGE';                                               %  3 Number of the record that the image data starts at
        'INTERCHANGE_FORMAT IMAGE';                             %  4
        'MINIMUM_LATITUDE IMAGE_MAP_PROJECTION';                %  5
        'MAXIMUM_LATITUDE IMAGE_MAP_PROJECTION';                %  6
        'WESTERNMOST_LONGITUDE IMAGE_MAP_PROJECTION';           %  7
        'EASTERNMOST_LONGITUDE IMAGE_MAP_PROJECTION';           %  8
        'LINES IMAGE';                                          %  9
        'LINE_SAMPLES IMAGE';                                   % 10
        'SAMPLE_TYPE IMAGE';                                    % 11 This should be MSB_INTEGER for HRSC DTMs
        'SAMPLE_BITS IMAGE';                                    % 12 This should be 16
        'MEX:DTM_MISSING_DN MEX:DTM';                           % 13 The DN for null pixels.
        'LINE_PREFIX_BYTES IMAGE'};                             % 14 The number of prefix bytes that precede a line in the image
        
% Create the keyword data structure with attributes addresses and
% values.
sizekeys2get = size(keys2get);
for i = 1:sizekeys2get(1)
    keys(i).address = keys2get(i);
    keys(i).value = 0;
end

inheader = 1;
infooter = 0;
level = 0; % Holds the level of indentation that the cursor is at. Allows us to address the keywords based on thier 'address' held in keys2get.
footerstartbyte = -1; % To begin with, assume there is no EOL. Some files may not have them.
address = '';
fid = fopen(infile, 'rt');

% If we find an 'End' in the header, we proceed to the start of the EOL,
% whose location may have been read. If it has not then we close the file.
% Sometimes in the footer there is an 'End' before the end of the EOL. So
% we keep reading regardless until the EOF if we are in the EOL.
while ~feof(fid) && (inheader || infooter)
     hline = fgetl(fid);
     
     % Separate hline into keyword and value either side of the '=' delimiter.
     [keyword,value] = strtok(hline,'=');
          
     if ~isempty(keyword)
        
        % Remove spaces and the '=' assignment operator.
        keyword = sscanf(keyword,'%s');
        value = strtrim(strtok(value, '='));
        
        % Test if the keyword is Group OR Object OR End_Group OR End_Object. If so we need to adjust
        % the parent tree.
        switch upper(keyword)
            case {'OBJECT', 'GROUP'}
                level = level + 1;
                address = [value, ' ', address];  %#ok<AGROW> % Push the new parent at the front of the address.
                
            case {'END_OBJECT', 'END_GROUP'}
                level = level - 1;
                [reject, address] = strtok(address, ' '); % Take off the front value from the address string
                address = strtrim(address);
                       
            case 'END'
                % If there is an END is the header, it means we should
                % proceed to the footer, ONLY if footerstartbyte != -1.
                % Else we should quit this while loop, done by setting
                % both infooter and inheader = 0.
                if inheader && (footerstartbyte > -1)
                    fseek(fid, footerstartbyte, 'bof');
                    infooter = 1;
                end
                inheader = 0;
            
            otherwise
                % Now perform an action based on the current address with
                % the current keyword added to it.
                fulladdress = strtrim([keyword, ' ', address]);
                
                if strcmpi(fulladdress, 'STARTBYTE ORIGINALLABEL');
                    footerstartbyte = str2double(value);
                else
                    for i = 1:sizekeys2get
                        if strcmpi(keys(i).address, fulladdress)
                           keys(i).value = value;
                        end
                    end
                end
                fulladdress = '';
        end
     end
end

fclose(fid);

% Should test here to see if any of the keys are empty and return an error
% if so, as we cannot load the image unless they are all obtained from the file.


%------------------------- NOW READ CORE IMAGE DATA -----------------------

% IMG FILE PARAMETERS
id = keys(1).value;
record_bytes = str2double(keys(2).value);               % Label bytes
image_pointer = str2double(keys(3).value);              % Record pointer to the start of the image data
samples = str2double(keys(10).value);                   % Image samples                       
lines = str2double(keys(9).value);                      % Image lines

% The start byte of the data is (^IMAGE - 1) * RECORD_BYTES
data_start_byte = (image_pointer - 1)*record_bytes;

% Find out the precision based on passing, in this case, the value
% associated with the PDS keyword 'SAMPLE_BITS'.
[precision, pixel_bytes] = get_precision(keys(12).value);

% Turn the precision into one that loads AND parses the specified
% data type as the same precision, rather than just loading it as specified then storing it as
% the default 'double'.
precision = ['*', precision];

% Find out what byte-ordering the data is. The keyword SAMPLE_TYPE tells us
% this. For HRSC it's usually MSB_INTEGER, which is big endian.
endian = get_endian(keys(11).value);

% Open the file as binary read-only.
fid = fopen(infile, 'r', endian);

% Skip the header.
fseek(fid, data_start_byte, 'bof');

% Are there any line prefix bytes, if so we must avoid them.
line_prefix_bytes = str2double(keys(14).value);
if line_prefix_bytes > 0
    margin = line_prefix_bytes/pixel_bytes;
    readsamples = samples + margin;
else
    readsamples = samples;
end

core = fread(fid, [readsamples, lines], precision);

% Now get rid of the margin produced by the extra engineering values
% contained in the line_prefix_bytes.
if line_prefix_bytes > 0
    core = core(margin+1:end, :);
end

% Rotate by 90 degrees.
core = core';

fclose(fid);

% Set all pixels equal to the null value equal to zero.
null_dn = str2double(keys(13).value);
core(core == null_dn) = NaN;

%-----LAT LON-----
% OLD AND CRUDE
%maxlat = str2double(keys(6).value);   % MAXIMUM_LATITUDE IMAGE_MAP_PROJECTION
%minlat = str2double(keys(5).value);   % MINIMUM_LATITUDE IMAGE_MAP_PROJECTION
%maxlon = str2double(keys(8).value);   % EASTERNMOST_LONGITUDE IMAGE_MAP_PROJECTION
%minlon = str2double(keys(7).value);   % WESTERNMOST_LONGITUDE IMAGE_MAP_PROJECTION
% Extract degrees per pixel in lat and lon.
%dlat = (maxlat-minlat)/(lines-1);
%dlon = (maxlon-minlon)/(samples-1);
% Create the lat/lon vectors.
%corelatvec = maxlat:-1*dlat:minlat;
%corelonvec = minlon:dlon:maxlon;

% Using the footprint, interpolate lat,lon in that grid for each pixel




end