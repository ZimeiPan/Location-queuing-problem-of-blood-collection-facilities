function utility_matrix = distribution(parameter,t)
    %% 找到对于志愿者来说效用最大的捐赠点
    
    % 距离矩阵
    distance_matrix = parameter.distance_matrix;  %【捐赠点，候选点】
    % 距离敏感因子 -0.1 -0.75 -1 -1.5
    alpha = -0.1;
    % 风险敏感因子
    beta = -0.1;
    
    % 构建一个每周期的效用矩阵
    sz = size(parameter.distance_matrix);
    utility_matrix = zeros(sz);
    
    mobile_rist_t = parameter.mobile_risk(t,:);
    fix_rist_t = parameter.fixed_risk(t,:);
    risk_t = [mobile_rist_t,fix_rist_t];

    for i = 1 : size(distance_matrix,1)
        for j = 1 : size(distance_matrix,2)
            utility_matrix(i,j) = (distance_matrix(i,j)^alpha) * (risk_t(1,j)^beta); 
        end
    end

