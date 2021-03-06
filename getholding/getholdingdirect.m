function resDirect = getholdingdirect(resTrading)
%输入换仓日因子数据，输出换仓日品种选择及方向矩阵（1表示多头，-1表示空头，NaN表示不持有）

if ~(isa(resTrading, 'table') &&...
    strcmp(resTrading.Properties.VariableNames{1}, 'Date'))
    error('resTrading should be a table with "Date" as 1st column!')
end

groupNum = evalin('base', 'tradingPara.groupNum');

% 分组后有余数，去掉中间余数个数据，这个动作是不是没有必要做？
% 之前漫雪的代码里去除中间余数个数据，因为把每个品种的分组数据保存下来了
% 有必要保存下来吗？
% 只取第一组和最后一组就可以了，不涉及中间的部分。而且中间的数据做了= []处理以后，数都对不齐

% @2019.02.01修改为每天的品种数决定每天操作个数
% 按说应该是这么搞的，不然最前面品种少的时候可能都不够分，但貌似也是可以限制的
resTrading = genRank(resTrading, 0);
% 这里的秩已经是剔除了流动性品种以后的

resDirect = nan(height(resTrading), width(resTrading));
resDirect = array2table(resDirect, 'VariableNames', resTrading.Properties.VariableNames);
resDirect.Date = resTrading.Date;



for iDay = 1 : height(resTrading)
   % 今天所有的品种
   dataI = table2array(resTrading(iDay, 2:end));
   totalNumI = sum(~isnan(dataI));
   % 今天操作的品种
   tradeNumI = floor(totalNumI / groupNum);
   
   directI = zeros(1, length(dataI));
   shortIdx = ismember(dataI, 1:tradeNumI);
   longIdx = ismember(dataI, totalNumI - tradeNumI + 1 : totalNumI);
   directI(shortIdx) = -1;
   directI(longIdx) = 1;
   resDirect(iDay, 2:end) = array2table(directI);
end

% 
% % 貌似还是有必要，因为也想看看中间其他组的表现啊，看这个因子是否有区分度 先不用管了，在单独测因子的时候看过区分度了
% num = floor((size(resTrading, 2) - 1 ) / groupNum); % 每组有几个品种
% 
% % 对resTrading的每一行进行sort后取前num个做空，后num个做多
% % 如果遇到非空数值还不到2*num的情况，就缩减选择品种个数
% res = table2array(resTrading(:, 2:end));
% res = num2cell(res, 2);
% res = cellfun(@(o) labeldirect(o, num), res, 'UniformOutput', false);
% % res = cellfun(@(o) labelDirectRank(o, num), res, 'UniformOutput', false);
% res = [resTrading.Date cell2mat(res)]; % add Date and convert it to table
% res = array2table(res, 'VariableName', resTrading.Properties.VariableNames);
% % 这个地方用rowfun能不能实现？ 感觉应该是可以的，但是试了一下不行。。
% error msg: 未定义与 'function_handle' 类型的输入参数相对应的函数 'rowfun'。
% 感觉是2016B版本的rowfun有点问题，网上也有人遇到。暂时用arrayfun或者cellfun代替。
% 
% %% 12.28 加入MA限制
% % 计算MA
% numMA = 20;
% % resTrading.Date
% 
% basicData = getBasicData('future');
% basicData.ContName = cellfun(@char, basicData.ContName, 'UniformOutput', false);
% basicData.AdjClose = basicData.Close .* basicData.AdjFactor;
% 
% adjClose = table(basicData.Date, basicData.ContName, basicData.AdjClose, ...
%     'VariableNames', {'Date', 'ContName', 'AdjClose'});
% adjClose = unstack(adjClose, 'AdjClose', 'ContName');
% adjClose = delStockBondIdx(adjClose);
% closeMA = movmean(table2array(adjClose(:, 2:end)), [numMA - 1, 0]);
% 
% labelMA = table2array(adjClose(:, 2:end)) >= closeMA;
% labelMA = double(labelMA);
% labelMA = arrayfun(@(x, y, z) ifelse(x == 0, -1, x), labelMA); % 不能简单这么处理 因为0可能是小于MA 也可能是空值
% labelNonNaN = ~isnan(table2array(adjClose(:, 2:end)));
% labelMA = [adjClose.Date, labelMA .* labelNonNaN]; % labelMA中1表示AdjClose>MA20，-1表示小于，0表示AdjClose是NaN
% 
% %% 加入MA筛选后的结果
% 
% % 日期选择 
% [~, idx, ~] = intersect(labelMA(:, 1), res.Date);
% labelMA = labelMA(idx, :);
% 
% % 对比结果
% tmp = [res.Date, table2array(res(:, 2:end)) == labelMA(:, 2:end)];
% tmp = [res.Date, tmp(:, 2:end) .* table2array(res(:, 2:end))]; 
% 
% res = array2table(tmp, 'VariableNames', res.Properties.VariableNames);

end


