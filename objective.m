function individual_obj = objective(individual)
    % Calculate the fitness value
    global parameter dim_t
    individual_obj1 = zeros(1,parameter.period);
    individual_obj2 = zeros(1,parameter.period);

    Room={};Car={};
    % The number of traversal periods
    for t = 1 : parameter.period
        % Get the solution for each period
        x_t = individual(1,(t-1)*dim_t+1:t*dim_t);
        % The opening of the blood collection point and the service desk for each period of each solution
        [Room{t},Car{t}] = Amend_t(x_t,parameter.fixed_filter_risk(t).index,parameter.mobile_filter_index(t).index);
        % Calculate the objective value for each period
        [t_obj1,t_obj2] = obj_cal(Room{t},Car{t},t);
        % objective1
        individual_obj1(:,t) = t_obj1;
        % objective2
        individual_obj2(:,t) = t_obj2;
    end

    individual_obj1 = sum(individual_obj1);
    individual_obj2 = sum(individual_obj2);
    individual_obj = [individual_obj1,individual_obj2];  
end

% Calculate the objective function
function [t_obj1,t_obj2] = obj_cal(Room,Car,t)
    global parameter
    
    t_obj1 = 0;
    t_obj2 = 0;
    
    obj_l = 0;  % loss Cost
    obj_j = 0;  % Open costs
    obj_u = 0;  % Service Desk Costs
    obj_r = 0;  % risk protection Cost
    
    mobile_num = size(parameter.mobile_risk,2);
    fix_num = size(parameter.fixed_risk,2);
    location_num = mobile_num + fix_num;

    % The closest blood collection point for each donor site, based on the openness of the solution
    mobile_index = parameter.mobile_filter_index(t).index(Car(1,:));
    index_1 = find(Room(1,:) == 1);


    %% Fixed cost of opening facilities
    % Mobile Blood Donation Vehicle
    for i = 1 : size(mobile_index,2)
        % Open costs
        obj_j = obj_j + parameter.C_j;
        % Service Desk Costs
        obj_u = obj_u + parameter.C_u * Car(2,i);
        % risk protection Cost
        risk_1 = parameter.mobile_risk(t,mobile_index(i));
        obj_r = obj_r + parameter.C_r(risk_1);
    end

    % Fixed Blood Donation House
    for i = 1 : size(index_1,2)
        % Open costs
        obj_j = obj_j + parameter.C_k;
        % Service Desk Costs
        obj_u = obj_u + parameter.C_u * Room(2,i);
        % risk protection Cost
        risk_2 = parameter.fixed_risk(t,index_1(i));
        obj_r = obj_r + parameter.C_r(risk_2);
    end
    fix_index = index_1 + mobile_num;
    % Open the facility index
    index = [mobile_index,fix_index];
    
    
    % Find the smallest index assigned by the donation point
    % V：shortest distance  I:index
    [V,I] = min(parameter.distance_matrix(:,index),[],2); 
    

    %% Calculate the probability of arrival at each blood collection point
    collection_rate_t = zeros(1,location_num);
    donation_loss_rate_t = zeros(1,size(parameter.donation_risk,1));
    for i = 1 : size(parameter.donation_risk,1)
        collection_rate_index = index(I(i,:));
        distance = V(i,:);
        H_ij = 1 - distance/parameter.max_distance;
        %H_ij = max(0,1 - distance/15);
        G_i = 1 - parameter.donation_risk(i,t)/3;
        G_j = 1 - parameter.location_risk(t,collection_rate_index)/3;

        % Calculate average arrival rate from donor area to blood collection
        % Arrival rate
        arr = parameter.arrRate(i,:);
        lamda_ij = arr * G_i * G_j * H_ij;
        arr_i_loss = arr - lamda_ij;
        donation_loss_rate_t(1,i) = arr_i_loss;
        collection_rate_t(collection_rate_index) = collection_rate_t(collection_rate_index) + lamda_ij;
    end
    % Cost of loss
    obj_l = parameter.C_l * sum(donation_loss_rate_t,'all');

    %% Calculate the lambda of the blood collection point
    ser_num = zeros(1,location_num);
    ser_num(mobile_index) = Car(2,:);
    ser_num(fix_index) = Room(2,index_1);
    Rho_t = zeros(1,location_num);
    for i = 1 : location_num
        if(ser_num(:,i)>0)
            Rho_t(:,i) = collection_rate_t(:,i) / (ser_num(:,i) * parameter.u);
        end
    end
    
    individual_obj1 = zeros(1,location_num);
    %% Objective 1
    for i = 1 : location_num
        if(Rho_t(:,i) ~= 0)
            [~,~,~,~,~,~,W_s] = mmc_queueing(collection_rate_t(:,i),parameter.u,ser_num(:,i),1);
            individual_obj1(:,i) = collection_rate_t(:,i) * W_s;
        end
    end
    t_obj1 = sum(individual_obj1,'all');
    % Open cost + loss cost + service desk cost + risk protection cost
    t_obj2 = obj_j + obj_l + obj_u + obj_r;
end