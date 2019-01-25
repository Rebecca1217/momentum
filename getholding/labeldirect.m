function res = labeldirect(inputCell, selecNum)
%label trading direct based on factor data

direct = evalin('base', 'tradingPara.direct');
if ~(isnumeric(inputCell))
    error('inputCell should be a 1*n numeric array.')
end

groupNum = evalin('base', 'tradingPara.groupNum');
res = zeros(1, length(inputCell));

validNum = sum(~isnan(inputCell));
selecNum = min(selecNum, floor(validNum / groupNum));
% 保留1：selecNum 做空， validNum - selecNum + 1 : validNum做多；
% [~, ri] = sort(inputCell); 
longIndex = (validNum - selecNum + 1) : validNum;
shortIndex = 1 : selecNum;
% ri = tiedrank(inputCell); % 并列的会有0.5的rank 不行
[~, idx] = sort(inputCell, 'ascend');
[~, idx] = sort(idx, 'ascend'); % 这种处理方式，没有并列，相等的会按照出现的顺序排列，NaN全部排在最后


res(ismember(idx, shortIndex)) = -1 * direct;
res(ismember(idx, longIndex)) = 1 * direct;

end

