function [service_strength,P_0,P_n,L_q,L_s,W_q,W_s] = mmc_queueing(arrive_rate,service_rate,c,n)
    
    % M/M/c The formula for calculating the queuing model
    if arrive_rate == 0
        service_strength = 0;
        P_0 = 1;
        P_n = 0;
        L_q = 0;
        L_s = 0;
        W_q = 0;
        W_s = 0;
    end
    
    % Service intensity
    service_strength = arrive_rate / (c * service_rate);
    a_s = arrive_rate / service_rate;
    
    % State probability
    sum_1 = 0;
    for k = 0 : (c-1)
        sum_1 = sum_1 + a_s^k/factorial(k);
    end
    sum_2 = a_s^c / (factorial(c)*(1-service_strength));
    P_0 = 1 / (sum_1 + sum_2);
    P_n = 0;
    if n <= c
        P_n = (a_s^n * P_0) /factorial(n);
    else
        P_n = (a_s^n * P_0) /(factorial(c) * c^(n-c));
    end

    % length of queues
    L_q = ((c * service_strength)^c * service_strength * P_0) / (factorial(c) * (1 - service_strength)^2);
    
    % length of stay
    L_s = L_q + a_s;

    % Wait time
    W_q = L_q / arrive_rate;

    % stay time
    W_s = L_s / arrive_rate;
end

