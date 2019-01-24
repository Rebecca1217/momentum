function res = getLiquidInfoHuatai(dateFrom, dateTo, n, pct, ifPctReverse)
% get all liquid varieties between dateFrom and dateTo
% n表示过去n天的交易金额均值，pct表示当日成交金额的pct分为点
% 分位数默认是从高到低排序

% 按照华泰证券的标准筛选： 主力合约过去60天平均成交金额，计算每日成交金额
% usualPath = '\\Cj-lmxue-dt\期货数据2.0\usualData';
% liquidPath = [usualPath, '\liquidityInfo'];  %
% 原先是直接从期货数据2.0里面漫雪每天更新的liquidityInfo读取
% 2018.12.26改成从Z盘漫雪重新整理的表读取交易量，自己按照标准筛选

% liquidityInfo获取和保存的时候就剔除股指和国债，因为要涉及一些排序运算，先剔除比较清楚

tradingDay = gettradingday(dateFrom, dateTo);
% varieties = getallvarieties([usualPath, '\fut_variety.mat']);

% 得到每天每个品种的交易量
mainContTable = getBasicData('future');
mainContTable.Amount = mainContTable.Volume .* mainContTable.Close .* mainContTable.MultiFactor;
mainContTable = table(mainContTable.Date, mainContTable.ContName, mainContTable.Amount, ...
    'VariableNames', {'Date', 'ContName', 'Amount'});

mainContTable.ContName = cellfun(@char, mainContTable.ContName, 'UniformOutput', false);
res = unstack(mainContTable, 'Amount', 'ContName');
res = delStockBondIdx(res); % 原始数据本来就没有TS，所以只删除了5列
res = outerjoin(tradingDay, res, 'type', 'left', 'mergekeys', true);

%% 计算均值和分位数
% 过去60日平均成交量
resMovN = [res.Date, movmean(table2array(res(:, 2:end)), [n - 1, 0])];
% 计算每日各品种成交金额pct分位数
dailyPrctile = prctile(table2array(res(:, 2:end)), ...
    ifelse(ifPctReverse, (1 - pct) * 100, pct * 100), 2);

if size(resMovN, 1) ~= size(dailyPrctile, 1)
    error('Please check the dimention of movmean and quantile!')
end
%% 比较获得liquidity标签

tmpRes = [res.Date, resMovN(:, 2:end) >= dailyPrctile];
tmpRes = array2table(tmpRes, 'VariableNames', res.Properties.VariableNames);

res = tmpRes;
clear tmpRes
end


