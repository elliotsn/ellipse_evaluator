function [values] = readWorldFile(path)
%
%  Function to read the 6 numeric values from a world file and return them
%
fid = fopen(path,'rt');
values = zeros(6, 1);

for i = 1:6
    in = fgetl(fid);
    values(i, 1) = str2double(in);
end
fclose(fid);