%
% Function to build a bounding rectangle (CW polygon) with 2 vectors
% which are used to build a grid. Points on edges are
% required even if edges are straight.
%
function [x, y] = boundingRectGrid(xv, yv)
   
    nx = numel(xv);
    ny = numel(yv);
    
    if nx == 0 || ny == 0;
        x = []; y = [];
    elseif nx == 1 && ny == 1
        x = xv; y = yv;
    else
        xv = sort(xv, 'ascend');
        yv = sort(yv, 'ascend');
    
        if nx == 1 && ny > 1
            x = repmat(xv, [1 ny]);
            y = yv;
        elseif ny == 1 && nx > 1
            x = xv;
            y = repmat(yv, [1 nx]);
        else 
            xl = [min(xv) max(xv)];
            yl = [min(yv) max(yv)];
            
            % LL -> UL -> UR -> LR
            x = [repmat(xl(1),[1 ny]) xv(2:end)              repmat(xl(2),[1,ny-1]) reverse(xv(2:end-1))   ];          
            y = [yv                   repmat(yl(2),[1,nx-1]) reverse(yv(1:end-1))   repmat(yl(1),[1,nx-2]) ];
        
        end
    end
end