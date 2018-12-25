function [signalMtrx,HoldingMtrx,futUni] = getSigMtrx(TargetPortfolio)
% ��TargetPortfolio�ĳɾ�����ʽ����������һ�����źţ�һ���ǳֲ�

len = cellfun(@(x) size(x,1),TargetPortfolio(:,1)); %ÿ�������ս��׵�Ʒ�ֵ���Ŀ
num = sum(len);
t = 1;
targetTS = cell(num,2);
targetDate = zeros(num,1);
for d = 1:size(TargetPortfolio,1)
    targetTS(t:t+len(d)-1,:) = TargetPortfolio{d,1};
    targetDate(t:t+len(d)-1) = TargetPortfolio{d,2};
    t = t+len(d);
end
targetTS = sortrows([targetTS,num2cell(targetDate)],1); %Ʒ�֡�����������
fut_variety = regexp(targetTS(:,1),'\D*(?=\d)','match'); %Ʒ�ִ���
fut_variety = reshape([fut_variety{:}],size(fut_variety));
targetHD = [cell2mat(targetTS(:,3)),sign(cell2mat(targetTS(:,2))),abs(cell2mat(targetTS(:,2)))]; %date sign hands-˳����targetTS��Ӧ
%
futUni = unique(fut_variety);
date = cell2mat(TargetPortfolio(:,2));
signalMtrx = [date,zeros(length(date),length(futUni))];
HoldingMtrx = zeros(size(signalMtrx));
HoldingMtrx(:,1) = date;
for i_fut = 1:length(futUni)
    tmp = targetHD(ismember(fut_variety,futUni{i_fut}),:);
    [~,li0,li1] = intersect(tmp(:,1),date);
    signalMtrx(li1,i_fut+1) = tmp(li0,2);
    HoldingMtrx(li1,i_fut+1) = tmp(li0,3);
end