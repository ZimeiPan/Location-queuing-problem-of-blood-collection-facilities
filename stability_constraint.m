%% Determine whether system stability constraints are satisfied
function [flag] = stability_constraint(Room,Car,t)
    flag = 1;

    
    global parameter

    if (isempty(Car)) && (~any(any(Room)))
        flag = 0;
        return 
    end

    location_num = size(parameter.mobile_risk,2) + size(parameter.fixed_risk,2);
    
    % The closest blood collection point for each donor site, based on the openness of the solution
    mobile_index = parameter.mobile_filter_index(t).index(Car(1,:));
    index_1 = find(Room(1,:) == 1);
    fix_index = index_1 + size(parameter.mobile_risk,2);
    index = [mobile_index,fix_index];
    
    [V,I] = min(parameter.distance_matrix(:,index),[],2); 
    
    % Calculate the probability of arrival at each blood collection point
    collection_rate_t = zeros(1,location_num);
    % Iterate through each donation point
    for i = 1 : size(parameter.donation_risk,1)
        collection_rate_index = index(I(i,:));
        distance = V(i,:);
        H_ij = 1 - distance/parameter.max_distance;
        G_i = 1 - parameter.donation_risk(i,t)/3;
        G_j = 1 - parameter.location_risk(t,collection_rate_index)/3;
        % Arrival rate
        arr = parameter.arrRate(i,:);
        lamda_ij = arr * G_i * G_j * H_ij;
        collection_rate_t(collection_rate_index) = collection_rate_t(collection_rate_index) + lamda_ij;
    end

    % Determine whether system stability constraints are satisfied
    ser_num = zeros(1,location_num);
    ser_num(mobile_index) = Car(2,:);
    ser_num(fix_index) = Room(2,index_1);
    Rho_t = zeros(1,location_num);
    for i = 1 : location_num
        if(ser_num(:,i)>0)
            Rho_t(:,i) = collection_rate_t(:,i) / (ser_num(:,i) * parameter.u);
        end
    end
    if(size(find(Rho_t >= 1)) > 0)
        flag = 0;
        return
    end
end

