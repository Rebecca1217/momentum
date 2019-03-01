function res = getholding(passway, tradingPara)
%�õ�ÿ�ڳֲ�Ʒ�ֺͷ���
% �ȵõ������յģ�Ȼ����䵽�м��ÿ��õ������ĳֲ�Ʒ�ֺͷ���
% ֮���ٿ��������ͺ�Լ���ֵ�����
% 
% % @2019.2.28 ����factorData,��ȡlongVolume �� shortVolume ���������ݼ��õ��źţ�����������ɸѡһ�鼴��
% load('E:\futureData\longVolume.mat')
% load('E:\futureData\shortVolume.mat')
dateFrom = evalin('base', 'factorPara.dateFrom');
dateTo = evalin('base', 'factorPara.dateTo');
% longVolume = longVolume(longVolume.Date >= dateFrom & longVolume.Date <= dateTo, :);
% shortVolume = shortVolume(shortVolume.Date >= dateFrom & shortVolume.Date <= dateTo, :);

% load('E:\futureData\longVolumeDelta.mat')
% load('E:\futureData\shortVolumeDelta.mat')
load('E:\futureData\deltaLongLowin.mat')
load('E:\futureData\deltaShortLowin.mat')
longVolumeDelta = deltaLongLowin;
shortVolumeDelta = deltaShortLowin;
longVolumeDelta = longVolumeDelta(longVolumeDelta.Date >= dateFrom & longVolumeDelta.Date <= dateTo, :);
shortVolumeDelta = shortVolumeDelta(shortVolumeDelta.Date >= dateFrom & shortVolumeDelta.Date <= dateTo, :);

longVolumeDelta = delStockBondIdx(longVolumeDelta);
shortVolumeDelta = delStockBondIdx(shortVolumeDelta);

% longVolume = delStockBondIdx(longVolume);
% shortVolume = delStockBondIdx(shortVolume);

% 
% shiftLongVolume = [longVolume.Date, [nan(1, width(longVolume) - 1); table2array(longVolume(1:end-1, 2:end))]];
% shiftLongVolume = [longVolume.Date, table2array(longVolume(:, 2:end)) - shiftLongVolume(:, 2:end)];
% % shiftLongVolume = [longVolume.Date, ...
% %     (table2array(longVolume(:, 2:end)) - shiftLongVolume(:, 2:end)) ./ shiftLongVolume(:, 2:end)];
% 
% 
% shiftShortVolume = [shortVolume.Date, [nan(1, width(shortVolume) - 1); table2array(shortVolume(1:end-1, 2:end))]];
% shiftShortVolume = [shortVolume.Date, table2array(shortVolume(:, 2:end)) - shiftShortVolume(:, 2:end)];
% % shiftShortVolume = [shortVolume.Date, ...
% %     (table2array(shortVolume(:, 2:end)) - shiftShortVolume(:, 2:end)) ./ shiftShortVolume(:, 2:end)];

% ���޳������Բ��Ʒ��
varNames = longVolumeDelta.Properties.VariableNames;
% liquidityInfo = evalin('base', 'liquidityInfo');
% liquidityInfo = arrayfun(@(x, y, z) ifelse(x == 0, NaN, x), liquidityInfo);
% longVolumeDelta = [longVolumeDelta.Date, table2array(longVolumeDelta(:, 2:end)) .* liquidityInfo];
% shortVolumeDelta = [shortVolumeDelta.Date, table2array(shortVolumeDelta(:, 2:end)) .* liquidityInfo];
% shiftLongVolume = [longVolume.Date, shiftLongVolume(:, 2:end) .* liquidityInfo];
% shiftShortVolume = [shortVolume.Date, shiftShortVolume(:, 2:end) .* liquidityInfo];
longVolumeDelta = table2array(longVolumeDelta);
shortVolumeDelta = table2array(shortVolumeDelta);

% shiftLongVolume �õ�1 -1  shiftShortVolume�õ���1 -1 ��Ϊ-1 1  ������˵õ�1 0
% �ٺ�shiftVolume��Label��һ�飬���������źž���

% shiftLongVolume = array2table(shiftLongVolume, 'VariableNames', longVolume.Properties.VariableNames);
% shiftShortVolume = array2table(shiftShortVolume, 'VariableNames', shortVolume.Properties.VariableNames);

% longRes = getholdingdirect(shiftLongVolume);
% shortRes = getholdingdirect(shiftShortVolume);
% shortRes = array2table([shortRes.Date, -table2array(shortRes(:, 2:end))], 'VariableNames', shortRes.Properties.VariableNames);

% res = table2array(longRes(:, 2:end)) .* table2array(shortRes(:, 2:end)) .* table2array(longRes(:, 2:end));
% res = array2table([longRes.Date, res], 'VariableNames', longRes.Properties.VariableNames);
% % ��ɸѡ �൥
% resLongMore = shiftLongVolume(:, 2:end) > 0;
% resLongLess = shiftLongVolume(:, 2:end) < 0;
% resShortMore = shiftShortVolume(:, 2:end) > 0;
% resShortLess = shiftShortVolume(:, 2:end) < 0;

resLongMore = longVolumeDelta(:, 2:end) > 0;
resLongLess = longVolumeDelta(:, 2:end) < 0;
resShortMore = shortVolumeDelta(:, 2:end) > 0;
resShortLess = shortVolumeDelta(:, 2:end) < 0;

resLongLabel = resLongMore .* resShortLess;
resShortLabel = - resLongLess .* resShortMore;

% res = [longVolume.Date, resLongLabel + resShortLabel];
% res = array2table(res, 'VariableNames', longVolume.Properties.VariableNames);
res = [longVolumeDelta(:, 1), resLongLabel + resShortLabel];
res = array2table(res, 'VariableNames', varNames);

% factorData = evalin('base', 'factorData');
% dateFrom = evalin('base', 'factorPara.dateFrom');
% dateTo = evalin('base', 'factorPara.dateTo');
% factorData = factorData(factorData.Date >= dateFrom & factorData.Date <= dateTo, :);
% 
% 
% 
% %% �޳������Բ��Ʒ��
% % @2018.12.28 ����һ����bug������label����ֱ�Ӻ���ֵ��ˡ���labelҪ��label��ˡ���
% % ֮ǰ����ʱ��liquidityInfoֱ�Ӻ�factorData��ˣ���Ϊ�ǰ������Ե͵��޳��ˣ�ʵ���ǰ�factorData�������Ե͵�Ʒ������ֵ��Ϊ0�ˡ���
% % 2������������1����label������0���ĳ�NaN��Ȼ������ˣ�˼·��ԭ��һ��
% % 2������������ѡ��Ʒ�ֱ�ǩ�Ժ󣬱�ǩ����ͱ�ǩ�����˵õ����ĳֱֲ�ǩ
% liquidityInfo = evalin('base', 'liquidityInfo');
% % ����factorData����������ȱʧ��һ��ʱ�䴰�ڵģ�liquidityInfo��from-toȫ��ʱ���
% liquidityInfo = arrayfun(@(x, y, z) ifelse(x == 0, NaN, x), liquidityInfo);
% res = table2array(factorData(:, 2:end)) .* liquidityInfo; % ����Warn��factorData��load������
% res = [factorData.Date, res]; % ������Ʒ�ֵ�ÿ��������
% % 
% % 
% % %% @2018.12.27 �޳������ʵ͵�Ʒ�֣���̩�¶������ӣ�
% % % �����ʻ���ʱ���̶�14
% % % volatilityInfo = getVolatility(pct, factorData.Date(1), factorData.Date(end), 'ATR');
% % % res = res(:, 2:end) .* table2array(volatilityInfo(:, 2:end));
% % % res = [factorData.Date, res]; % ������ & �߲�����Ʒ�ֵ�ÿ����������
% % % % 
% % % %% @2018.12.28 �޳������ʵ͵�Ʒ�֣���̩�¶������ӣ�
% % % �����ʻ���ʱ�������Ӵ���һ��
% % % win = evalin('base', 'window(iWin)');
% % win = tradingPara.volWin;
% % pct = evalin('base', 'tradingPara.pct');
% % volatilityInfo = getVolatility(win, pct, factorData.Date(1), factorData.Date(end), 'sigma');
% % volatilityInfo = arrayfun(@(x, y, z) ifelse(x == 0, NaN, x), table2array(volatilityInfo(:, 2:end)));
% % 
% % res = res(:, 2:end) .* volatilityInfo;
% % res = [factorData.Date, res]; % ������ & �߲�����Ʒ�ֵ�ÿ����������
% % % 
% % 
% % % % @ 2019.02.24 �޳��ֵ����ݵ���Ϊ0��Ʒ��
% % % warrantLabel = evalin('base', 'warrantLabel');
% % % res = res(:, 2:end) .* warrantLabel;
% % % res = [factorData.Date, res]; % ������ & �ֵ���Ϊ0��Ʒ��ÿ����������
% % 
% % 
% %% ȷ����Ʒ�ֵĳֲ�
% % ���л����� ��������40�죬ͨ����40������ѭ�������Ӵ��ڣ�ͨ������
% holdingTime = evalin('base', 'tradingPara.holdingTime');
% % tradingDate = res(:, 1);
% tradingDate = res.Date;
% tradingIndex = ((tradingPara.passwayInterval * (passway - 1)) + 1:holdingTime:size(res, 1));
% tradingDate = tradingDate(tradingIndex);
% 
% 
% % �����յĳֲַ�����
% res = res(ismember(res.Date, tradingDate), :);

% % �����յ���������
% resTrading = array2table(res, 'VariableNames', factorData.Properties.VariableNames);
% resTrading = resTrading(ismember(resTrading.Date, tradingDate), :);
% 
% % % 
% % % % @2019.2.15 �����ֻ�����ϰ汾����
% % % res = array2table([resTrading.Date, ...
% % %     arrayfun(@(x, y, z) ifelse(isnan(x), NaN, ifelse(x > 1, 1, -1)), table2array(resTrading(:, 2:end)))], ...
% % %     'VariableNames', resTrading.Properties.VariableNames);
% % % res = array2table([res.Date, ...
% % %     arrayfun(@(x, y, z) ifelse(isnan(x), 0, x), table2array(res(:, 2:end)))], ...
% % %     'VariableNames', res.Properties.VariableNames);
% % % % ����ֱ�Ӹĳɾ����ź�ΪʲôЧ�����ܶࣿ
% 
% % resTrading��Ϊ��������getholdingdirect.m�õ������յĳֲַ�����
% res = getholdingdirect(resTrading);

if tradingPara.direct == -1
    res = array2table([res.Date, table2array(res(:, 2:end)) .* tradingPara.direct], ...
        'VariableNames', res.Properties.VariableNames);
end

% % 
% % ���Ӿ���ֵɸѡ
% res = factorSelect(res);
end

