function res = getholding(passway)
%得到每期持仓品种和方向
% 先得到换仓日的，然后填充到中间的每天得到完整的持仓品种和方向，
% 之后再考虑手数和合约名字的问题

factorData = evalin('base', 'factorData');
%% 剔除流动性差的品种
% @2018.12.28 发现一个大bug！！！label不能直接和数值相乘。。label要和label相乘。。
% 之前做的时候liquidityInfo直接和factorData相乘，以为是把流动性低的剔除了，实际是把factorData里流动性低的品种因子值改为0了。。
% 2个改正方案：1、把label矩阵里0都改成NaN，然后再相乘，思路和原来一样
% 2、因子先排序，选出品种标签以后，标签矩阵和标签矩阵点乘得到最后的持仓标签
liquidityInfo = evalin('base', 'liquidityInfo');
% 这里factorData因子数据是缺失第一个时间窗口的；liquidityInfo是from-to全部时间的
liquidityInfo = arrayfun(@(x, y, z) ifelse(x == 0, NaN, x), liquidityInfo);
res = table2array(factorData(:, 2:end)) .* liquidityInfo; % 忽略Warn，factorData是load出来的
res = [factorData.Date, res]; % 流动性品种的每日因子秩


%% @2018.12.27 剔除波动率低的品种（华泰新动量因子）
% 波动率回溯时长固定14
% volatilityInfo = getVolatility(pct, factorData.Date(1), factorData.Date(end), 'ATR');
% res = res(:, 2:end) .* table2array(volatilityInfo(:, 2:end));
% res = [factorData.Date, res]; % 流动性 & 高波动率品种的每日因子数据
% 
% %% @2018.12.28 剔除波动率低的品种（华泰新动量因子）
% % 波动率回溯时长与因子窗口一致
% win = evalin('base', 'window(iWin)');
% pct = evalin('base', 'tradingPara.pct');
% volatilityInfo = getVolatility(win, pct, factorData.Date(1), factorData.Date(end), 'sigma');
% volatilityInfo = arrayfun(@(x, y, z) ifelse(x == 0, NaN, x), table2array(volatilityInfo(:, 2:end)));
% 
% res = res(:, 2:end) .* volatilityInfo;
% res = [factorData.Date, res]; % 流动性 & 高波动率品种的每日因子数据

%% 确定各品种的持仓
% 所有换仓日 换仓周期40天，通道数40，两层循环（因子窗口，通道数）
holdingTime = evalin('base', 'tradingPara.holdingTime');
tradingDate = res(:, 1);
tradingIndex = (passway:holdingTime:size(res, 1));
tradingDate = tradingDate(tradingIndex);
% iWin = 1, passway = 1时，从因子出现的第一天就开始配置

% 换仓日的因子排序
resTrading = array2table(res, 'VariableNames', factorData.Properties.VariableNames);
resTrading = resTrading(ismember(resTrading.Date, tradingDate), :);


% resTrading作为参数输入getholdingdirect.m得到换仓日的持仓方向结果
res = getholdingdirect(resTrading);

% 
% % 现货溢价筛选
% res = premiumSelect(res);

% % 
% % 因子绝对值筛选
% res = factorSelect(res);
end

