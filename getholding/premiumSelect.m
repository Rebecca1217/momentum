function res = premiumSelect(momRes)
%PREMIUMSELECT momRes是动量的持仓结果，函数返回的是经过现货期货溢价调整的交易日持仓结果

%% 计算各品种现货溢价数值
% getPremium
res = getPremium();
[~, idx, ~] = intersect(res.Date, momRes.Date);
res = res(idx, :);

%% 筛选：做多（1）品种要求现货溢价（>1），做空（-1）品种要求期货溢价（<1）

% ifelse 不能处理NaN，MATLAB里会把NaN参与比较并且返回false
res = array2table([res.Date, arrayfun(@(x, y, z) ifelse(isnan(x), NaN, ifelse(x > 1, 1, -1)), table2array(res(:, 2:end)))]);

equalLabel = table2array(momRes(:, 2:end)) == table2array(res(:, 2:end));

res = array2table([momRes.Date, table2array(momRes(:, 2:end)) .* equalLabel], ...
    'VariableNames', momRes.Properties.VariableNames);

end

