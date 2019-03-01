function res = getholding(passway, tradingPara)
%得到每期持仓品种和方向
% 先得到换仓日的，然后填充到中间的每天得到完整的持仓品种和方向，
% 之后再考虑手数和合约名字的问题
% 
% % @2019.2.28 不用factorData,读取longVolume 和 shortVolume 这两个数据集得到信号，再用流动性筛选一遍即可
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

% 先剔除流动性差的品种
varNames = longVolumeDelta.Properties.VariableNames;
% liquidityInfo = evalin('base', 'liquidityInfo');
% liquidityInfo = arrayfun(@(x, y, z) ifelse(x == 0, NaN, x), liquidityInfo);
% longVolumeDelta = [longVolumeDelta.Date, table2array(longVolumeDelta(:, 2:end)) .* liquidityInfo];
% shortVolumeDelta = [shortVolumeDelta.Date, table2array(shortVolumeDelta(:, 2:end)) .* liquidityInfo];
% shiftLongVolume = [longVolume.Date, shiftLongVolume(:, 2:end) .* liquidityInfo];
% shiftShortVolume = [shortVolume.Date, shiftShortVolume(:, 2:end) .* liquidityInfo];
longVolumeDelta = table2array(longVolumeDelta);
shortVolumeDelta = table2array(shortVolumeDelta);

% shiftLongVolume 得到1 -1  shiftShortVolume得到的1 -1 改为-1 1  二者相乘得到1 0
% 再和shiftVolume的Label乘一遍，就是最后的信号矩阵

% shiftLongVolume = array2table(shiftLongVolume, 'VariableNames', longVolume.Properties.VariableNames);
% shiftShortVolume = array2table(shiftShortVolume, 'VariableNames', shortVolume.Properties.VariableNames);

% longRes = getholdingdirect(shiftLongVolume);
% shortRes = getholdingdirect(shiftShortVolume);
% shortRes = array2table([shortRes.Date, -table2array(shortRes(:, 2:end))], 'VariableNames', shortRes.Properties.VariableNames);

% res = table2array(longRes(:, 2:end)) .* table2array(shortRes(:, 2:end)) .* table2array(longRes(:, 2:end));
% res = array2table([longRes.Date, res], 'VariableNames', longRes.Properties.VariableNames);
% % 再筛选 多单
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
% %% 剔除流动性差的品种
% % @2018.12.28 发现一个大bug！！！label不能直接和数值相乘。。label要和label相乘。。
% % 之前做的时候liquidityInfo直接和factorData相乘，以为是把流动性低的剔除了，实际是把factorData里流动性低的品种因子值改为0了。。
% % 2个改正方案：1、把label矩阵里0都改成NaN，然后再相乘，思路和原来一样
% % 2、因子先排序，选出品种标签以后，标签矩阵和标签矩阵点乘得到最后的持仓标签
% liquidityInfo = evalin('base', 'liquidityInfo');
% % 这里factorData因子数据是缺失第一个时间窗口的；liquidityInfo是from-to全部时间的
% liquidityInfo = arrayfun(@(x, y, z) ifelse(x == 0, NaN, x), liquidityInfo);
% res = table2array(factorData(:, 2:end)) .* liquidityInfo; % 忽略Warn，factorData是load出来的
% res = [factorData.Date, res]; % 流动性品种的每日因子秩
% % 
% % 
% % %% @2018.12.27 剔除波动率低的品种（华泰新动量因子）
% % % 波动率回溯时长固定14
% % % volatilityInfo = getVolatility(pct, factorData.Date(1), factorData.Date(end), 'ATR');
% % % res = res(:, 2:end) .* table2array(volatilityInfo(:, 2:end));
% % % res = [factorData.Date, res]; % 流动性 & 高波动率品种的每日因子数据
% % % % 
% % % %% @2018.12.28 剔除波动率低的品种（华泰新动量因子）
% % % 波动率回溯时长与因子窗口一致
% % % win = evalin('base', 'window(iWin)');
% % win = tradingPara.volWin;
% % pct = evalin('base', 'tradingPara.pct');
% % volatilityInfo = getVolatility(win, pct, factorData.Date(1), factorData.Date(end), 'sigma');
% % volatilityInfo = arrayfun(@(x, y, z) ifelse(x == 0, NaN, x), table2array(volatilityInfo(:, 2:end)));
% % 
% % res = res(:, 2:end) .* volatilityInfo;
% % res = [factorData.Date, res]; % 流动性 & 高波动率品种的每日因子数据
% % % 
% % 
% % % % @ 2019.02.24 剔除仓单数据当天为0的品种
% % % warrantLabel = evalin('base', 'warrantLabel');
% % % res = res(:, 2:end) .* warrantLabel;
% % % res = [factorData.Date, res]; % 流动性 & 仓单不为0的品种每日因子数据
% % 
% % 
% %% 确定各品种的持仓
% % 所有换仓日 换仓周期40天，通道数40，两层循环（因子窗口，通道数）
% holdingTime = evalin('base', 'tradingPara.holdingTime');
% % tradingDate = res(:, 1);
% tradingDate = res.Date;
% tradingIndex = ((tradingPara.passwayInterval * (passway - 1)) + 1:holdingTime:size(res, 1));
% tradingDate = tradingDate(tradingIndex);
% 
% 
% % 换仓日的持仓方向结果
% res = res(ismember(res.Date, tradingDate), :);

% % 换仓日的因子排序
% resTrading = array2table(res, 'VariableNames', factorData.Properties.VariableNames);
% resTrading = resTrading(ismember(resTrading.Date, tradingDate), :);
% 
% % % 
% % % % @2019.2.15 绝对现货溢价老版本调整
% % % res = array2table([resTrading.Date, ...
% % %     arrayfun(@(x, y, z) ifelse(isnan(x), NaN, ifelse(x > 1, 1, -1)), table2array(resTrading(:, 2:end)))], ...
% % %     'VariableNames', resTrading.Properties.VariableNames);
% % % res = array2table([res.Date, ...
% % %     arrayfun(@(x, y, z) ifelse(isnan(x), 0, x), table2array(res(:, 2:end)))], ...
% % %     'VariableNames', res.Properties.VariableNames);
% % % % 这样直接改成绝对信号为什么效果会差很多？
% 
% % resTrading作为参数输入getholdingdirect.m得到换仓日的持仓方向结果
% res = getholdingdirect(resTrading);

if tradingPara.direct == -1
    res = array2table([res.Date, table2array(res(:, 2:end)) .* tradingPara.direct], ...
        'VariableNames', res.Properties.VariableNames);
end

% % 
% % 因子绝对值筛选
% res = factorSelect(res);
end

