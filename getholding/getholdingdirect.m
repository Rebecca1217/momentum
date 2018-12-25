function res = getholdingdirect(resTrading)
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

% 貌似还是有必要，因为也想看看中间其他组的表现啊，看这个因子是否有区分度
num = floor((size(resTrading, 2) - 1 ) / groupNum);

% 对resTrading的每一行进行sort后取前num个做空，后num个做多
% 如果遇到非空数值还不到2*num的情况，就缩减选择品种个数
res = table2array(resTrading(:, 2:end));
res = num2cell(res, 2);
res = cellfun(@(o) labeldirect(o, num), res, 'UniformOutput', false);
res = [resTrading.Date cell2mat(res)]; % add Date and convert it to table
res = array2table(res, 'VariableName', resTrading.Properties.VariableNames);
% 这个地方用rowfun能不能实现？ 感觉应该是可以的，但是试了一下不行。。
% error msg: 未定义与 'function_handle' 类型的输入参数相对应的函数 'rowfun'。
% 感觉是2016B版本的rowfun有点问题，网上也有人遇到。暂时用arrayfun或者cellfun代替。

end


