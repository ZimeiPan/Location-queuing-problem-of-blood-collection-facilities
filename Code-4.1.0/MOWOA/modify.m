function ret=modify(x)
%% �Գ�����Χ��x��������-�е�����
global popmin popmax dim
ret=x;

index1=x<popmin;
index2=x>popmax;
ret=ret.*(~(index1+index2))+index1*popmin+index2*popmax;

% for k=1:dim
%     if x(k)>popmax||x(k)<popmin
%         ret(k)=popmin+(popmax-popmin)*rand();
%     end
% end
% ret(find(x<popmin))=popmin;
% ret(find(x>popmax))=popmax;
