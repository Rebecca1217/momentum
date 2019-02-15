function holdingInfo = getholdinghands(posTradingDirect, posFullDirect, capital)
%input posFullDirect, capital, output daily holdinghands
%ƽ�������ʽ𣬺�����Ҫ�Ӳ�������������Ȩ�ʽ���䷽ʽ,capitalָ����������ֵ�����ﲻ���Ǳ�֤��
%����ط��������޳�һ�������ԣ���Ϊ�������ӵ�ʱ���޹���,posFullDirect�в�����������

tradingNum = sum(abs(table2array(posTradingDirect(:, 2:end))), 2);
tradingAmount = capital ./ tradingNum;
fullTradingNum = sum(abs(table2array(posFullDirect(:, 2:end))), 2);
fullTradingAmount = capital ./ fullTradingNum;
% load price 
% ��Լ���� = ������ֵ ./ ����Լ���� .* ��Լ�۸� .* posfullDirect
factorPara = evalin('base', 'factorPara');
dataPara.path = factorPara.lotsDataPath; % @2019.1.8�����Լ�����ò���Ȩ �������̼�
dataPara.dateFrom = str2double(datestr(datenum(num2str(factorPara.dateFrom), 'yyyymmdd') - 10, 'yyyymmdd'));
dataPara.dateTo = factorPara.dateTo;
dataPara.priceType = factorPara.priceType;

priceData = getpricedata(dataPara);
varNames = priceData.Properties.VariableNames;
% ����ط�priceDataҪ������dateFrom����ǰһ�㣬��Ϊ��Ҫ��һ�������յļ۸���ȷ������������
% ��һ����ǵ����յĻ���priceData��Ҫ������һ����ǰһ�������յļ۸���Ϣ
% priceData = priceData(priceData.Date >= min(posFullDirect.Date) & ...
%     priceData.Date <= max(posFullDirect.Date), :);
% @2019.2.14 ���priceData������0����Ҫ����fill0
priceData = varfun(@fill0Price, priceData);
priceData.Properties.VariableNames = varNames;
clear varNames

% load ��Լ���� unitInfo �� liquidInfoһ����ÿ�����ϸ���table���ݣ��õ�ʱ��load�Ϳ�����
load('E:\futureData\unitInfo.mat')
unitInfo = unitInfo(unitInfo.Date >= min(posFullDirect.Date) & ...
    unitInfo.Date <= max(posFullDirect.Date), :);

% unitInfo��liquidityInfoһ��������Ҫ�޳���ָ�ڻ��͹�ծ�ڻ�
unitInfo = delStockBondIdx(unitInfo);

% get raw hands
% ����ֻget�����վͿ����ˣ� �м䲿�ֵ������ͻ�����һ��������ϼ���
% ע�⣬����м�������Լ���ˣ�����Ҫƽ����ǰ��Լ�������µ�������Լ�����������ͻ��б仯����
% �����ô������ʱ�Ȳ�����

unitInfoTrading = unitInfo(ismember(unitInfo.Date,  posTradingDirect.Date), :);
priceDataHolding = priceData(ismember(priceData.Date, posTradingDirect.Date), :);
fullUnitInfoTrading = unitInfo(ismember(unitInfo.Date, posFullDirect.Date), :);
fullPriceDataHolding = priceData(ismember(priceData.Date, posFullDirect.Date), :);
% ����������ڼ����������һ�������յ����̼۸񣬼���t�������õ���t-1���̼�
% [~, ra, ~] = intersect(priceData.Date, posTradingDirect.Date);
% priceLastDay = priceData((ra - 1), :);
% clear ra
%@2019.01.07 �޸�Ϊ����t�յ����̼�ȷ��t+1�յĿ�����������¼��t��

hands = round(...
    repmat(tradingAmount, 1, size(posTradingDirect, 2) - 1)  ./ ...
    (table2array(unitInfoTrading(:, 2:end)) .* ...
    table2array(priceDataHolding(:, 2:end))) .* ...
    table2array(posTradingDirect(:, 2:end)));
% tradingAmount��ƽ��������ֲ�Ʒ��/futAllocationFactor.m������ƽ�����������ȫ��������Ʒ��
% ����t-1�յ����̼۸�ȷ��t�յĿ�����������¼��t��
% ����������0��NaN��0��ʾ�����ݵ���ûѡ�гֲ֣�NaN��ʾȱʧ��Ҫ���ݣ��۸�/��Լ�����ȣ�

% ���ﲻ��Ҫ����С�䶯��λ����������ȡ���ͺ��ˣ���С�䶯��λ�ĵ����ڻز�ƽ̨��
% ���²�ȫ�ǵ����յĳֲ�����
% �Ȱ�������ȫʱ�� �ټ��� ��Ȼ�������˻�Ҫһ������һ��ʱ��
totalDate = posFullDirect(:, 1);
hands = array2table([posTradingDirect.Date hands], ...
    'VariableNames', posTradingDirect.Properties.VariableNames);
fullHands = outerjoin(hands, totalDate, 'MergeKeys', true);
fullHands = varfun(@fillnan, fullHands);
fullHands.Properties.VariableNames = posFullDirect.Properties.VariableNames;
holdingInfo.fullHands = fullHands;


% �ز�ƽ̨holdingInfo��Ҫ����Ϣ�У�ÿ�ճֲ����������������ֵ���ֲ�����Ȩ�أ�ʵ�ʳ�����ֵ��ʵ�ʳֲ�Ȩ��
holdingInfo.normSize = repmat(fullTradingAmount, 1, size(posFullDirect, 2) -1) .* ...
    abs(table2array(posFullDirect(:, 2:end)));
holdingInfo.normWeight = bsxfun(@times, holdingInfo.normSize, ...
    repmat(1./capital, 1, size(holdingInfo.normSize, 2)));
holdingInfo.realSize = abs(table2array(holdingInfo.fullHands(:, 2:end))) .*...
    table2array(fullPriceDataHolding(:, 2:end)) .* ...
    table2array(fullUnitInfoTrading(:, 2:end));
realSizeDly = nansum(holdingInfo.realSize, 2);
holdingInfo.realWeight = bsxfun(@times, holdingInfo.realSize, ...
    repmat(1./realSizeDly, 1, size(holdingInfo.realSize, 2)));
% ��ÿ������ϱ�ͷ
holdingInfo.normSize = array2table([posFullDirect.Date holdingInfo.normSize],...
    'VariableNames', posFullDirect.Properties.VariableNames);
holdingInfo.normWeight = array2table([posFullDirect.Date holdingInfo.normWeight],...
    'VariableNames', posFullDirect.Properties.VariableNames);
holdingInfo.realSize = array2table([posFullDirect.Date holdingInfo.realSize],...
    'VariableNames', posFullDirect.Properties.VariableNames);
holdingInfo.realWeight = array2table([posFullDirect.Date holdingInfo.realWeight],...
    'VariableNames', posFullDirect.Properties.VariableNames);


    
end



