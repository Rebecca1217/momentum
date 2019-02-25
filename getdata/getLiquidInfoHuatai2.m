function res = getLiquidInfoHuatai2(dateFrom, dateTo, n, pct, ifPctReverse)
% get all liquid varieties between dateFrom and dateTo
% n��ʾ��ȥn��Ľ��׽���ֵ��pct��ʾ���ճɽ�����pct��Ϊ��
% ��λ��Ĭ���ǴӸߵ�������
% ��������ԣ��ý�������ɸѡ��׼�����ǳɽ����

% ԭ����ֱ�Ӵ��ڻ�����2.0������ѩÿ����µ�liquidityInfo��ȡ
% 2018.12.26�ĳɴ�Z����ѩ��������ı��ȡ���������Լ����ձ�׼ɸѡ

% liquidityInfo��ȡ�ͱ����ʱ����޳���ָ�͹�ծ����ΪҪ�漰һЩ�������㣬���޳��Ƚ����

tradingDay = gettradingday(dateFrom, dateTo);
% varieties = getallvarieties([usualPath, '\fut_variety.mat']);

% �õ�ÿ��ÿ��Ʒ�ֵĽ�����
mainContTable = getBasicData('future');
% mainContTable.Amount = mainContTable.Volume .* mainContTable.Close .* mainContTable.MultiFactor;
% mainContTable = table(mainContTable.Date, mainContTable.ContName, mainContTable.Amount, ...
%     'VariableNames', {'Date', 'ContName', 'Amount'});
mainContTable = table(mainContTable.Date, mainContTable.ContName, mainContTable.Volume, ...
    'VariableNames', {'Date', 'ContName', 'Volume'});

mainContTable.ContName = cellfun(@char, mainContTable.ContName, 'UniformOutput', false);
res = unstack(mainContTable, 'Volume', 'ContName');
res = delStockBondIdx(res); % ԭʼ���ݱ�����û��TS������ֻɾ����5��
res = outerjoin(tradingDay, res, 'type', 'left', 'mergekeys', true);

%% �����ֵ�ͷ�λ��
% ��ȥ60��ƽ���ɽ���
resMovN = [res.Date, movmean(table2array(res(:, 2:end)), [n - 1, 0])];
% ����ÿ�ո�Ʒ�ֳɽ����pct��λ��
dailyPrctile = prctile(table2array(res(:, 2:end)), ...
    ifelse(ifPctReverse, (1 - pct) * 100, pct * 100), 2);

if size(resMovN, 1) ~= size(dailyPrctile, 1)
    error('Please check the dimention of movmean and quantile!')
end
%% �Ƚϻ��liquidity��ǩ

tmpRes = [res.Date, resMovN(:, 2:end) >= dailyPrctile];
tmpRes = array2table(tmpRes, 'VariableNames', res.Properties.VariableNames);

res = tmpRes;
clear tmpRes
end


