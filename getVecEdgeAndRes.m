%
% Passed a linear 1xn vector, determine a vector of edges and the spacing
% of the vector. Allows for 1x1 vectors, but unable to set meaningful res
% or edges, returns NaN.
%
%  Copyright 2016  Elliot Sefton-Nash
function [edges, res] = getVecEdgeAndRes(centers)
    flag = true;
    if isempty(centers) || numel(centers) == 1
        flag = false;
    end
%     else
%         % Test for linearity. Removed because of false triggering due to
%         floating point arithmatic.
%         res = centers(2)-centers(1);
%         if any(diff(centers) ~= res)
%             flag = false;
%         end
%     end
    if flag
        res = centers(2)-centers(1);
        halfres = res/2;
        edges = [centers(:)-halfres; centers(end)+halfres];
    else
        res = NaN;
        edges = NaN;
    end
end