function ret=modify(x)
%% 对超出范围的x进行修正
global popmin popmax dim
ret=x;

for k=1:dim
    if x(k)>popmax||x(k)<popmin
        ret(k)=popmin+(popmax-popmin)*rand();
    end
end
%index1 = x<popmin;
%index2 = x>popmax;

%ret=ret.*(~(index1+index2))+index1*popmin+index2*popmax;
% ret(find(x<popmin))=popmin;
% ret(find(x>popmax))=popmax;
