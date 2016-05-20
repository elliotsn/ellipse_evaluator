%
% Function to return the index of the element in vec that is closest in 
% value to the point p. Vec must be always increasing or always decreasing.
% If p lies outside the domain of the vector, ind is set to the first or 
% last vector element.
%
% Inputs:
%   vec  - 1 x n monotonic ascending vector
%   p    - point for which index is returned
%
% Outputs:
%   ind  - index of point position in vec
%
%  Copyright 2016  Elliot Sefton-Nash
function ind = getVecPointInd(vec, p)

    n = numel(vec);
    if p > max(vec);
        ind = n;
    elseif p < min(vec);
        ind = 1;
    else
        d = abs(p - vec);
        ind = find(d == min(d),1);
    end
    
end