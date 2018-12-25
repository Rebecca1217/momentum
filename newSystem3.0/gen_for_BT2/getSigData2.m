function sigData = getSigData2(signal,tdDate)
% ÿһ���źŶ�Ӧ�Ŀ�ƽ��������
% signal:����Ʒ�ֶ�Ӧ���źź�����
% ע��������һ�������źŶ�Ӧ��ƽ���ź�û�з����������һ���źŵ�ƽ��ʱ���Ϊnan
% 20180710����Ķ���ƽ���źŵ��б���ǰһ���б�+1

signal = signal(signal(:,1)>=tdDate(1) & signal(:,1)<=tdDate(end),:);
signal = signal(:,2);
% �ֶ��ͷ�ֱ���
sigLong = signal;
sigLong(signal==-1) = 0;
sigShort = signal;
sigShort(signal==1) = 0;
sigShort(signal==-1) = 1;
if sum(sigLong)~=0
    sigLiLong = getSigLines(sigLong);
else
    sigLiLong = [];
end
if sum(sigShort)~=0
    sigLiShort = getSigLines(sigShort);
    sigLiShort(:,1) = -1;
else
    sigLiShort = [];
end
sigData = sortrows([sigLiLong;sigLiShort],2);

end


function sigLi = getSigLines(sigDirect) 
% �����˵�һ�оͷ����źŵ����
% �����źŷ��������С��źŽ���������


difSig = [sigDirect(1);diff(sigDirect)];
locs = find(difSig==1); %�źŷ���������

sigLi = zeros(length(locs),3);
sigLi(:,1) = 1;
sigLi(:,2) = locs; %�����ź�������
for l = 1:length(locs)
    edL = find(difSig(locs(l):end)==-1,1,'first')+locs(l)-1;
    if isempty(edL)
        sigLi(l,3) = nan;
    else
        sigLi(l,3) = edL;
    end
end

end
