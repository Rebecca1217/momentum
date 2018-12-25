function res = getunitinfo(dateFrom, dateTo)
% get all varieties multiplier between dateFrom and dateTo

% 不能一次性load进文件夹下的所有mat数据 因为每load进来名字一样 load一次覆盖一次
% 只能循环 就很慢。。
usualPath = '\\Cj-lmxue-dt\期货数据2.0\usualData';
unitPath = [usualPath, '\PunitInfo'];

tradingDay = gettradingday(dateFrom, dateTo);
varieties = getallvarieties([usualPath, '\fut_variety.mat']);

res = zeros(size(tradingDay, 1), size(varieties.VarietyName, 1)); % 预分配
for iDate = 1:size(tradingDay, 1)

    load([unitPath, '\', num2str(tradingDay.Date(iDate)), '.mat'])
    infoData = cell2table(infoData, 'VariableNames', {'VarietyName' 'Unit'});
    [~, ra, rb] = intersect(varieties.VarietyName, infoData.VarietyName);
    fullUnitInfo = varieties;
    fullUnitInfo.Unit = NaN(size(fullUnitInfo, 1), 1);
    fullUnitInfo.Unit(ra) = infoData.Unit(rb);
    res(iDate, :) = transpose(fullUnitInfo.Unit);  

end
res = [tradingDay.Date res];
res = array2table(res, 'VariableNames', ...
    [{'Date'}, transpose(varieties.VarietyName)]);

end

