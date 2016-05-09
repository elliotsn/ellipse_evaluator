% Returns two cell arrays of strings. label contains short strings for use
% in list boxes. desc contains the description of the unit.
function [label, desc, mult] = getLengthUnitList()
    label = {'m', 'km'};
    desc = {'metres', 'kilometres'};
    % Factors to convert units into metres.
    mult = [1 1e3];
end