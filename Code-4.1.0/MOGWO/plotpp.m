function plotpp(pop)
    x = pop(1,:);
    y = pop(2,:);
    
    %绘制二维散点图
    plot(x,y,'*');
    xlabel('等待时间');
    ylabel('成本');
    title('帕累托前沿面');
    grid on;
end

