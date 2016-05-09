%
% Function to return the time right now in the format YYYYMMDDTHHMMSS
%
function timeStr = getTimeStrNow()
    timeStr = datestr(now,'YYYYMMDDThhmmss');
end