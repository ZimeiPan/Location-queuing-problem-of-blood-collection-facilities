function [Index SubIndex]=GetGridIndex(particle,G)

    c=particle.Cost;
    % 目标数
    nobj=numel(c);
    % 网格数
    ngrid=numel(G(1).Upper);
    
    str=['sub2ind(' mat2str(ones(1,nobj)*ngrid)];

    SubIndex=zeros(1,nobj);
    % 找到档案中每个非支配解所对应目标函数值在网格中的索引
    for j=1:nobj
        
        U=G(j).Upper;
        
        i=find(c(j)<U,1,'first');
        
        SubIndex(j)=i;
        
        str=[str ',' num2str(i)];
    end
    
    str=[str ');'];
    % 将字符串转化为线性索引
    % eval:执行参数中的函数
    Index=eval(str); 
end