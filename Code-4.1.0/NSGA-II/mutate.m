function newChromo = mutate(chromo,ProM)
    global dim popmax popmin
    
%     newChromo = chromo;
%     %% �������
%     prand = rand;
%     if prand<=mu
%         judge = 0;
%         while judge == 0
%            d = randi(dim);
%            newChromo(1,d) = popmin+(popmax-popmin).*rand();
%            judge = test(newChromo);
%         end
%     end
    %% ����ʽ����
    newChromo = chromo;
    MinValue = repmat(popmin, 1, dim);
    MaxValue = repmat(popmax, 1, dim);
    DisM = 1;
    
    k    = rand(1,dim); % ���ѡ��Ҫ����Ļ���λ
    mu   = rand(1,dim); % ���ö���ʽ���죬��Ϊʽ�е� u
    
    Temp = k<=ProM & mu<0.5;   % Ҫ����Ļ���λ��ProM���������
    newChromo(Temp) = newChromo(Temp)+(MaxValue(Temp)-MinValue(Temp))...
    .*((2.*mu(Temp)+(1-2.*mu(Temp)).*(1-(newChromo(Temp)-MinValue(Temp))./(MaxValue(Temp)-MinValue(Temp))).^(DisM+1)).^(1/(DisM+1))-1);
    
    Temp = k<=ProM & mu>=0.5;
    newChromo(Temp) = newChromo(Temp)+(MaxValue(Temp)-MinValue(Temp))...
    .*(1-(2.*(1-mu(Temp))+2.*(mu(Temp)-0.5).*(1-(MaxValue(Temp)-newChromo(Temp))./(MaxValue(Temp)-MinValue(Temp))).^(DisM+1)).^(1/(DisM+1)));
    
    %% Խ�紦��-�ֱ������������Сֵ
    newChromo(newChromo>MaxValue) = MaxValue(newChromo>MaxValue); % �Ӵ�Խ�Ͻ紦��
    newChromo(newChromo<MinValue) = MinValue(newChromo<MinValue); % �Ӵ�Խ�½紦��
    
end
