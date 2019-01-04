function res = premiumSelect(momRes)
%PREMIUMSELECT momRes�Ƕ����ĳֲֽ�����������ص��Ǿ����ֻ��ڻ���۵����Ľ����ճֲֽ��

%% �����Ʒ���ֻ������ֵ
% getPremium
res = getPremium();
[~, idx, ~] = intersect(res.Date, momRes.Date);
res = res(idx, :);

%% ɸѡ�����ࣨ1��Ʒ��Ҫ���ֻ���ۣ�>1�������գ�-1��Ʒ��Ҫ���ڻ���ۣ�<1��

% ifelse ���ܴ���NaN��MATLAB����NaN����Ƚϲ��ҷ���false
res = array2table([res.Date, arrayfun(@(x, y, z) ifelse(isnan(x), NaN, ifelse(x > 1, 1, -1)), table2array(res(:, 2:end)))]);

equalLabel = table2array(momRes(:, 2:end)) == table2array(res(:, 2:end));

res = array2table([momRes.Date, table2array(momRes(:, 2:end)) .* equalLabel], ...
    'VariableNames', momRes.Properties.VariableNames);

end

