function individual_obj = objective(individual)
    %% 计算适应度值
    global parameter dim_t
    individual_obj1 = zeros(1,parameter.period);
    individual_obj2 = zeros(1,parameter.period);
    
    Room={};Car={};
    % 遍历周期数
    for t = 1 : parameter.period
        % 获取每周期的解
        x_t = individual(1,(t-1)*dim_t+1:t*dim_t);
        % 每个解每个周期采血点与服务台的开放情况
        [Room{t},Car{t}] = Amend_t(x_t,parameter.fixed_filter_risk(t).index,parameter.mobile_filter_index(t).index);
        %% 计算每个周期的目标值
        [t_obj1,t_obj2] = obj_cal(Room{t},Car{t},t);
        %% 目标1
        individual_obj1(:,t) = t_obj1;
        %individual_obj1 = t_obj1 + individual_obj1;
        %% 目标2
        individual_obj2(:,t) = t_obj2;
    end
    % 目标值1：求和
    individual_obj1 = sum(individual_obj1);
    % 目标值2：求和
    individual_obj2 = sum(individual_obj2);
    individual_obj = [individual_obj1,individual_obj2];  
end

