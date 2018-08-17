function res = getholding(win, passway)
%得到每期持仓品种和方向
% 先得到换仓日的，然后填充到中间的每天得到完整的持仓品种和方向，
% 之后再考虑手数和合约名字的问题
factorDataPath = evalin('base', 'factorDataPath');
factorName = evalin('base', 'factorName');
load([factorDataPath, factorName, '\window', num2str(win), '.mat'])

%% 剔除流动性差的品种
liquidityInfo = evalin('base', 'liquidityInfo');
% 这里factorData因子数据是缺失第一个时间窗口的；liquidityInfo是from-to全部时间的
res = table2array(factorData(:, 2:end)) .* ...
    liquidityInfo((win + 1 : end), :); % 忽略Warn，factorData是load出来的

res = [factorData.Date, res]; % 流动性品种的每日因子数据

%% 确定各品种的持仓
% 所有换仓日 换仓周期40天，通道数40，两层循环（因子窗口，通道数）
holdingTime = evalin('base', 'tradingPara.holdingTime');
tradingDate = res(:, 1);
tradingIndex = (passway:holdingTime:size(res, 1));
tradingDate = tradingDate(tradingIndex);
% iWin = 1, passway = 1时，从因子出现的第一天就开始配置

% 换仓日的因子数据
resTrading = array2table(res, 'VariableNames', factorData.Properties.VariableNames);
resTrading = resTrading(ismember(resTrading.Date, tradingDate), :);


% resTrading作为参数输入getholdingdirect.m得到换仓日的持仓方向结果
res = getholdingdirect(resTrading);

end

