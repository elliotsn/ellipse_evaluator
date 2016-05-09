% Function to validate and create a linear space defined by its limits and interval.
function vec = getVec(lims, step)
    d = diff(lims);
    if d == 0
       % If limits are the same and step is 0 then a scalar is desired
       if step == 0
           vec = lims(1);
       else
           % Otherwise the input is incorrect.
           vec = [];
       end
    else
        if step > d
            step = d;
        end
        % Define vector. Lims represents edges, vec represents pixel edges.
        vec = min(lims):step:max(lims);
    end
end