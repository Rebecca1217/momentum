function [BacktestResult,err] = CTABacktest_GeneralPlatform(TargetPortfolio,TradePara)
% ======================CTAͨ�ûز�ƽ̨==============================
% -------------------------����------------------------------
% TargetPortfolio:Ŀ��ֲ֣����������ռ�¼���Ǻ�һ�������յ�Ŀ��ֲ�
% TargetPortfolio:cell,��һ��Ϊ���;�ڶ���ΪĿ����������գ�������Ϊ�����գ���¼���Ǻ�һ��������Ӧ�������ĳֲ�
% TargetPortfolio:�ڶ���cell�е�Ԫ�ذ������У���һ����Ʒ�ִ���(A0809),�ڶ�����Ŀ������(������)
% TradePara:���ײ���������·�������׳ɱ�
% -------------------------���------------------------------
% BacktestResult:�ز������ۼ����桢���ճ��ڡ����ڳֲ�
err = 0;
% ���ײ���ȷ��
% ·��
futDataPath = TradePara.futDataPath; %�ڻ�����·��
futUnitPath = TradePara.futUnitPath; %�ڻ���С�䶯��λ����·��
futMultiPath = TradePara.futMultiPath; %�ڻ���Լ��������·��
% ����
PType = TradePara.PType; %�ɽ��۸�����
fixC = TradePara.fixC; %�̶��ɱ�
slip = TradePara.slip; %����


% ��������յ���������
tradaySeries = cell2mat(TargetPortfolio(:,2)); %Ŀ��ֲ������գ�������
nextTraday = get_nextTraday(tradaySeries); %Ŀ��ֲֶ�Ӧ�ĵ�����
if length(nextTraday)~=length(tradaySeries) %����������ڵ���Ŀ��������������յ���Ŀ������
    fprintf('����������ȱʧ�����һ��dateCalendar������\n')
    err = 1;
    return;
end

% ����ÿ��ʵ�ʵĽ��׵���
% ����Ҫ���׵ĵ��Ӷ�Ӧ�����ھ��ǵ��������
% TargetTraListDly��20180209Ҫ���׵ĵ��ӱ�ǵ�����Ϊ20180209
% HisListDly��20180209��¼����20180209�������ʷ�ֲ�
% TargetPortfolio��20180209Ҫ��ɵ�Ŀ��ֱֲ�ǵ�����Ϊ20180208
[TargetTraListDly,HisListDly] = get_TargetTraListDly(TargetPortfolio,nextTraday); 
% TargetTraListDly��TargetPortfolio�����ڴ�һ��

nv = zeros(length(nextTraday),3); %��ֵ���У����ڡ��ۼ����桢��������
nv(:,1) = nextTraday;
riskExposure = zeros(length(nextTraday),3); %���ճ������У����ڡ�������ĳ��ڡ�����ĳ���
riskExposure(:,1) = nextTraday;
% ���׵����Ѿ����ɺ��ˣ���ʼ���ջز�
load(futUnitPath) %�����Լ��С�䶯��λ
% ����
tradeDayI = nextTraday(1); %�׸�������
tradeList = TargetTraListDly{1,1}; %�׸����׵�
load([futDataPath,'\',num2str(tradeDayI),'.mat']) %����۸�����
load([futMultiPath,'\',num2str(tradeDayI),'.mat']) %��Լ����
[tradePrice,setPrice] = get_tradePrice(futureDataCS,PType); %���׼۸�ͽ���۸�
paraT.fixC = fixC;
paraT.slip = slip;
paraT.minTickInfo = minTickInfo;
paraT.MultiInfo = infoData;
[nv(1,3),riskExposure(1,2:3)] = get_TradeProfitDly(tradeList,tradePrice,setPrice,[],paraT);

% ÿ��ӯ��=��ʷ�ֲ�ӯ��+�µĽ��ײ�����ӯ��
for d = 2:length(nextTraday) %
    tradeDayI = nextTraday(d); %����20180102
    % ���յĽ��׵�
    tradeList = TargetTraListDly{d,1}; %����20180102��Ӧ�Ľ��׵�����¼20180102Ӧ����ɵĽ���
    % ���յ���ʷ�ֲ�
    hisList = HisListDly{d,1}; %����20180102��Ӧ�ĳֲֵ�����¼20180102Ӧ�ó��е���ʷ�ֲ�
    % ���뵱�յ�����
    load([futDataPath,'\',num2str(tradeDayI),'.mat']) %����۸�����
    load([futMultiPath,'\',num2str(tradeDayI),'.mat']) %��Լ����
    setPriceBF = setPrice;
    [tradePrice,setPrice] = get_tradePrice(futureDataCS,PType);
    if isempty(tradeList) %����������轻��
        tradeProfit = 0;
        tradeRE = [0,0];
    else
        paraT.MultiInfo = infoData;
        [tradeProfit,tradeRE] = get_TradeProfitDly(tradeList,tradePrice,setPrice,setPriceBF,paraT);
    end
    if isempty(hisList) %�������û����ʷ�ֲ�
        holdProfit = 0;
        holdRE = [0,0];
    else
        [holdProfit,holdRE] = get_HoldProfitDly(hisList,setPrice,setPriceBF,paraT);
    end
    nv(d,3) = tradeProfit+holdProfit;
    riskExposure(d,2:3) = tradeRE+holdRE;
end

nv(:,2) = cumsum(nv(:,3));
BacktestResult.nv = nv; %���
BacktestResult.riskExposure = riskExposure;
BacktestResult.TargetPortfolio = TargetPortfolio;



