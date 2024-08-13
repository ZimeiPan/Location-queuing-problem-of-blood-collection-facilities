function ret=test(x)
    % 默认满足约束
    ret=1;
    %% 将实数解码为整数解形式
    global parameter dim_t
    Room={};Car={};
    % 遍历周期数
    for t = 1 : parameter.period
        % 获取每周期的解
        x_t = x(1,(t-1)*dim_t+1:t*dim_t);
        % 每个解每个周期采血点与服务台的开放情况
        [Room{t},Car{t}] = Amend_t(x_t,parameter.fixed_filter_risk(t).index,parameter.mobile_filter_index(t).index);
        %% 计算是否满足系统稳定性约束
        flag = stability_constraint(Room{t},Car{t},t);
        
        if flag == 0
            ret = 0;
            return
        end
    end
end

