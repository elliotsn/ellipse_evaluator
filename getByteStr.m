%
% Function to return a string that represents the number of bytes in B in a
% tidy way.
%
% Author: Elliot Sefton-Nash
% Date  : 20151208
function s = getByteStr(B)
    n = floor(log2(B)/10);
    if n < 0
        s = '';
    else
        if n == 0
            % Just ' B'
            num = sprintf('%i',round(B));
            suf = '';
        else % n > 0
            % Assume that: suf_i+1 = suf_i*10^3.
            % If 2^10 <= B < 2^20 then suffix == 'K' etc..
            sufs = {'K','M','G','T','P','E','Z','Y'};
            ns = numel(sufs);
            % More than the suffixes that we have.
            if n > ns
                % Only in largest. i.e. ' YB' as suffix.
                suf = sufs{end};
                % One extra digit for every extra power of 10 in YB
                n = ns;
                wholedigits = floor(log10(B/(2^(n*10)))+1);
            else
                % Uses one of the sufs.
                wholedigits = 3;
                suf = sufs{n};
            end
            % num is a nicely formatted version of B divided by the highest value of n 
            % where 2^(10*n) < B == true
            if isinf(wholedigits)
                % wholedigits is returned Inf when overflows.
                % Limit in this case is 1023.999999999999 (~ 2^10) YB.
                num = '> 2^10';
            else
                num = sprintf(['%',num2str(wholedigits),'.3f'],B/(2^(n*10)));
            end
        end
        s = [num ' ' suf 'B'];
    end
end