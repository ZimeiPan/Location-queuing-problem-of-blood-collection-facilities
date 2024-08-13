function [service_strength,P_0,P_n,L_q,L_s,W_q,W_s] = mmc_queueing(arrive_rate,service_rate,c,n)
    % m/m/c 排队模型计算公式
    % 排除某采血点到达率为0时,使用公式会计算出错
    if arrive_rate == 0
        service_strength = 0;
        P_0 = 1;
        P_n = 0;
        L_q = 0;
        L_s = 0;
        W_q = 0;
        W_s = 0;
    end
    
    % 服务强度
    service_strength = arrive_rate / (c * service_rate);
    a_s = arrive_rate / service_rate;
    
    % 状态概率
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

    % 排队长
    L_q = ((c * service_strength)^c * service_strength * P_0) / (factorial(c) * (1 - service_strength)^2);
    
    % 队长
    L_s = L_q + a_s;
    
    % 等待时间
    W_q = L_q / arrive_rate;
    
    % 逗留时间
    W_s = L_s / arrive_rate;
end

