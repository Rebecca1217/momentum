function res = getholdingdirect(resTrading)
%���뻻�����������ݣ����������Ʒ��ѡ�񼰷������1��ʾ��ͷ��-1��ʾ��ͷ��NaN��ʾ�����У�

if ~(isa(resTrading, 'table') &&...
    strcmp(resTrading.Properties.VariableNames{1}, 'Date'))
    error('resTrading should be a table with "Date" as 1st column!')
end

groupNum = evalin('base', 'tradingPara.groupNum');

% �������������ȥ���м����������ݣ���������ǲ���û�б�Ҫ����
% ֻȡ��һ������һ��Ϳ����ˣ����漰�м�Ĳ��֡������м����������= []�����Ժ������Բ���
num = floor((size(resTrading, 2) - 1 ) / groupNum);

% ��resTrading��ÿһ�н���sort��ȡǰnum�����գ���num������
% ��������ǿ���ֵ������2*num�������������ѡ��Ʒ�ָ���
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
% ����1��selecNum ���գ� validNum - selecNum + 1 : validNum���ࣻ
[~, ri] = sort(inputCell);
longIndex = (validNum - selecNum + 1) : validNum;
shortIndex = 1 : selecNum;
res(ismember(ri, shortIndex)) = -1;
res(ismember(ri, longIndex)) = 1;

end