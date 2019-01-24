function res = factorSelect(res)
%FACTORSELECT �������Ӿ���ֵɸѡ
% Ҫ�������Ʒ�֣����Ӿ���ֵҪ��0�� ���յ�Ʒ�֣����Ӿ���ֵҪ��0
factorData = evalin('base', 'factorData');

[~, idx, ~] = intersect(factorData.Date, res.Date);
factorLabel = factorData(idx, :);

% ifelse ���ܴ���NaN��MATLAB����NaN����Ƚϲ��ҷ���false
factorLabel = array2table([factorLabel.Date, arrayfun(@(x, y, z) ifelse(isnan(x), NaN, ifelse(x > 0, 1, -1)), table2array(factorLabel(:, 2:end)))]);

equalLabel = table2array(res(:, 2:end)) == table2array(factorLabel(:, 2:end));

res = array2table([res.Date, table2array(res(:, 2:end)) .* equalLabel], ...
    'VariableNames', res.Properties.VariableNames);


end

