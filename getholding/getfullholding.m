function res = getfullholding(posTradingDirect, fullDate)
%input is the pos direct at trading Date, output is the full time series of
% pos direct


res = outerjoin(posTradingDirect, array2table(fullDate, 'VariableNames', {'Date'}),...
    'MergeKeys', true);

% it's a pity that fillmissing can only be used in version after MATLAB 2016B...
% res = fillmissing(res, 'previous', 1);

% fill missing data
% 对table每一列向量化后做处理，再合成为一个table

fullRes = table2array(res(:, 2:end));
fullRes = num2cell(fullRes, 1);

fullRes = cellfun(@fillnan, fullRes, 'UniformOutput', false);
fullRes = [res.Date cell2mat(fullRes)];
res = array2table(fullRes, 'VariableName', res.Properties.VariableNames);

end

