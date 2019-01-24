function res = factorSelect(res)
%FACTORSELECT 根据因子绝对值筛选
% 要求做多的品种，因子绝对值要＞0， 做空的品种，因子绝对值要＜0
factorData = evalin('base', 'factorData');

[~, idx, ~] = intersect(factorData.Date, res.Date);
factorLabel = factorData(idx, :);

% ifelse 不能处理NaN，MATLAB里会把NaN参与比较并且返回false
factorLabel = array2table([factorLabel.Date, arrayfun(@(x, y, z) ifelse(isnan(x), NaN, ifelse(x > 0, 1, -1)), table2array(factorLabel(:, 2:end)))]);

equalLabel = table2array(res(:, 2:end)) == table2array(factorLabel(:, 2:end));

res = array2table([res.Date, table2array(res(:, 2:end)) .* equalLabel], ...
    'VariableNames', res.Properties.VariableNames);


end

