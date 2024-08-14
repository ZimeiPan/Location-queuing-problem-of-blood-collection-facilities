clear;
clc
tic

global parameter dim_t dim popmax popmin
parameter = Load_Data();

popsize = 100;
dim_t = length(parameter.MinValue); % dimension
dim = dim_t * parameter.period;
popmax = 1;
popmin = 0;
Max_iter = 1000;

% Grey Wolf Optimization Algorithm Parameters
Archive_size=100;   % Storage size
alpha = 0.1;        % Grid Inflation Parameter
nGrid = 10;         % Number of Grids per each Dimension
beta = 4;           % Leader Selection Pressure Parameter
gamma = 2;          % Extra (to be deleted) Repository Member Selection Pressure

%% Initialization
GreyWolves = CreateEmptyParticle(popsize);
Poulation = initial_pop(popsize);
for i = 1 : popsize
    GreyWolves(i).Velocity = 0;
    GreyWolves(i).Position = zeros(1,dim);
    % individual
    GreyWolves(i).Position = Poulation(i,:); 
    % constraint handle
    if test(GreyWolves(i).Position)
        GreyWolves(i).Cost = objective(GreyWolves(i).Position);
    else
        GreyWolves(i).Cost = [inf,inf];
    end
    % optimal individual
    GreyWolves(i).Best.Position = GreyWolves(i).Position;
    % The goal of the optimal individual
    GreyWolves(i).Best.Cost = GreyWolves(i).Cost;
end
% Obtaining dominance relationships between individuals of a population
GreyWolves=DetermineDomination(GreyWolves);
% Non-discretionary liberation into external files
Archive=GetNonDominatedParticles(GreyWolves);
% Objective of access to external archives
Archive_costs = GetCosts(Archive);
G=CreateHypercubes(Archive_costs,nGrid,alpha);
for i = 1 : numel(Archive)
    [Archive(i).GridIndex,Archive(i).GridSubIndex] = GetGridIndex(Archive(i),G);
end

%% main loop
for it = 1 : Max_iter
    % parameters a
    a = 2 * cos(pi*it/(2*Max_iter));

    for g = 1 : popsize
       
        clear rep2
        clear rep3
        % choose alpha,beta,delta gray wolf
        Delta = SelectLeader(Archive,beta);
        Beta = SelectLeader(Archive,beta);
        Alpha = SelectLeader(Archive,beta);
        
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
        % new individual
        new_individual = [X1;X2;X3];
        % Fix the solution in scope
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

    % The external file updates itself (removing dominated solutions from the file)
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
    F1obj = unique(Archive_costs',"rows");
    % plot
    plotpp(Archive_costs);
    pause(0.01);
end
toc
time = toc;
disp(['runtime: ',num2str(toc)]);  
nos = size(F1obj,1);
save('IMOGWO.mat','Archive','Archive_costs','F1obj','time','nos');