function res = getholdingdirect(resTrading)
%输入换仓日因子数据，输出换仓日品种选择及方向矩阵（1表示多头，-1表示空头，NaN表示不持有）

if ~(isa(resTrading, 'table') &&...
    strcmp(resTrading.Properties.VariableNames{1}, 'Date'))
    error('resTrading should be a table with "Date" as 1st column!')
end

groupNum = evalin('base', 'tradingPara.groupNum');

% 分组后有余数，去掉中间余数个数据，这个动作是不是没有必要做？
% 只取第一组和最后一组就可以了，不涉及中间的部分。而且中间的数据做了= []处理以后，数都对不齐
num = floor((size(resTrading, 2) - 1 ) / groupNum);

% 对resTrading的每一行进行sort后取前num个做空，后num个做多
% 如果遇到非空数值还不到2*num的情况，就缩减选择品种个数
res = table2array(resTrading(:, 2:end));
res = num2cell(res, 2);
res = cellfun(@(o) labeldirect(o, num), res, 'UniformOutput', false);

res = [resTrading.Date cell2mat(res)]; % add Date and convert it to table
res = array2table(res, 'VariableName', resTrading.Properties.VariableNames);
end



function res = labeldirect(inputCell, selecNum)

if ~(isnumeric(inputCell))
    error('inputCell should be a 1*n numeric array.')
end

res = zeros(1, length(inputCell));
% ri = tiedrank(inputCell{1});
% selecNum = min(selecNum, floor(max(ri) / 2));
validNum = sum(~isnan(inputCell));
selecNum = min(selecNum, floor(max(validNum) / 2));
% 保留1：selecNum 做空， validNum - selecNum + 1 : validNum做多；
[~, ri] = sort(inputCell);
longIndex = (validNum - selecNum + 1) : validNum;
shortIndex = 1 : selecNum;
res(ismember(ri, shortIndex)) = -1;
res(ismember(ri, longIndex)) = 1;

end