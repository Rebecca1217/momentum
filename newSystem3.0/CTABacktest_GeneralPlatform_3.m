function [BacktestResult,err] = CTABacktest_GeneralPlatform_3(TargetPortfolio,TradePara)
% ======================CTAͨ�ûز�ƽ̨2.0-20180329==============================
% -------------------------����------------------------------
% TargetPortfolio:Ŀ��ֲ֣����������ռ�¼���Ǻ�һ�������յ�Ŀ��ֲ�
% TargetPortfolio:cell,��һ��Ϊ���;�ڶ���ΪĿ����������գ�������Ϊ�����գ���¼���Ǻ�һ��������Ӧ�������ĳֲ�
% TargetPortfolio:�ڶ���cell�е�Ԫ�ذ������У���һ����Ʒ�ִ���(A0809),�ڶ�����Ŀ������(������)
% TargetPortfolio�еĽ��������������������н�����
% TradePara:���ײ���������·�������׳ɱ�
% -------------------------���------------------------------
% BacktestResult:�ز������ۼ����桢���ճ��ڡ����ڳֲ�
% 20180709:
% 1.ֹӯֹ��������targetportfolio��ʱ���ǣ����ڼ��������ʱ����

err = 0;
% ���ײ���ȷ��
% ���ײ���ȷ��
if nargin==1
    Cost.fix = 0; %�̶��ɱ�
    Cost.float = 0; %����
    PType = 'open'; %���׼۸�
    % ��������·��
    futDataPath = 'D:\�ڻ�����2.0\dlyData\������Լ';
    futUnitPath = 'D:\�ڻ�����2.0\usualData\minTickInfo.mat';
    futMultiPath = 'D:\�ڻ�����2.0\usualData\PunitInfo';
else
    % ·��
    futDataPath = TradePara.futDataPath; %�ڻ�����·��
    futUnitPath = TradePara.futUnitPath; %�ڻ���С�䶯��λ����·��
    futMultiPath = TradePara.futMultiPath; %�ڻ���Լ��������·��
    % ����
    PType = TradePara.PType; %�ɽ��۸�����
    Cost.fix = TradePara.fixC;
    Cost.float = TradePara.slip;
end
load(futUnitPath) %��С�䶯��λ����-minTickInfo
load([futMultiPath,'\',num2str(TargetPortfolio{end,2}),'.mat']) %��Լ��������-�������һ�������ն�Ӧ�ĺ�Լ��������

% ��������յ���������
tradaySeries = cell2mat(TargetPortfolio(:,2)); %Ŀ��ֲ������գ�������
nextTraday = get_nextTraday(tradaySeries); %Ŀ��ֲֶ�Ӧ�ĵ�����
if length(nextTraday)~=length(tradaySeries) %����������ڵ���Ŀ��������������յ���Ŀ������
    fprintf('����������ȱʧ�����һ��dateCalendar������\n')
    err = 1;
    return;
end

% �Ƚ�TargetPortfolio�ĳɾ�����ʽ����������һ�����źţ�һ���ǳֲ�,���ں�TargetPortfolio�Ƕ����
[signalMtrx,HoldingMtrx,fut_variety] = getSigMtrx(TargetPortfolio);

% ���Ʒ�ֲ���
signalDate = signalMtrx(:,1);
rtnFut = zeros(size(signalMtrx));
rtnFut(:,1) = signalDate;
riskExposure = zeros(length(signalDate),2); %���ճ������У����ڡ�������ĳ���
riskExposure(:,1) = signalDate;
for i_fut = 1:length(fut_variety)
    fut = fut_variety{i_fut};
    Cost.unit = minTickInfo{ismember(minTickInfo(:,1),fut),2};
    Cost.multi = infoData{ismember(infoData(:,1),fut),2};
    % ���������ʽ������
    % Ҫ���������ݡ��ź����ݡ��ֲ����ݵ���ֹ���ڶ���
    % ��������
    load([futDataPath,'\',fut,'.mat'])
    tradeData = getTradeData(futureData,signalDate(1),signalDate(end),PType);
    % �ź�����
    sigData = getSigData2(signalMtrx(:,[1,i_fut+1]),tradeData.tdDate);
    % �ֲ���������
    HoldingHandsFut = HoldingMtrx(:,[1,i_fut+1]);
    HoldingHandsFut(HoldingHandsFut(:,2)==0,2) = nan;
    HoldingHandsFut(:,2) = [nan;HoldingHandsFut(1:end-1,2)]; %�ֲ�����������һ�죬����Ŀ��������뵱������ڶ����ˣ�����1.2�Ŀ���������������1.1�����ڸĳɼ�¼��1.2
    HoldingHandsFut = HoldingHandsFut(HoldingHandsFut(:,1)>=tradeData.tdDate(1) & HoldingHandsFut(:,1)<=tradeData.tdDate(end),:);
    % ��������
    tdList = calRtnByRealData2(sigData,tradeData,HoldingHandsFut,Cost);
    %
    [~,li0,li1] = intersect(signalDate,tradeData.tdDate);
    rtnFut(li0,i_fut+1) = tdList(li1,5);
    %
    riskExposure(li0,2) = riskExposure(li0,2)+tdList(li1,4).*tradeData.ttData(li1,2);
end

nv = [rtnFut(:,1),cumsum(sum(rtnFut(:,2:end),2)),sum(rtnFut(:,2:end),2)];
% �洢���
BacktestResult.rtnFut = rtnFut;
BacktestResult.fut_variety = fut_variety;
BacktestResult.riskExposure = riskExposure;
BacktestResult.nv = nv;
    
    