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