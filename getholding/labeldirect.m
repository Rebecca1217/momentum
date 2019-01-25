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
% ����1��selecNum ���գ� validNum - selecNum + 1 : validNum���ࣻ
% [~, ri] = sort(inputCell); 
longIndex = (validNum - selecNum + 1) : validNum;
shortIndex = 1 : selecNum;
% ri = tiedrank(inputCell); % ���еĻ���0.5��rank ����
[~, idx] = sort(inputCell, 'ascend');
[~, idx] = sort(idx, 'ascend'); % ���ִ���ʽ��û�в��У���ȵĻᰴ�ճ��ֵ�˳�����У�NaNȫ���������


res(ismember(idx, shortIndex)) = -1 * direct;
res(ismember(idx, longIndex)) = 1 * direct;

end

