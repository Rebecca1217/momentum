function [ProfitDly,sizeDly] = get_TradeProfitDly(tradeList,tradePrice,setPrice,setPriceBF,paraT)
% �ֱֲ仯��ɵ�ӯ��
% ��������֮��Ľ��׵�����
% ����ǿ��ֵ����ý��׼ۺͽ�����
% �����ƽ�ֵ����ý��׼ۺ�������

fixC = paraT.fixC;
slip = paraT.slip;
minTickInfo = paraT.minTickInfo;
MultiInfo = paraT.MultiInfo;

tradeFut = regexp(tradeList(:,1),'\D*(?=\d)','match'); %���콻�׵�Ʒ��
tradeFut = reshape([tradeFut{:}],size(tradeFut));
[~,li0,li1] = intersect(tradeFut,minTickInfo(:,1));% ��С�䶯��λ
tradeList(li0,4) = minTickInfo(li1,2);
[~,li0,li1] = intersect(tradeFut,MultiInfo(:,1)); %��Լ����
tradeList(li0,5) = MultiInfo(li1,2);
% [~,liA,liF] = unique(tradeList(:,1));% ��Ե��շ����Ʒ�֣�Ҫ���������С�䶯��λ�ͺ�Լ����
% tmp = tradeList(liA,4:5);
% tradeList(:,4:5) = tmp(liF,:);
% ���µ�Ʒ��ҲҪ����-�������·�
[~,liA,liF] = unique(tradeFut);% ��Ե��շ����Ʒ�֣�Ҫ���������С�䶯��λ�ͺ�Լ����
tmp = tradeList(liA,4:5);
tradeList(:,4:5) = tmp(liF,:);

profitFut = zeros(length(tradeFut),5); %���׷��򡢽������������׼ۡ�����ۡ���Լ����
% �����׵�Ʒ�ֳַɿ��ֵ���ƽ�ֵ����ֱ���
% ���ֵ������׼ۺͽ�����
% ƽ�ֵ������׼ۺ�������
profitFut(:,1) = sign(cell2mat(tradeList(:,2))); %���׷���
profitFut(:,2) = abs(cell2mat(tradeList(:,2))); %��������
[~,li0] = intersect(tradePrice(:,1),tradeList(:,1));
tradePrice = cell2mat(tradePrice(li0,2));
[~,~,liF] = unique(tradeList(:,1));
tradePrice = tradePrice(liF);


profitFut(:,3) = (tradePrice+profitFut(:,1).*cell2mat(tradeList(:,4))*slip).*(1+profitFut(:,1)*fixC); %���ǽ��׳ɱ��Ľ��׼۸�
% �����Ҫ���ֿ��ֵ���ƽ�ֵ�
OpenOrClose = cell2mat(tradeList(:,3));
liOpen = find(OpenOrClose==1); %���ֵ�
liClose = find(OpenOrClose==-1); %ƽ�ֵ�
if ~isempty(liOpen)
%     setPrice = setPrice(li0,:);
%     setPrice = setPrice(liF,:);
    [~,li0] = intersect(setPrice(:,1),tradeList(liOpen,1));
    setPrice = cell2mat(setPrice(li0,2));
    profitFut(liOpen,4) = setPrice;
end
if ~isempty(liClose)
%     setPriceBF = setPriceBF(li0,:);
%     setPriceBF = setPriceBF(liF,:);
    [~,li0] = intersect(setPriceBF(:,1),tradeList(liClose,1));
    setPriceBF = cell2mat(setPriceBF(li0,2));
    profitFut(liClose,4) = setPriceBF;
end
profitFut(:,5) = cell2mat(tradeList(:,5)); %��Լ����

% �������Ʒ�ֵ�����
profit = (profitFut(:,4)-profitFut(:,3)).*profitFut(:,5).*profitFut(:,1).*profitFut(:,2);
profit(isnan(profit)) = 0; %profit��nan����������ڻ��µ�ʱ�����ʱ���Ĭ��ƽ�ɺ�Լû�в���������%%%%%%%%%%%%%%%%%%%%%%%%%
ProfitDly = sum(profit);

% ��ֵ=�¿��ִ�������ֵ��ƽ�ֵĲ��ֲ�����
sizeDly = zeros(1,2);
if ~isempty(liOpen)
    sizeDly(1) = sum(profitFut(liOpen,4).*profitFut(liOpen,2).*profitFut(liOpen,5)); %������
    sizeDly(2) = sum(profitFut(liOpen,4).*profitFut(liOpen,2).*profitFut(liOpen,1).*profitFut(liOpen,5)); %���ڣ�����
end



