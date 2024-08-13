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

%% 灰狼优化算法参数
Archive_size=200;   % 存储大小
alpha=0.1;  % 网格膨胀参数
nGrid=10;   % 每个维度的网格数
beta=4;     % 领导选择压力参数
gamma=2;    % 额外（待删除）存储库成员选择压力 

%% part_1
% 创建空种群
GreyWolves = CreateEmptyParticle(popsize);
for i = 1 : popsize
    GreyWolves(i).Velocity = 0;
    GreyWolves(i).Position = zeros(1,dim);
    % 个体
    GreyWolves(i).Position = initial_pop(1); 
    % 目标
    if test(GreyWolves(i).Position)
        GreyWolves(i).Cost = objective(GreyWolves(i).Position);
    else
        GreyWolves(i).Cost = [inf,inf];
    end
    % 最优个体
    GreyWolves(i).Best.Position = GreyWolves(i).Position;
    % 最优个体的目标
    GreyWolves(i).Best.Cost = GreyWolves(i).Cost;
end

%% part_2
% 得到种群个体间的支配关系
GreyWolves=DetermineDomination(GreyWolves);
% 非支配解放入外部档案
Archive=GetNonDominatedParticles(GreyWolves);
% 获取外部档案的目标
Archive_costs = GetCosts(Archive);
% 创造超立方空间
G=CreateHypercubes(Archive_costs,nGrid,alpha);

for i = 1 : numel(Archive)
    [Archive(i).GridIndex,Archive(i).GridSubIndex] = GetGridIndex(Archive(i),G);
end

%% part_3
for it = 1 : Max_iter
    % 参数rep2
    a=2-it*((2)/Max_iter);
    
    % 迭代每个个体
    for g = 1 : popsize
       
        clear rep2
        clear rep3
        % 选择alpha,beta,delta灰狼
        Delta = SelectLeader(Archive,beta);
        Beta = SelectLeader(Archive,beta);
        Alpha = SelectLeader(Archive,beta);
        
        % 如果最不拥挤的群体中的解少于三个，则第二个最不拥挤的群体也可以选择其他领导者。
        if size(Archive,1) > 1
            counter=0;
            for newi = 1 : size(Archive,1)
                if sum(Delta.Position~=Archive(newi).Position)~=0
                    counter = counter + 1;
                    rep2(counter,1) = Archive(newi);
                end
            end
            Beta = SelectLeader(rep2,beta);
        end
        % 如果第二个最不拥挤的群体有一个解，则此场景是相同的，因此应从第三个最不拥挤的群体中选择delta领导者。 
        if size(Archive,1) > 2
            counter=0;
            for newi=1:size(rep2,1)
                if sum(Beta.Position~=rep2(newi).Position)~=0
                    counter=counter+1;
                    rep3(counter,1)=rep2(newi);
                end
            end
            Alpha=SelectLeader(rep3,beta);
        end
        
        c=2.*rand(1, dim);
        D=abs(c.*Delta.Position-GreyWolves(g).Position);
        A=2.*a.*rand(1, dim)-a;
        X1=Delta.Position-A.*abs(D);
        c=2.*rand(1, dim);
        D=abs(c.*Beta.Position-GreyWolves(g).Position);
        A=2.*a.*rand()-a;
        X2=Beta.Position-A.*abs(D);
        c=2.*rand(1, dim);
        D=abs(c.*Alpha.Position-GreyWolves(g).Position);
        A=2.*a.*rand()-a;
        X3=Alpha.Position-A.*abs(D);
        % 新个体
        new_individual = [X1;X2;X3];
        %% 解修正，在范围内
        x = modify(mean(new_individual));
        GreyWolves(g).Position = x;
        if test(x)
            GreyWolves(g).Cost = objective(GreyWolves(g).Position)';%转换成列向量
        else
            GreyWolves(g).Cost = [inf;inf];
        end
    end
    GreyWolves=DetermineDomination(GreyWolves);
    non_dominated_wolves=GetNonDominatedParticles(GreyWolves);
    Archive=[Archive
        non_dominated_wolves];

    % 外部档案自己更新（去掉档案中被支配的解）
    Archive = DetermineDomination(Archive);
    Archive = GetNonDominatedParticles(Archive);
    
    for i=1:numel(Archive)
        [Archive(i).GridIndex,Archive(i).GridSubIndex]=GetGridIndex(Archive(i),G);
    end
    
    if numel(Archive)>Archive_size
        EXTRA = numel(Archive)-Archive_size;
        Archive = DeleteFromRep(Archive,EXTRA,gamma);
        Archive_costs = GetCosts(Archive);
        G = CreateHypercubes(Archive_costs,nGrid,alpha);
    end

    disp(['In iteration ' num2str(it) ': Number of solutions in the archive = ' num2str(numel(Archive))]);
    
    for a = 1 : 1 : size(Archive,1)
        Archive(a).Cost = Archive(a).Cost(:);
    end
    Archive_costs = GetCosts(Archive);
    %save('MOGWO.mat','Archive_costs','Archive');
    %% 绘图
    plotpp(Archive_costs);
    pause(0.01);
end
%save result
toc
time = toc;
disp(['运行时间: ',num2str(toc)]);
%hv = HV(Archive_costs);
hv = HV_2D(Archive_costs);
save('基本算例/MOGWO.mat','Archive','Archive_costs','time','hv');