function [mboile_filter_index,fixed_filter_risk] = risk_filter(mboile_risk,fixed_risk)
    %% 筛选移动献血车和固定献血屋可用的索引
    period = size(mboile_risk,1);
    for t = 1 : period
        [~,mobile_row] = find(mboile_risk(t,:) < 3);
        mboile_filter_index(t).index = mobile_row;
        [~,fix_row] = find(fixed_risk(t,:) < 3);
        fixed_filter_risk(t).index = fix_row;
    end
end

