function [t_obj1,t_obj2] = obj_cal(Room,Car,t)
    global parameter
    
    %% 参数设置
    t_obj1 = 0;
    t_obj2 = 0;
    
    obj_l = 0;  % 损失成本
    obj_j = 0;  % 开放成本
    obj_u = 0;  % 服务器成本
    obj_r = 0;  % 风险防护成本
    
    mobile_num = size(parameter.mobile_risk,2);
    fix_num = size(parameter.fixed_risk,2);
    location_num = mobile_num + fix_num;

    %% 根据解的开放情况，得出每个捐赠点距离最近的采血点
    % 移动索引
    mobile_index = parameter.mobile_filter_index(t).index(Car(1,:));
    % 固定索引 
    index_1 = find(Room(1,:) == 1);
    
    %% 设施开放固定成本
    % 移动献血车
    for i = 1 : size(mobile_index,2)
        % 开放成本
        obj_j = obj_j + parameter.C_j;
        % 服务台成本
        obj_u = obj_u + parameter.C_u * Car(2,i);
        % 风险防护成本
        risk_1 = parameter.mobile_risk(t,mobile_index(i));
        obj_r = obj_r + parameter.C_r(risk_1);
    end
    % 固定献血屋
    for i = 1 : size(index_1,2)
        % 开放成本
        obj_j = obj_j + parameter.C_k;
        % 服务台成本
        obj_u = obj_u + parameter.C_u * Room(2,i);
        % 风险防护成本
        risk_2 = parameter.fixed_risk(t,index_1(i));
        obj_r = obj_r + parameter.C_r(risk_2);
    end
    % 先移动献血车，后固定献血屋
    fix_index = index_1 + mobile_num;
    % 开放设施点索引
    index = [mobile_index,fix_index];
    
    
    %% 开放设置
    % 找到捐赠点分配的最小的索引
    % V：最短的距离 I:索引
    utility_matrix = distribution(parameter,t);
    %[V,I] = min(parameter.distance_matrix(:,index),[],2); 
    [V,I] = min(utility_matrix(:,index),[],2);
    
    %% 计算每个采血点的到达概率
    collection_rate_t = zeros(1,location_num);
    % 损失率保存，将由于高风险而导致的封闭也给算进去了
    donation_loss_rate_t = zeros(1,size(parameter.donation_risk,1));
    % 遍历每个捐赠点
    for i = 1 : size(parameter.donation_risk,1)
        % 采血点索引
        collection_rate_index = index(I(i,:));
        % 距离-到到达最近的采血点
        %distance = V(i,:);
        distance = parameter.distance_matrix(i,collection_rate_index);
        % 距离敏感因子
        H_ij = 1 - distance/parameter.max_distance;
        % 距离敏感因子-最远接受距离为15km
        %H_ij = max(0,1 - distance/15);
        
        % 捐赠区域风险敏感因子
        G_i = 1 - parameter.donation_risk(i,t)/3;
        % 对采血点的风险敏感因子
        G_j = 1 - parameter.location_risk(t,collection_rate_index)/3;
        %计算捐赠区域到采血的平均到达率
        % 到达率
        arr = parameter.arrRate(i,:);
        lamda_ij = arr * G_i * G_j * H_ij;
        arr_i_loss = arr - lamda_ij;
        donation_loss_rate_t(1,i) = arr_i_loss;
        collection_rate_t(collection_rate_index) = collection_rate_t(collection_rate_index) + lamda_ij;
    end
    % 损失成本
    obj_l = parameter.C_l * sum(donation_loss_rate_t,'all');

    %% 计算血液采集点的拉姆达
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
    
    individual_obj1 = zeros(1,location_num);
    %% 目标1：排队时间满意度-逗留时间最短
    for i = 1 : location_num
        if(Rho_t(:,i) ~= 0)
            % 逗留时间
            [~,~,~,~,~,~,W_s] = mmc_queueing(collection_rate_t(:,i),parameter.u,ser_num(:,i),1);
            % 目标1
            individual_obj1(:,i) = collection_rate_t(:,i) * W_s;
        end
    end
    % 逗留时间最短
    t_obj1 = sum(individual_obj1,'all');
    % 开放成本 + 损失成本 + 服务台成本 + 风险防护成本
    t_obj2 = obj_j + obj_l + obj_u + obj_r;
end

