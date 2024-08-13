function [hv] = HV_2D(F1obj)
    
    F(1,:) = F1obj(1,:)./100;
    F(2,:) = F1obj(2,:)./100000;
    
    ub = [5;5];
    [M, l] = size(F);% [目标数,解的个数]
    
    hypervolume_contributions = zeros(1, l);
    [sortF, Findex] = sort(F,2);
    
    Lindex = Findex(1,:); % 每个解关于第一个目标排序后的索引
    L = F(:,Lindex(1,:)); % 
    
    hypervolume_contributions(Lindex(1)) = 5;
    hypervolume_contributions(Lindex(l)) = 5;
    for i = 2 : l - 1
		hypervolume_contributions(Lindex(i)) = (L(1,i+1) - L(1,i)) * (L(2,i-1) - L(2,i));
    end
    
    hv = sum(hypervolume_contributions);
end