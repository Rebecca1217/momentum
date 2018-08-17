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
    % ����ط���ʵ��ʵ�ֵ���join(A, B) ��AΪ��������B join���������A�еļ�Bû�еĻ��ͷ��ؿ�
    % ��MATLABҪ��B�б������A�����еļ����������˸����֣��Ȱ�B��ȡ��û�ж�����Ϣ����outerjoin
end

end