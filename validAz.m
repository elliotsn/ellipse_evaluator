% Function to validate an azimuth entered as a string. Returns a value and
% a string.
% azUnitsInd is the index in the array returned by getAngUnitList(),
% defining the angular units.
function [azStr, azNum]= validAz(azStr,azUnitsInd)
    % If not valid number set empty string.
    v = validNumeric(azStr);
    if isempty(v)
        azStr = '0';
        azNum = 0;
    else
       % Valid number. Check units and map angle to one phase.
       [~, ~, mult] = getAngUnitList();
       % List box value corresponds to position in arrays returned by
       % getAngUnitList. Convert to radians.
       f = mult(azUnitsInd);
       % If <0 or >=2pi radians then correct phase, and convert back to
       % specified units.
       t = mod(v*f, 2*pi)/f;
       azStr = num2str(t);
       % Normally edit ui controls don't use this property, but it can
       % conveniently be used here to store the numeric value shown in the
       % textbox for use when called upon later;
       azNum = t;
    end
end