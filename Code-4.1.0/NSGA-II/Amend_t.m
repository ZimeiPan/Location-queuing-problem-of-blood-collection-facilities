function [Room,Car] = Amend_t(x_t,fixed_filter_risk,mobile_filter_index)
    
    global parameter 
    
    location_num = parameter.fix_room_num + parameter.max_mobile_vehicle_num;
    
    % 确保在自变量范围内
    % 归一化
    X = parameter.MinValue + (parameter.MaxValue-parameter.MinValue).*x_t;
    
    %% 获取数据
    % 固定献血屋
    x_1 = X(1:parameter.fix_room_num);
    % 移动献血车
    x_2 = X(parameter.fix_room_num+1:location_num);
    % 固定献血屋服务台
    x_3 = X(location_num+1:location_num+parameter.fix_room_num);
    % 移动献血车服务台
    x_4 = X(location_num+parameter.fix_room_num+1:end);

    %% 解码
    %Room(1,:) = round(x_1);
    for i = 1 : size(x_1,2)
        if x_1(1,i) <= 0
            Room(1,i) = 0;
        else
            Room(1,i) = 1;
        end
    end
    % 容易出错，应把每个周期满足条件的点输进去
    keyongshu = size(mobile_filter_index,2);
    Car(1,:) = ToPoint(x_2,keyongshu);
    Room(2,:) = round(x_3);
    Car(2,:) = round(x_4);

    %% 服务台-未开放的服务台为0
    %% 移动献血车的设置
    index=find(Car(1,:)==0);
    Car(:,index)=[];
    [~,index]=sort(Car(1,:));
    Car=Car(:,index);

    %% 固定献血屋的设置-将不满足风险的点设为0
    for i = 1 : size(Room,2)
        if (ismember(i,fixed_filter_risk)) && (Room(1,i) ~= 0)
            continue;
        else if Room(1,i)==0
            % 固定献血不开放，则服务台数目为0
            Room(2,i) = 0;
        else    
            % inf表示此地献血点不开放
            Room(:,i) = 0;
        end
    end
end

