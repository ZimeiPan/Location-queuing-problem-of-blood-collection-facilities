function plotpp(pop)
    x = pop(1,:);
    y = pop(2,:);
    
    plot(x,y,'*');
    xlabel('waiting time');
    ylabel('cost');
    title('Pareto front surface');
    grid on;
end

