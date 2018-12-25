function res= getliquidinfo(dateFrom, dateTo)
% get all liquid varieties between dateFrom and dateTo
% ���ÿ����������һ�����������������Ż���ʽ
usualPath = '\\Cj-lmxue-dt\�ڻ�����2.0\usualData';
liquidPath = [usualPath, '\liquidityInfo'];

tradingDay = gettradingday(dateFrom, dateTo);
varieties = getallvarieties([usualPath, '\fut_variety.mat']);

res = zeros(size(tradingDay, 1), size(varieties.VarietyName, 1)); % Ԥ����
for iDate = 1:size(tradingDay, 1)
    load([liquidPath, '\', num2str(tradingDay.Date(iDate)), '.mat'])
    [~, ~, ib] = intersect(liquidityInfo, varieties.VarietyName);
    iboole = zeros(1, size(varieties.VarietyName, 1)); % Ԥ�����ڴ�
    iboole(ib) = 1;
    iboole(setdiff(1:size(varieties.VarietyName, 1), ib)) = NaN;
    res(iDate, :) = iboole;
    %   res = vertcat(res, array2table(iboole));
    %  ��ΪҪԤ�����ڴ棬���Դ�ͳ�����ϼ�һֱ�����ַ�ʽ��������
    % ����Ԥ�����ڴ�Ѵ˶�����ʱ���20��������13��
end
res = [tradingDay, array2table(res, 'VariableNames', varieties.VarietyName)];
end