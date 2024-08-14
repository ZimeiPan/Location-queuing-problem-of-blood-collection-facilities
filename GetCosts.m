function costs=GetCosts(pop)
    % Reconstruction of solutions in external archives
    nobj = numel(pop(1).Cost);
    costs = reshape([pop.Cost],nobj,[]);
end