% Function to return the time right now in the format YYYYMMDDTHHMMSS
%
%  Copyright 2016  Elliot Sefton-Nash
function timeStr = getTimeStrNow()
    timeStr = datestr(now,'yyyymmddTHHMMSS');
end