function res = getunitinfo(dateFrom, dateTo)
% get all varieties multiplier between dateFrom and dateTo

% ����һ����load���ļ����µ�����mat���� ��Ϊÿload��������һ�� loadһ�θ���һ��
% ֻ��ѭ�� �ͺ�������
usualPath = '\\Cj-lmxue-dt\�ڻ�����2.0\usualData';
unitPath = [usualPath, '\PunitInfo'];

tradingDay = gettradingday(dateFrom, dateTo);
varieties = getallvarieties([usualPath, '\fut_variety.mat']);

res = zeros(size(tradingDay, 1), size(varieties.VarietyName, 1)); % Ԥ����
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

