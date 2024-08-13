clear;
clc
tic

global parameter dim_t dim popmax popmin
parameter = Load_Data();

popsize = 100;
dim_t = length(parameter.MinValue); % 维度
dim = dim_t * parameter.period;
popmax = 1;
popmin = 0;
Max_iter = 800; % 迭代次数

%% 多目标猩猩优化算法参数
Archive_size=200;   % 存储大小
alpha=0.1;  %网格膨胀参数
nGrid=10;   %每个维度的网格数
beta=4;     %领导选择压力参数
gamma=2;    %额外（待删除）存储库成员选择压力

%% part_1
% 创建空种群
Chimps = CreateEmptyParticle(popsize);
for i = 1 : popsize
    Chimps(i).Velocity = 0;
    Chimps(i).Position = zeros(1,dim);
    % 个体
    Chimps(i).Position = initial_pop(1); 
    % 目标
    if test(Chimps(i).Position)
        Chimps(i).Cost = objective(Chimps(i).Position);
    else
        Chimps(i).Cost = [inf,inf];
    end
    % 最优个体
    Chimps(i).Best.Position = Chimps(i).Position;
    % 最优个体的目标
    Chimps(i).Best.Cost = Chimps(i).Cost;
end

%% part_2
% 得到种群个体间的支配关系
Chimps=DetermineDomination(Chimps);
% 非支配解放入外部档案
Archive = GetNonDominatedParticles(Chimps);
% 获取外部档案的目标
Archive_costs = GetCosts(Archive);
% 创造超立方空间
G = CreateHypercubes(Archive_costs,nGrid,alpha);

for i = 1 : numel(Archive)
    [Archive(i).GridIndex,Archive(i).GridSubIndex] = GetGridIndex(Archive(i),G);
end

%% part_3
for it = 1 : Max_iter
    % 一些参数设置
    f = 2-it*((2)/Max_iter);    % 线性收敛因子
    
    % f的动态系数
    %Group 1
    C1G1=1.95-((2*it^(1/3))/(Max_iter^(1/3)));
    C2G1=(2*it^(1/3))/(Max_iter^(1/3))+0.5;
        
    %Group 2
    C1G2= 1.95-((2*it^(1/3))/(Max_iter^(1/3)));
    C2G2=(2*(it^3)/(Max_iter^3))+0.5;
    
    %Group 3
    C1G3=(-2*(it^3)/(Max_iter^3))+2.5;
    C2G3=(2*it^(1/3))/(Max_iter^(1/3))+0.5;
    
    %Group 4
    C1G4=(-2*(it^3)/(Max_iter^3))+2.5;
    C2G4=(2*(it^3)/(Max_iter^3))+0.5;
    
    %迭代每个个体
    for i = 1 : popsize
        clear rep2
        clear rep3
        clear rep4
        
        % 选择Attacker、Barrier、Chaser与Driver
        Attacker = SelectLeader(Archive,beta);
        Barrier = SelectLeader(Archive,beta);
        Chaser = SelectLeader(Archive,beta);
        Driver = SelectLeader(Archive,beta);
        
        % 如果最不拥挤的群体中的解少于四个，则第二个最不拥挤的群体也可以选择其他领导者。
        if size(Archive,1) > 1
            counter = 0;
            for newi = 1 : size(Archive,1)
                % 外部档案中排除最差解选择一个解
                if sum(Driver.Position~=Archive(newi).Position)~=0
                    counter = counter + 1;
                    rep2(counter,1) = Archive(newi);
                end
            end
            Chaser = SelectLeader(rep2,beta);
        end
        % 如果第二个最不拥挤的群体有一个解，则此场景是相同的，因此应从第三个最不拥挤的群体中选择Barrier 
        if size(Archive,1) > 2
            counter = 0;
            for newi = 1:size(rep2,1)
                if sum(Chaser.Position~=rep2(newi).Position)~=0
                    counter = counter+1;
                    rep3(counter,1) = rep2(newi);
                end
            end
            Barrier = SelectLeader(rep3,beta);
        end
        %  如果第三个最不拥挤的群体有一个解，则此场景是相同的，因此应从第四个最不拥挤的群体中选择Attacker 
        if size(Archive,1) > 3
            counter = 0;
            for newi = 1:size(rep3,1)
                if sum(Barrier.Position~=rep3(newi).Position)~=0
                    counter = counter+1;
                    rep4(counter,1) = rep3(newi);
                end
            end
            Attacker = SelectLeader(rep4,beta);
        end
        % 四种猩猩的两个系数
        r11=C1G1*rand(1,dim); % r1 is a random number in [0,1]
        r12=C2G1*rand(1,dim); % r2 is a random number in [0,1]
        
        r21=C1G2*rand(1,dim); % r1 is a random number in [0,1]
        r22=C2G2*rand(1,dim); % r2 is a random number in [0,1]
        
        r31=C1G3*rand(1,dim); % r1 is a random number in [0,1]
        r32=C2G3*rand(1,dim); % r2 is a random number in [0,1]
        
        r41=C1G4*rand(1,dim); % r1 is a random number in [0,1]
        r42=C2G4*rand(1,dim); % r2 is a random number in [0,1]
        
        % 选择各种混沌值
        m=chaos(3,1,1); 
        % Attacker
        A1=2*f*r11-f;
        C1=2*r12; 
        D_Attacker = abs(C1.*Attacker.Position - (m*Chimps(i).Position));
        X1 = Attacker.Position - A1.*D_Attacker;
        % Barrier
        A2=2*f*r21-f;
        C2=2*r22;
        D_Barrier=abs(C2.*Barrier.Position-(m*Chimps(i).Position));
        X2 = Barrier.Position - A2.*D_Barrier;
        % Chaser
        A3=2*f*r31-f; 
        C3=2*r32;
        D_Driver=abs(C3.*Chaser.Position-(m*Chimps(i).Position));
        X3=Chaser.Position - A3.*D_Driver; 
        % Driver
        A4=2*f*r41-f;
        C4=2*r42; 
        D_Driver=abs(C4.*Driver.Position-(m*Chimps(i).Position));
        X4 = Chaser.Position - A4.*D_Driver; % Equation (7)
        % 新个体
        new_individual = [X1;X2;X3;X4];
        % 解修正，在范围内
        x = modify(mean(new_individual));
        
        
        Chimps(i).Position = x;
        if test(x)
            Chimps(i).Cost = objective(Chimps(i).Position);
        else
            Chimps(i).Cost = [inf,inf];
        end
        Chimps(i).Cost = (Chimps(i).Cost)';%转置成列向量
        
    end
    Chimps = DetermineDomination(Chimps);
    non_dominated_chimps=GetNonDominatedParticles(Chimps);
    Archive=[Archive
        non_dominated_chimps];
    % 外部档案自己更新（去掉档案中被支配的解）
    Archive = DetermineDomination(Archive);
    Archive = GetNonDominatedParticles(Archive);
    for i=1:numel(Archive)
        [Archive(i).GridIndex,Archive(i).GridSubIndex]=GetGridIndex(Archive(i),G);
    end    
    if numel(Archive) > Archive_size
        EXTRA = numel(Archive) - Archive_size;
        Archive = DeleteFromRep(Archive,EXTRA,gamma);
        Archive_costs = GetCosts(Archive);
        G = CreateHypercubes(Archive_costs,nGrid,alpha);
    end
    disp(['In iteration ' num2str(it) ': Number of solutions in the archive = ' num2str(numel(Archive))]);
    costs = GetCosts(Chimps);
    for a = 1 : 1 : size(Archive,1)
        Archive(a).Cost = Archive(a).Cost(:);
    end
    Archive_costs = GetCosts(Archive);
    %save('MOChOA.mat','Archive_costs','Archive');
    %% 绘图
    plotpp(Archive_costs);
    pause(0.01);
end
%save('MOChOA.mat','Archive_costs','Archive','time');
toc
time = toc;
disp(['运行时间: ',num2str(toc)]);
hv = HV_2D(Archive_costs);
save('基本算例\MOChOA.mat','Archive_costs','Archive','time','hv');




