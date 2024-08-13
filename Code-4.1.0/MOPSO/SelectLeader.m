function leader = SelectLeader(rep, beta)

    % Grid Index of All Repository Members
    GI = [rep.GridIndex];
    
    % Occupied Cells：占据网格数
    OC = unique(GI);
    
    % Number of Particles in Occupied Cells 
    % 统计占据每个网格的数量
    N = zeros(size(OC));
    for k = 1:numel(OC)
        N(k) = numel(find(GI == OC(k)));
    end
    
    % Selection Probabilities 选择概率
    P = exp(-beta*N);
    P = P/sum(P);
    
    % Selected Cell Index
    sci = RouletteWheelSelection(P);
    
    % Selected Cell
    sc = OC(sci);
    
    % Selected Cell Members
    SCM = find(GI == sc);
    
    % Selected Member Index
    smi = randi([1 numel(SCM)]);
    
    % Selected Member
    sm = SCM(smi);
    
    % Leader
    leader = rep(sm);

end