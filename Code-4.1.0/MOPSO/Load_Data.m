function parameter = Load_Data()
    parameter=struct();

    %% 捐赠点信息
    donation_risk = xlsread('excel_real_40/捐赠点风险评估值.xlsx');
    % 平均到达率
    donation_info = xlsread("excel_real_40/捐赠点到达率.xlsx");
    % 到达率
    parameter.arrRate = donation_info(:,1);
    % 风险
    parameter.donation_risk = donation_risk;

    %% 移动献血车和固定献血屋
    mobile_risk = xlsread('excel_real_40/移动献血车风险评估值.xlsx');
    fixed_risk = xlsread('excel_real_40/固定献血屋风险评估值.xlsx');
    parameter.mobile_risk = mobile_risk';%[周期，数量]
    parameter.fixed_risk = fixed_risk;
    location_risk = [mobile_risk',fixed_risk]; % 周期*候选点
    parameter.location_risk = location_risk;

    parameter.max_mobile_vehicle_num = 15;         % 最大可用移动献血车数量
    fix_room_num = size(fixed_risk,2);
    parameter.fix_room_num = fix_room_num;         % 固定献血屋数量
    parameter.max_mob_ser_num = 4;                 % 移动献血车最大的服务台的数量
    parameter.max_fix_ser_num = 6;                 % 固定献血屋最大的服务台的数量

    parameter.period = 7;   % 周期
    parameter.u = 21;       % 服务率

    % 距离矩阵-捐赠点到采血点的距离
    distance_matrix = xlsread('excel_real_40/distance_list.xlsx');
    parameter.distance_matrix = distance_matrix;

    %% 取值的最小值与最大值
%     MinValue = [eps*ones(1,parameter.fix_room_num),-0.8*ones(1,parameter.max_mobile_vehicle_num)...
%                     ones(1,parameter.fix_room_num)-0.5,ones(1,parameter.max_mobile_vehicle_num)-0.5];
%     MaxValue = [ones(1,parameter.fix_room_num),ones(1,parameter.max_mobile_vehicle_num)...
%                     parameter.max_fix_ser_num*ones(1,parameter.fix_room_num)+0.5-eps,parameter.max_mob_ser_num*ones(1,parameter.max_mobile_vehicle_num)+0.5-eps];
    MinValue = [-1*ones(1,parameter.fix_room_num),-1*ones(1,parameter.max_mobile_vehicle_num)...
                    ones(1,parameter.fix_room_num),ones(1,parameter.max_mobile_vehicle_num)];
    MaxValue = [ones(1,parameter.fix_room_num),ones(1,parameter.max_mobile_vehicle_num)...
                    parameter.max_fix_ser_num*ones(1,parameter.fix_room_num),parameter.max_mob_ser_num*ones(1,parameter.max_mobile_vehicle_num)];
    parameter.MinValue = MinValue;
    parameter.MaxValue = MaxValue;
    
    %% 每周期可用的采血点的索引
    [mobile_filter_index,fixed_filter_risk] = risk_filter(parameter.mobile_risk,parameter.fixed_risk);
    parameter.mobile_filter_index = mobile_filter_index;
    parameter.fixed_filter_risk = fixed_filter_risk;
    
    %%其他参数
    % 损失成本
    parameter.C_l = 100;
    % 开放成本
    parameter.C_j = 500;
    parameter.C_k = 1000;
    % 服务器单位成本
    parameter.C_u = 200;
    % 不同风险等级下的防护成本
    parameter.C_r = [400,600,800];
    % 最大距离-找到所有距离中的最大值
    parameter.max_distance = max(distance_matrix,[],'all');
end

