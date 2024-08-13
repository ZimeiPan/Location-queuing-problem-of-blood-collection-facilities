function newChromo = mutate(chromo,ProM)
    global dim popmax popmin
    
%     newChromo = chromo;
%     %% 变异概率
%     prand = rand;
%     if prand<=mu
%         judge = 0;
%         while judge == 0
%            d = randi(dim);
%            newChromo(1,d) = popmin+(popmax-popmin).*rand();
%            judge = test(newChromo);
%         end
%     end
    %% 多项式变异
    newChromo = chromo;
    MinValue = repmat(popmin, 1, dim);
    MaxValue = repmat(popmax, 1, dim);
    DisM = 1;
    
    k    = rand(1,dim); % 随机选定要变异的基因位
    mu   = rand(1,dim); % 采用多项式变异，此为式中的 u
    
    Temp = k<=ProM & mu<0.5;   % 要变异的基因位，ProM：变异概率
    newChromo(Temp) = newChromo(Temp)+(MaxValue(Temp)-MinValue(Temp))...
    .*((2.*mu(Temp)+(1-2.*mu(Temp)).*(1-(newChromo(Temp)-MinValue(Temp))./(MaxValue(Temp)-MinValue(Temp))).^(DisM+1)).^(1/(DisM+1))-1);
    
    Temp = k<=ProM & mu>=0.5;
    newChromo(Temp) = newChromo(Temp)+(MaxValue(Temp)-MinValue(Temp))...
    .*(1-(2.*(1-mu(Temp))+2.*(mu(Temp)-0.5).*(1-(MaxValue(Temp)-newChromo(Temp))./(MaxValue(Temp)-MinValue(Temp))).^(DisM+1)).^(1/(DisM+1)));
    
    %% 越界处理-分别等于最大和修最小值
    newChromo(newChromo>MaxValue) = MaxValue(newChromo>MaxValue); % 子代越上界处理
    newChromo(newChromo<MinValue) = MinValue(newChromo<MinValue); % 子代越下界处理
    
end
