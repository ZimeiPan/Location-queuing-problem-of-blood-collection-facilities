function [flag] = stability_constraint(Room,Car,t)
    % 默认满足约束
    flag = 1;
    %% 判断是否满足系统稳定性约束
    global parameter

    %% 如果room和Car都为空，则flag为0
    if (isempty(Car)) && (~any(any(Room)))
        flag = 0;
        return 
    end
    % 移动献血屋候选点数量+固定献血屋候选点数量
    location_num = size(parameter.mobile_risk,2) + size(parameter.fixed_risk,2);
    %% 根据解的开放情况，得出每个捐赠点距离最近的采血点
    % 移动
    mobile_index = parameter.mobile_filter_index(t).index(Car(1,:));
    % 固定
    index_1 = find(Room(1,:) == 1);
    fix_index = index_1 + size(parameter.mobile_risk,2);
    % 开放设施点索引
    index = [mobile_index,fix_index];
    
    
    % 找到捐赠点分配的最小的索引
    % V：最短的距离 I:索引
    utility_matrix = distribution(parameter,t);
    %[V,I] = min(parameter.distance_matrix(:,index),[],2); 
    [V,I] = min(utility_matrix(:,index),[],2); 
    
    %% 计算每个采血点的到达概率
    collection_rate_t = zeros(1,location_num);
    % 遍历每个捐赠点
    for i = 1 : size(parameter.donation_risk,1)
        % 采血点索引
        collection_rate_index = index(I(i,:));
        % 距离-到到达最近的采血点
        %distance = V(i,:);
        distance = parameter.distance_matrix(i,collection_rate_index);
        % 距离敏感因子
        H_ij = 1 - distance/parameter.max_distance;
        % 捐赠区域风险敏感因子
        G_i = 1 - parameter.donation_risk(i,t)/3;
        % 对采血点的风险敏感因子
        G_j = 1 - parameter.location_risk(t,collection_rate_index)/3;
        %计算捐赠区域到采血的平均到达率
        % 到达率
        arr = parameter.arrRate(i,:);
        lamda_ij = arr * G_i * G_j * H_ij;
        collection_rate_t(collection_rate_index) = collection_rate_t(collection_rate_index) + lamda_ij;
    end
    
    % 判断是否满足系统稳定性约束
    % 1.1 获取服务器 
    ser_num = zeros(1,location_num);
    ser_num(mobile_index) = Car(2,:);
    ser_num(fix_index) = Room(2,index_1);
    % 1.2 Rho到达率
    Rho_t = zeros(1,location_num);
    for i = 1 : location_num
        if(ser_num(:,i)>0)
            Rho_t(:,i) = collection_rate_t(:,i) / (ser_num(:,i) * parameter.u);
        end
    end
    if(size(find(Rho_t >= 1)) > 0)
        % 不满足约束
        flag = 0;
        return
    end
end

