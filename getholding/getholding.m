function res = getholding(win, passway)
%�õ�ÿ�ڳֲ�Ʒ�ֺͷ���
% �ȵõ������յģ�Ȼ����䵽�м��ÿ��õ������ĳֲ�Ʒ�ֺͷ���
% ֮���ٿ��������ͺ�Լ���ֵ�����
factorDataPath = evalin('base', 'factorDataPath');
factorName = evalin('base', 'factorName');
load([factorDataPath, factorName, '\window', num2str(win), '.mat'])

%% �޳������Բ��Ʒ��
liquidityInfo = evalin('base', 'liquidityInfo');
% ����factorData����������ȱʧ��һ��ʱ�䴰�ڵģ�liquidityInfo��from-toȫ��ʱ���
res = table2array(factorData(:, 2:end)) .* ...
    liquidityInfo((win + 1 : end), :); % ����Warn��factorData��load������

res = [factorData.Date, res]; % ������Ʒ�ֵ�ÿ����������

%% ȷ����Ʒ�ֵĳֲ�
% ���л����� ��������40�죬ͨ����40������ѭ�������Ӵ��ڣ�ͨ������
holdingTime = evalin('base', 'tradingPara.holdingTime');
tradingDate = res(:, 1);
tradingIndex = (passway:holdingTime:size(res, 1));
tradingDate = tradingDate(tradingIndex);
% iWin = 1, passway = 1ʱ�������ӳ��ֵĵ�һ��Ϳ�ʼ����

% �����յ���������
resTrading = array2table(res, 'VariableNames', factorData.Properties.VariableNames);
resTrading = resTrading(ismember(resTrading.Date, tradingDate), :);


% resTrading��Ϊ��������getholdingdirect.m�õ������յĳֲַ�����
res = getholdingdirect(resTrading);

end

