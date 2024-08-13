function rep_h=SelectLeader(rep,beta)
    if nargin<2
        beta=1;
    end
    % 找到索引及索引对应解的个数
    [occ_cell_index occ_cell_member_count]=GetOccupiedCells(rep);
    % 比较拥挤的网格选择概率较低
    p=occ_cell_member_count.^(-beta);
    % 每个待选网格索引被选择的几率
    p=p/sum(p);
    % 轮盘赌选择
    selected_cell_index=occ_cell_index(RouletteWheelSelection(p));
    
    GridIndices=[rep.GridIndex];
    % 找到所选择索引对应的位置
    selected_cell_members=find(GridIndices==selected_cell_index);
    
    n=numel(selected_cell_members);
    % 在该位置随机选择一个解
    selected_memebr_index=randi([1 n]);
    % 在外部档案找到对应的索引
    h=selected_cell_members(selected_memebr_index);
    % 在档案找到对应的解
    rep_h=rep(h);
end