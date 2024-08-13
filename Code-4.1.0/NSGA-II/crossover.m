function [newChromo1,newChromo2] = crossover(chromo1,chromo2,pc)
    global parameter
    
    pop = size(chromo1,1);
    % ά��
    dim = size(chromo1,2);
    newChromo1 = chromo1;
    newChromo2 = chromo2;
    
    n = rand;
    
    %% ���н���
    if n<=pc
        
        %% ���㽻��-�ٶ�̫��
        %a = randi(dim);
        %newChromo1 = [chromo1(:,1:a),chromo2(:,a+1:end)];
        %newChromo2 = [chromo2(:,1:a),chromo1(:,a+1:end)];
        
        % ģ������ƽ���-Ч����̫��
        u = rand;
        if u <= 0.5
            r = (2*u)^(1/2);
        else
            r = (1/(2-2*u))^(1/2);
        end
        newChromo1 = 0.5 * ((1+r).*chromo1 + (1-r).*chromo2);
        newChromo2 = 0.5 * (1-r).*chromo1 + (1+r).*chromo2;
        newChromo1=modify(newChromo1);
        newChromo2=modify(newChromo2);
        
        %% ���㽻��-���Ը�Ϊģ������ƽ�������
%         list = randperm(dim);
%         a = list(1);
%         b = list(2);
%         if a < b
%             newChromo1 = [chromo1(:,1:a),chromo2(:,a+1:b),chromo1(:,b+1:end)];
%             newChromo2 = [chromo2(:,1:a),chromo1(:,a+1:b),chromo2(:,b+1:end)];
%         else
%             newChromo1 = [chromo1(:,1:b),chromo2(:,b+1:a),chromo1(:,a+1:end)];
%             newChromo2 = [chromo2(:,1:b),chromo1(:,b+1:a),chromo2(:,a+1:end)];
%         end
    end
end
