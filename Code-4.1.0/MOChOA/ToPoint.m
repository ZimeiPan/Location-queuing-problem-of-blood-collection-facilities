function tr=ToPoint(x,number)
    %% 转换为节点选择-巧妙的将解转化为 固定献血屋/移动献血车的选址
    %% 其中，移动献血车的选址还满足最大车量约束
    n=1:number;
    tr=x;
    for i=1:length(x)
        % 当为复数时,取0,即为不选址
        if x(i)<=0
            tr(i)=0;
        else
            %% 其他情况，选索引
            ch=ceil(x(i)*length(n));
            tr(i)=n(ch);
            n(ch)=[];
        end
    end