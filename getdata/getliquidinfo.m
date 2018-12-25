function res= getliquidinfo(dateFrom, dateTo)
% get all liquid varieties between dateFrom and dateTo
% 这个每个交易日跑一遍下来很慢，想想优化方式
usualPath = '\\Cj-lmxue-dt\期货数据2.0\usualData';
liquidPath = [usualPath, '\liquidityInfo'];

tradingDay = gettradingday(dateFrom, dateTo);
varieties = getallvarieties([usualPath, '\fut_variety.mat']);

res = zeros(size(tradingDay, 1), size(varieties.VarietyName, 1)); % 预分配
for iDate = 1:size(tradingDay, 1)
    load([liquidPath, '\', num2str(tradingDay.Date(iDate)), '.mat'])
    [~, ~, ib] = intersect(liquidityInfo, varieties.VarietyName);
    iboole = zeros(1, size(varieties.VarietyName, 1)); % 预分配内存
    iboole(ib) = 1;
    iboole(setdiff(1:size(varieties.VarietyName, 1), ib)) = NaN;
    res(iDate, :) = iboole;
    %   res = vertcat(res, array2table(iboole));
    %  因为要预分配内存，所以传统的往上加一直变这种方式不适用了
    % 这里预分配内存把此段运行时间从20秒缩减到13秒
end
res = [tradingDay, array2table(res, 'VariableNames', varieties.VarietyName)];
end