function plotpp(pop)
    obj = [pop.obj];
    x = obj(1,:);
    y = obj(2,:);
    
    %绘制二维散点图
    plot(x,y,'*');
    xlabel('满意度');
    ylabel('总成本');
    title('帕累托前沿面');
    grid on;
end

