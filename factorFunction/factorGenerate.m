function res = factorGenerate(factorPara)
% factor generate for momentum

% get price data
dataPara.path = factorPara.dataPath;
dataPara.dateFrom = factorPara.dateFrom;
dataPara.dateTo = factorPara.dateTo;
dataPara.priceType = factorPara.priceType;

priceData = getpricedata(dataPara); % 所有品种从dateFrom到dateTo的收盘价（priceType）

% 根据factorPara.win得到错位一个时间窗口的价格矩阵，两个矩阵点除即可
forwardPrice = priceData((factorPara.win + 1) : end, :); % 向后移动win个交易日
resDate = forwardPrice.Date;
resFactor = table2array(forwardPrice(:, 2:end)) ./ ...
    table2array(priceData(1:(size(priceData, 1) - factorPara.win), 2:end)) - 1;
res = [resDate, resFactor];
res = array2table(res, 'VariableNames', priceData.Properties.VariableNames);
end

