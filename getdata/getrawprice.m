function res = getrawprice(pricePath, varieties, dateFrom, dateTo, priceType)

tradingDay = gettradingday(dateFrom, dateTo);
% tradingDay = tradingDay(tradingDay.Date >= str2double(dateFrom) & ...
%     tradingDay.Date <= str2double(dateTo), :);

res = tradingDay;
for iVar = 1 : size(varieties, 1)
    varName = char(varieties.VarietyName(iVar));
    load([pricePath, '\', varName, '.mat'])
    str = ['iPrice = futureData.', priceType, ';'];
    eval(str)
    iData = table(futureData.Date, iPrice, ...
        'VariableName', {'Date', varName});
%     iData = iData(iData.Date >= str2double(dateFrom) & ...
%         iData.Date <= str2double(dateTo), :); % 加上type left以后就不用先截取iData了
    res = outerjoin(res, iData, 'type', 'left', 'MergeKeys', true); 
    % outerjoin会把join后的结果按照key排序
end

end