clear;
clc
tic

global parameter dim_t dim popmax popmin
parameter = Load_Data();

popsize = 200;
dim_t = length(parameter.MinValue); % 维度
dim = dim_t * parameter.period;
popmax = 1;
popmin = 0;
Max_iter = 400; % 迭代次数


%% 初始化种群
pop = initial_pop(popsize);

%% 计算目标适应度值
for p = 1 : popsize
    if test(pop(p,:))
        pop_obj(p,:) = objective(pop(p,:));
    else
        pop_obj(p,:) = [inf,inf];
    end
end

% 初始化领导解
Leader_pos = zeros(1,dim);
Leader_score = [inf,inf];

% 每代最优解
Convergence_curve=zeros(1,Max_iter);

t=0;% Loop counter
%非支配排序准备工作
empty.value = [];
empty.obj = [];
empty.rank = [];
empty.domination = [];
empty.dominated = 0;
empty.crowdingdistance = [];
population = repmat(empty, popsize, 1);
for p = 1 : popsize
    x = pop_obj(p,1);y=pop_obj(p,2);
    population(p).obj = [x;y];
    population(p).value = pop(p,:);
end

%非支配排序
% F-每个层级的个数
[population,F] = nondominatedsort(population);
% 拥挤度计算
population = calcrowdingdistance(population,F);

while t < Max_iter
    % 根据拥挤度和距离进行排序
    population = Sortpop(population);
    popc = repmat(empty, popsize ,1);
    a = 2-t*((2)/Max_iter); 
    a2 = -1+t*((-1)/Max_iter);
    F1 = population(F{1});
    
    for i = 1:popsize
        new_individual = zeros(1,dim);
        % 在第一个支配层级随机选择一个最优解
        f = randi(numel(F1));
        leader_pop = F1(f);
        Leader_pos = leader_pop.value;
        Leader_score = leader_pop.obj;
        r1 = rand(); 
        r2 = rand(); 
        A = 2*a*r1-a;  
        C = 2*r2;      
        b = 1;               
        l = (a2-1)*rand+1;   
        p = rand();      
        for j = 1 : dim
            if p < 0.5   
                if abs(A) >= 1
                    rand_leader_index = floor(popsize*rand()+1);
                    X_rand = population(rand_leader_index).value;
                    D_X_rand = abs(C*X_rand(j) - population(i).value(1,j)); 
                    new_individual(:,j) = X_rand(j)-A*D_X_rand;      
                elseif abs(A)<1
                    D_Leader = abs(C*Leader_pos(j)-population(i).value(1,j)); 
                    new_individual(:,j)=Leader_pos(j)-A*D_Leader;     
                end
            elseif p>=0.5
                distance2Leader = abs(Leader_pos(j)-population(i).value(1,j));
                new_individual(:,j) = distance2Leader*exp(b.*l).*cos(l.*2*pi)+Leader_pos(j);
            end
        end
        %% 对每个解进行修正
        x=modify(new_individual);
        %% 判断解是否满足约束
        if test(x)
            individual_obj = objective(x);
        else
            individual_obj = [inf,inf];
        end
        popc(i).value = x;
        popc(i).obj = [individual_obj(1);individual_obj(2)];
    end
    % 合并种群，并重新计算非支配等级和拥挤度
    newpop = [population; popc];
    [population,F] = nondominatedsort(newpop);
    population = calcrowdingdistance(population,F);
    % 排序
    population = Sortpop(population);
    % 淘汰
    population = population(1: popsize);
    [population,F] = nondominatedsort(population);
    population = calcrowdingdistance(population,F);
    population = Sortpop(population);
    F1 = population(F{1});
    for f=1:1:size(F1,1)
        F1obj(f,:) = (F1(f).obj)';
    end
    F1obj = unique(F1obj,'rows');
    a = size(F,2);
    disp(['Iteration ' num2str(t+1) ': Number of F1 Members = ' num2str(numel(F1)) '非支配等级 ' num2str(a)]);
    %save('MOWOA.mat','F1','F1obj');
    % 绘图
    plotpp(F1);
    pause(0.01);
    t = t+1;
end
toc
hv = HV_2D(F1obj);
time = toc;
save('基本算例\MOWOA.mat','F1','F1obj','time','hv');