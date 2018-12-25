function [res] = getallvarieties(varietyPath)
% get all varieties name from varietyPath
load(varietyPath)
% cell2mat���ⲻ���ã���Ϊ����ֻ�ܴ洢���֣�����λ����ͬ���ַ���
res = regexp(fut_variety, '^\w+(?=\.)', 'match');
res = cell2table(res, 'VariableNames', {'VarietyName'});
res.VarietyName = sort(res.VarietyName);

end

