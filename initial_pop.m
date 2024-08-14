function pop = initial_pop(popsize)
    global parameter dim_t popmax popmin
    
    period = parameter.period;
    dim = dim_t*period;
    
    % Logistic map
    cxl = rand(popsize,dim);
    for j = 1:dim-1
       cxl(:,j+1) = 4.*cxl(:,j).*(1-cxl(:,j));
    end
    
    pop = cxl.*(popmax-popmin)+ popmin;
end

