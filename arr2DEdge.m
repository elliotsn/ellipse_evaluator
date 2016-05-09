%
% Function to return the elements around the edge of a 2D array, in the
% CW direction: LL -> UL -> UR -> LR
%
% Automatically removes extraneous singletons above 2D.
% Returns empty if number of dimensions is not 2, or input is empty, or not
% an array.
% Returns the input array if it is 2D but one of the dimensions is of size
% 1.
function edge = arr2DEdge(arr)
    if ~isempty(arr) && ismatrix(arr)
        % Remove singletons
        arr = squeeze(arr);
        if ndims(arr) == 2 %#ok<ISMAT>
            if any(size(arr) == 1)
                edge = arr;
            else                
                edge = [arr(end:-1:1,1)' arr(1,2:end), arr(2:end,end)', arr(end,end-1:-1:2)];
            end
        else
            edge = [];
        end
    else
        edge = [];
    end
end