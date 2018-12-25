function holdingInfo = getholdinghands(posTradingDirect, posFullDirect, capital)
%input posFullDirect, capital, output daily holdinghands
%平均分配资金，后期需要加参数设置其他加权资金分配方式,capital指的是名义市值，这里不考虑保证金
%这个地方不用再剔除一遍流动性，因为计算因子的时候剔过了,posFullDirect中不含非流动性

tradingNum = sum(abs(table2array(posTradingDirect(:, 2:end))), 2);
tradingAmount = capital ./ tradingNum;
fullTradingNum = sum(abs(table2array(posFullDirect(:, 2:end))), 2);
fullTradingAmount = capital ./ fullTradingNum;
% load price 
% 合约手数 = 名义市值 ./ （合约乘数 .* 合约价格） .* posfullDirect
factorPara = evalin('base', 'factorPara');
dataPara.path = factorPara.dataPath;
dataPara.dateFrom = str2double(datestr(datenum(num2str(factorPara.dateFrom), 'yyyymmdd') - 10, 'yyyymmdd'));
dataPara.dateTo = factorPara.dateTo;
dataPara.priceType = factorPara.priceType;

priceData = getpricedata(dataPara);
% 这个地方priceData要保留比dateFrom稍往前一点，因为需要上一个交易日的价格来确定调仓日手数
% 第一天就是调仓日的话，priceData需要保留第一天往前一个交易日的价格信息
% priceData = priceData(priceData.Date >= min(posFullDirect.Date) & ...
%     priceData.Date <= max(posFullDirect.Date), :);

% load 合约乘数 unitInfo 和 liquidInfo一样，每天晚上更新table数据，用的时候load就可以了
load('E:\futureData\unitInfo.mat')
unitInfo = unitInfo(unitInfo.Date >= min(posFullDirect.Date) & ...
    unitInfo.Date <= max(posFullDirect.Date), :);

% unitInfo和liquidityInfo一样，都需要剔除股指期货和国债期货
unitInfo = delStockBondIdx(unitInfo);

% get raw hands
% 这里只get换仓日就可以了， 中间部分的手数和换仓日一样，填充上即可
% 注意，如果中间主力合约换了，那需要平掉当前合约，开仓新的主力合约，这样手数就会有变化。。
% 这点怎么处理？暂时先不处理

unitInfoTrading = unitInfo(ismember(unitInfo.Date,  posTradingDirect.Date), :);
priceDataHolding = priceData(ismember(priceData.Date, posTradingDirect.Date), :);
fullUnitInfoTrading = unitInfo(ismember(unitInfo.Date, posFullDirect.Date), :);
fullPriceDataHolding = priceData(ismember(priceData.Date, posFullDirect.Date), :);
% 下面这段用于计算调仓日上一个交易日的收盘价格，计算t日手数用的是t-1收盘价
[~, ra, ~] = intersect(priceData.Date, posTradingDirect.Date);
priceLastDay = priceData((ra - 1), :);
clear ra

hands = round(...
    repmat(tradingAmount, 1, size(posTradingDirect, 2) - 1)  ./ ...
    (table2array(unitInfoTrading(:, 2:end)) .* ...
    table2array(priceLastDay(:, 2:end))) .* ...
    table2array(posTradingDirect(:, 2:end)));
% tradingAmount是平均分配给持仓品种/futAllocationFactor.m里面是平均分配给当天全部流动性品种
% 根据t-1日的收盘价格确定t日的开仓手数，记录在t日
% 这个结果里有0有NaN，0表示有数据但是没选中持仓；NaN表示缺失必要数据（价格/合约乘数等）

% 这里不需要用最小变动单位调整，就先取整就好了，最小变动单位的调整在回测平台有
% 往下补全非调仓日的持仓手数
% 先把手数补全时间 再计算 不然计算完了还要一个个补一遍时间
totalDate = posFullDirect(:, 1);
hands = array2table([posTradingDirect.Date hands], ...
    'VariableNames', posTradingDirect.Properties.VariableNames);
fullHands = outerjoin(hands, totalDate, 'MergeKeys', true);
fullHands = varfun(@fillnan, fullHands);
fullHands.Properties.VariableNames = posFullDirect.Properties.VariableNames;
holdingInfo.fullHands = fullHands;


% 回测平台holdingInfo需要的信息有：每日持仓手数，名义分配市值，持仓名义权重，实际持有市值，实际持仓权重
holdingInfo.normSize = repmat(fullTradingAmount, 1, size(posFullDirect, 2) -1) .* ...
    abs(table2array(posFullDirect(:, 2:end)));
holdingInfo.normWeight = bsxfun(@times, holdingInfo.normSize, ...
    repmat(1./capital, 1, size(holdingInfo.normSize, 2)));
holdingInfo.realSize = abs(table2array(holdingInfo.fullHands(:, 2:end))) .*...
    table2array(fullPriceDataHolding(:, 2:end)) .* ...
    table2array(fullUnitInfoTrading(:, 2:end));
realSizeDly = nansum(holdingInfo.realSize, 2);
holdingInfo.realWeight = bsxfun(@times, holdingInfo.realSize, ...
    repmat(1./realSizeDly, 1, size(holdingInfo.realSize, 2)));
% 给每个表加上表头
holdingInfo.normSize = array2table([posFullDirect.Date holdingInfo.normSize],...
    'VariableNames', posFullDirect.Properties.VariableNames);
holdingInfo.normWeight = array2table([posFullDirect.Date holdingInfo.normWeight],...
    'VariableNames', posFullDirect.Properties.VariableNames);
holdingInfo.realSize = array2table([posFullDirect.Date holdingInfo.realSize],...
    'VariableNames', posFullDirect.Properties.VariableNames);
holdingInfo.realWeight = array2table([posFullDirect.Date holdingInfo.realWeight],...
    'VariableNames', posFullDirect.Properties.VariableNames);


    
end



