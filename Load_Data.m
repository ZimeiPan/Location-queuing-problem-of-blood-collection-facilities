function parameter = Load_Data()
    parameter=struct();

    % Donation Point Information
    donation_risk = xlsread('./data/Donor point risk assessment value.xlsx');
    donation_info = xlsread("./data/Donation point arrival rate.xlsx");
    parameter.arrRate = donation_info(:,1);
    parameter.donation_risk = donation_risk;


    % Mobile blood donation carts and fixed blood donation houses
    mobile_risk = xlsread('./data/Risk assessment values for mobile blood donation vehicles.xlsx');
    fixed_risk = xlsread('./data/Risk Assessment Value for Fixed Blood Donation Houses.xlsx');
    parameter.mobile_risk = mobile_risk';
    parameter.fixed_risk = fixed_risk;
    location_risk = [mobile_risk',fixed_risk]; 
    parameter.location_risk = location_risk;

    parameter.max_mobile_vehicle_num = 15;         % Maximum number of mobile blood donation vehicles available
    fix_room_num = size(fixed_risk,2);
    parameter.fix_room_num = fix_room_num;         % Number of fixed blood donation houses
    parameter.max_mob_ser_num = 4;                 % Maximum number of service desks for mobile blood donors
    parameter.max_fix_ser_num = 6;                 % Number of maximum service desks in fixed blood donation houses

    parameter.period = 7;  
    parameter.u = 21;       % service rate


    % distance matrix
    distance_matrix = xlsread('./data/distance_list.xlsx');
    parameter.distance_matrix = distance_matrix;

    MinValue = [-1*ones(1,parameter.fix_room_num),-1*ones(1,parameter.max_mobile_vehicle_num)...
                    ones(1,parameter.fix_room_num),ones(1,parameter.max_mobile_vehicle_num)];
    MaxValue = [ones(1,parameter.fix_room_num),ones(1,parameter.max_mobile_vehicle_num)...
                    parameter.max_fix_ser_num*ones(1,parameter.fix_room_num),parameter.max_mob_ser_num*ones(1,parameter.max_mobile_vehicle_num)];
    parameter.MinValue = MinValue;
    parameter.MaxValue = MaxValue;
    

    % Index of the collection points available for each cycle
    [mobile_filter_index,fixed_filter_risk] = risk_filter(parameter.mobile_risk,parameter.fixed_risk);
    parameter.mobile_filter_index = mobile_filter_index;
    parameter.fixed_filter_risk = fixed_filter_risk;
    

    %% Other parameters
    % Cost of loss
    parameter.C_l = 100;
    % Open costs
    parameter.C_j = 500;
    parameter.C_k = 1000;
    % Server unit cost
    parameter.C_u = 200;
    % Protection costs at different risk levels
    parameter.C_r = [400,600,800];
    % Maximum Distance - Finds the maximum value among all distances
    parameter.max_distance = max(distance_matrix,[],'all');
end

function [mboile_filter_index,fixed_filter_risk] = risk_filter(mboile_risk,fixed_risk)
    % Screen the indexes available for mobile donor carts and fixed donor houses
    period = size(mboile_risk,1);
    for t = 1 : period
        [~,mobile_row] = find(mboile_risk(t,:) < 3);
        mboile_filter_index(t).index = mobile_row;
        [~,fix_row] = find(fixed_risk(t,:) < 3);
        fixed_filter_risk(t).index = fix_row;
    end
end

