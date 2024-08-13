clc;
clear;
close all;
tic

global parameter dim_t dim popmax popmin
parameter = Load_Data();
%% 一些基本参数
popsize = 200;
dim_t = length(parameter.MinValue); % 维度
dim = dim_t * parameter.period;
dim_size = [1 dim];
popmax = 1;
popmin = 0;
Max_iter = 400; % 迭代次数
Archive_size = 200;

w = 0.5;              % Inertia Weight 惯性权重
wdamp = 0.99;         % Intertia Weight Damping Rate
c1 = 1;               % Personal Learning Coefficient
c2 = 2;               % Global Learning Coefficient

nGrid = 10;            % Number of Grids per Dimension
alpha = 0.1;          % Inflation Rate
beta = 4;             % Leader Selection Pressure
gamma = 2;            % Deletion Selection Pressure

mu = 0.1;             % Mutation Rate

%% 初始化
empty_particle.Position = [];
empty_particle.Velocity = [];
empty_particle.Cost = [];
empty_particle.Best.Position = [];
empty_particle.Best.Cost = [];
empty_particle.IsDominated = [];
empty_particle.GridIndex = [];
empty_particle.GridSubIndex = [];

pop = repmat(empty_particle, popsize, 1);

for i = 1:popsize
    pop(i).Position = initial_pop(1);
    pop(i).Velocity = zeros(dim_size);
    if test(pop(i).Position)
        pop(i).Cost = objective(pop(i).Position)'; %需要转置一下
    else
        pop(i).Cost = [inf;inf];
    end
    % Update Personal Best
    pop(i).Best.Position = pop(i).Position;
    pop(i).Best.Cost = pop(i).Cost;
end

% 确定支配关系
pop = DetermineDomination(pop);
% 放入外部存储库
Archive = pop(~[pop.IsDominated]);
% 创建网格
Grid = CreateGrid(Archive, nGrid, alpha);
% 获取每个解在网格中的编号
for i = 1:numel(Archive)
    Archive(i) = FindGridIndex(Archive(i), Grid);
end

%% 主循环
for it = 1 : Max_iter
    for i = 1 : popsize
        % 领导者选择机制
        leader = SelectLeader(Archive, beta);
        
        pop(i).Velocity = w*pop(i).Velocity ...
            +c1*rand(dim_size).*(pop(i).Best.Position-pop(i).Position) ...
            +c2*rand(dim_size).*(leader.Position-pop(i).Position);
        pop(i).Position = pop(i).Position + pop(i).Velocity;
        %% 边界修正
        pop(i).Position = max(pop(i).Position, popmin);
        pop(i).Position = min(pop(i).Position, popmax);
        % 判断是否满足约束
        if test(pop(i).Position)
            pop(i).Cost = objective(pop(i).Position)';
        else
            pop(i).Cost = [inf;inf];
        end
       
        % 变异
        pm = (1-(it-1)/(Max_iter-1))^(1/mu);
        % 判断1
        if rand<pm
            % 判断是否满足约束
            NewSol.Position = Mutate(pop(i).Position, pm, popmin, popmax);
            if test(NewSol.Position)
                NewSol.Cost = objective(NewSol.Position)';
            else
                NewSol.Cost = [inf;inf];
            end

            if Dominates(NewSol, pop(i))
                pop(i).Position = NewSol.Position;
                pop(i).Cost = NewSol.Cost;
            elseif Dominates(pop(i), NewSol)
                % Do Nothing
            else
                if rand<0.5
                    pop(i).Position = NewSol.Position;
                    pop(i).Cost = NewSol.Cost;
                end
            end
        end

        % 判断2
        if Dominates(pop(i), pop(i).Best)
            pop(i).Best.Position = pop(i).Position;
            pop(i).Best.Cost = pop(i).Cost;
            
        elseif Dominates(pop(i).Best, pop(i))
            % Do Nothing   
        else
            if rand<0.5
                pop(i).Best.Position = pop(i).Position;
                pop(i).Best.Cost = pop(i).Cost;
            end
        end
    end
    
    % Add Non-Dominated Particles to REPOSITORY
    Archive = [Archive
         pop(~[pop.IsDominated])];
    Archive = DetermineDomination(Archive);
    % Keep only Non-Dminated Memebrs in the Repository
    % 忘了这一步
    Archive = Archive(~[Archive.IsDominated]);
    % Update Grid
    Grid = CreateGrid(Archive, nGrid, alpha);
    % Update Grid Indices
    for i = 1:numel(Archive)
        Archive(i) = FindGridIndex(Archive(i), Grid);
    end
    % Check if Repository is Full
    if numel(Archive) > Archive_size
        Extra = numel(Archive)-Archive_size;
        for e = 1:Extra
            Archive = DeleteOneRepMemebr(Archive, gamma);
        end
    end
    % Damping Inertia Weight
    w = w*wdamp;
    %save("MOPSO.mat","Archive");
    disp(['In iteration ' num2str(it) ': Number of solutions in the archive = ' num2str(numel(Archive))]);
    %% 绘图
    Archive_costs = [];
    for i = 1 : numel(Archive)
        Archive_costs = [Archive_costs,Archive(i).Cost];
    end
    plotpp(Archive_costs);
    pause(0.01);
end
toc
disp(['运行时间: ',num2str(toc)]);
time = toc;
hv = HV_2D(Archive_costs);
save("基本算例/MOPSO.mat","Archive","Archive_costs",'hv','time');