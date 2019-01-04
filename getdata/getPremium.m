function res = getPremium()
%GETPREMIUM 得到的是全部时间的现货溢价数据
% spot/future， ＞1表示现货溢价，＜1表示期货溢价

% 注：现货数据有个问题，不全，不能两个矩阵直接对应相除，所以采用outerjoin的形式
%% 期货数据
future = getBasicData('future');
future = table(future.Date, future.ContName, future.Close, ...
    'VariableNames', {'Date', 'ContName', 'Close'});
future.ContName = cellfun(@char, future.ContName, 'UniformOutput', false);

%% 现货数据
spot = getBasicData('spot');
spot = table(spot.Date, spot.ContName, spot.SpotPrice, ...
    'VariableNames', {'Date', 'ContName', 'SpotPrice'});
spot.ContName = cellfun(@char, spot.ContName, 'UniformOutput', false);

%% 溢价结果
res = outerjoin(future, spot, 'type', 'left', 'MergeKeys', true, 'Keys', [1, 2]);
res.SpotPremium = res.SpotPrice ./ res.Close;
res = table(res.Date, res.ContName, res.SpotPremium, ...
    'VariableNames', {'Date', 'ContName', 'SpotPremium'});

res = unstack(res, 'SpotPremium', 'ContName');
res = delStockBondIdx(res);


end

