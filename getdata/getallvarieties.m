function [res] = getallvarieties(varietyPath)
% get all varieties name from varietyPath
load(varietyPath)
% cell2mat在这不能用，因为矩阵只能存储数字，或者位数相同的字符串
res = regexp(fut_variety, '^\w+(?=\.)', 'match');
res = cell2table(res, 'VariableNames', {'VarietyName'});
% res.VarietyName = char(res.VarietyName); % 这一步有必要吗，之后名称加到价格数据时直接cell不能加？


end

