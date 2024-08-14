function [Room,Car] = Amend_t(x_t,fixed_filter_risk,mobile_filter_index)
    
    global parameter 
    
    location_num = parameter.fix_room_num + parameter.max_mobile_vehicle_num;
    
    % Ensure that it is within the range of the independent variable
    % normalize
    X = parameter.MinValue + (parameter.MaxValue-parameter.MinValue).*x_t;
    
    %% Getting data
    % Fixed Blood Donation House
    x_1 = X(1:parameter.fix_room_num);
    % Mobile Blood Donation Vehicle
    x_2 = X(parameter.fix_room_num+1:location_num);
    % Fixed Blood Donation House Service Counter
    x_3 = X(location_num+1:location_num+parameter.fix_room_num);
    % Mobile Blood Donor Counter
    x_4 = X(location_num+parameter.fix_room_num+1:end);

    %% decoder
    for i = 1 : size(x_1,2)
        if x_1(1,i) <= 0
            Room(1,i) = 0;
        else
            Room(1,i) = 1;
        end
    end

    keyongshu = size(mobile_filter_index,2);
    Car(1,:) = ToPoint(x_2,keyongshu);
    Room(2,:) = round(x_3);
    Car(2,:) = round(x_4);

    % Helpdesk - 0 for unopened helpdesk
    % Mobile Blood Donation Vehicle Setup
    index=find(Car(1,:)==0);
    Car(:,index)=[];
    [~,index]=sort(Car(1,:));
    Car=Car(:,index);

    % Fixed blood donation house setup - set points that do not meet the risk to 0
    for i = 1 : size(Room,2)
        if (ismember(i,fixed_filter_risk)) && (Room(1,i) ~= 0)
            continue;
        elseif Room(1,i)==0
            % The number of service desks is 0 if fixed blood donation is not open
            Room(2,i) = 0;
        else    
            Room(:,i) = 0;
        end
    end
end

% Decoding of mobile blood donation vehicles
function tr=ToPoint(x,number)
    n=1:number;
    tr=x;
    for i=1:length(x)
        if x(i)<=0
            tr(i)=0;
        else
            ch=ceil(x(i)*length(n));
            tr(i)=n(ch);
            n(ch)=[];
        end
    end
end
