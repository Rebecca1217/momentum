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
    iData = iData(iData.Date >= str2double(dateFrom) & ...
        iData.Date <= str2double(dateTo), :);
    res = outerjoin(res, iData, 'MergeKeys', true); 
    % 这个地方其实想实现的是join(A, B) 以A为基础，把B join上来，如果A有的键B没有的话就返回空
    % 但MATLAB要求B中必须包含A中所有的键，所以做了个这种，先把B截取成没有多余信息，再outerjoin
end

end