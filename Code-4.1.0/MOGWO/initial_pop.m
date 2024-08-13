function pop = initial_pop(popsize)
    global parameter dim_t popmax popmin
    
    
    period = parameter.period;
    dim = dim_t*period;
    pop = zeros(popsize,dim_t*period);
    
    for p = 1 : popsize
        pop(p,:) = popmin+(popmax-popmin).*rand(1,dim);
    end
end

