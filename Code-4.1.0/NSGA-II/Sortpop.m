function pop = Sortpop(pop)
    %ӵ���Ƚ�������
    [~, CDSO] = sort([pop.crowdingdistance], 'descend'); 
    pop = pop(CDSO);
    %��֧��ȼ���������
    [~, RSO] = sort([pop.rank]);
    pop = pop(RSO);
end
