function [res] = getallvarieties(varietyPath)
% get all varieties name from varietyPath
load(varietyPath)
% cell2mat在这不能用，因为矩阵只能存储数字，或者位数相同的字符串
res = regexp(fut_variety, '^\w+(?=\.)', 'match');
res = cell2table(res, 'VariableNames', {'VarietyName'});
res.VarietyName = sort(res.VarietyName);

end

