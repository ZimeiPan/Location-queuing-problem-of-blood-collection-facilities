function ret=test(x)
    ret=1;
    % Decoding real numbers into integer solution form
    global parameter dim_t
    Room={};Car={};
    for t = 1 : parameter.period
        % Get the solution for each period
        x_t = x(1,(t-1)*dim_t+1:t*dim_t);
        [Room{t},Car{t}] = Amend_t(x_t,parameter.fixed_filter_risk(t).index,parameter.mobile_filter_index(t).index);
        % Calculate the objective value for each period
        flag = stability_constraint(Room{t},Car{t},t);
        
        if flag == 0
            ret = 0;
            return
        end
    end
end