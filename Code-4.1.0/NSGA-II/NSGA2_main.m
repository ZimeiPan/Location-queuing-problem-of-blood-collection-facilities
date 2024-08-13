clear all
clc
tic

%% 参数调用
global parameter dim_t dim popmax popmin
parameter = Load_Data();

dim_t = length(parameter.MinValue); % 维度
dim = dim_t * parameter.period;
popmax = 1;
popmin = 0;

%% code starts
% 遗传算法参数
popsize = 200;  % 种群大小
no_runs = 1;    % 循环次数
pc = 0.9;
gen_max = 400;  % 最大迭代次数
pm= 0.1;        % 变异概率
%子代种群规模大小，偶数化处理
nc = round(pc*popsize/2)*2;

%% 初始化种群
pop = initial_pop(popsize);

for p = 1 : popsize
    if test(pop(p,:))
        pop_obj(p,:) = objective(pop(p,:));
    else
        pop_obj(p,:) = [inf,inf];
    end
end

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
    % 变成列的形式
    population(p).obj = [x;y];
    population(p).value = pop(p,:);
end

%非支配排序
% F-每个层级的个数
[population,F] = nondominatedsort(population);
% 拥挤度计算
population = calcrowdingdistance(population,F);

%% 主循环
for it = 1 : gen_max
    popc = repmat(empty, popsize/2,2);
    %popc = repmat(empty, nc/2,2);
    % 二元锦标赛选择
    %交叉
    for j=1:popsize/2
       p1 = tournamentsel(population);
       p2 = tournamentsel(population);
       [popc(j,1).value, popc(j,2).value] = crossover(p1.value,p2.value,pc);
    end
    popc = popc(:);
    %变异,并计算目标函数值
    for p=1:popsize
        popc(p).value = mutate(popc(p).value,pm);
        if test(popc(p).value)
            popc(p).obj = objective(popc(p).value)';%转置成列向量
        else
            popc(p).obj = [inf;inf];
        end
    end
    
    %合并种群，并重新计算非支配等级和拥挤度
    newpop = [population; popc];
    [population,F] = nondominatedsort(newpop);
    population = calcrowdingdistance(population,F);
    %排序
    population = Sortpop(population);
    population = population(1: popsize);
    [population,F] = nondominatedsort(population);
    population = calcrowdingdistance(population,F);
    population = Sortpop(population);

    % 更新第1等级
    F1 = population(F{1});
    for f=1:1:size(F1,1)
        F1obj(f,:) = (F1(f).obj)';
    end
    F1obj = unique(F1obj,'rows');
    %save('NSGA.mat','F1','F1obj');
    % 层级
    a = size(F,2);
    disp(['Iteration ' num2str(it) ': Number of F1 Members = ' num2str(numel(F1)) '非支配等级 ' num2str(a)]);
     % 绘图
    plotpp(F1);
    pause(0.01);
end
toc
disp(['运行时间: ',num2str(toc)]);
time = toc;
hv = HV_2D(F1obj);
save('200-400/NSGA.mat','F1','F1obj','time','hv');
