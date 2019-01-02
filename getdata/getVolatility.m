function res = getVolatility(win, pct, dateFrom, dateTo, type)
%GETVOLATILITY win是计算波动率的时间窗口，和动量因子窗口一致，pct是筛选的百分位点，从低到高排列
% 比如pct = 0.25表示，剔除波动率从低到高排在前25%的（标签为0）
% atr数据是从漫雪TableData直接读的，固定win = 14，所以函数先不设置win参数

tradingDay = gettradingday(dateFrom, dateTo);

basicData = getBasicData();
basicData.ContName = cellfun(@char, basicData.ContName, 'UniformOutput', false);


if strcmp(type, 'ATR')
    basicData.ATRRatio = basicData.ATRABS ./ basicData.Close; % 因为ATR值本身也是量纲不可比的
    % 直接除以没复权的收盘价，因为ATR本身就是用当天价格与同合约前一天价格计算的，所以除以当天收盘价就可以
    
    %% 计算每日win窗口（win = 14）的波动率
    % resMovStd = [res.Date, movstd(table2array(res(:, 2:end)), [win - 1, 0])];
    volData = table(basicData.Date, basicData.ContName, basicData.ATRRatio, ...
        'VariableNames', {'Date', 'ContName', 'Vol'});
    volData = unstack(volData, 'Vol', 'ContName');
    %% 补齐0价格2019.1.2
    varNames = volData.Properties.VariableNames;
    volData = array2table([volData.Date, table2array(varfun(@fill0Price, volData(:, 2:end)))], ...
        'VariableNames', varNames);
    
else
    % @2019.1.2用标准差的话需要daily return的标准差而不是绝对价格的标准差
    basicData.AdjClose = basicData.Close .* basicData.AdjFactor;
    volData = table(basicData.Date, basicData.ContName, basicData.AdjClose, ...
        'VariableNames', {'Date', 'ContName', 'AdjClose'});
    volData = unstack(volData, 'AdjClose', 'ContName');
    % FU品种有段价格是0
    % 将价格数据向上补齐，再求收益率不然会报错
    % 补齐0价格2019.1.2
    varNames = volData.Properties.VariableNames;
    volData = array2table([volData.Date, table2array(varfun(@fill0Price, volData(:, 2:end)))], ...
        'VariableNames', varNames);
    % 价格绝对值转化为daily return
    volData = array2table([volData.Date, ...
        [nan(1, size(volData, 2) - 1);...
        price2ret(table2array(volData(:, 2:end)), [], 'Periodic')]], ...
        'VariableNames', volData.Properties.VariableNames);
    movStd = array2table([volData.Date, ...
        movstd(table2array(volData(:, 2:end)), [win - 1, 0])], ...
        'VariableName', volData.Properties.VariableNames);
    volData = movStd;
    clear movStd
end

volData = delStockBondIdx(volData);  % 原始数据本来就没有TS，所以只删除了5列

%% 筛选分位数贴标签
dailyPrctile = prctile(table2array(volData(:, 2:end)), pct * 100, 2);
if size(volData, 1) ~= size(dailyPrctile, 1)
    error('Please check the dimention of movstd and quantile!')
end
% middle = prctile(table2array(volData(:, 2:end)), 50, 2);
% dailyPrctile2 = prctile(table2array(volData(:, 2:end)), (1 - pct) * 100, 2);

%% 比较获得volatility标签
res = [volData.Date, table2array(volData(:, 2:end)) > dailyPrctile];
res = array2table(res, 'VariableNames', volData.Properties.VariableNames);
res = outerjoin(tradingDay, res, 'type', 'left', 'mergekeys', true);

end

