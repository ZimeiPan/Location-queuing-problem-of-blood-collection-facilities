function costs=GetCosts(pop)
    %% 对外部档案中的解进行重构
    nobj = numel(pop(1).Cost);
    costs = reshape([pop.Cost],nobj,[]);
end