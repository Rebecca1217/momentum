function resDirect = getholdingdirect(resTrading)
%���뻻�����������ݣ����������Ʒ��ѡ�񼰷������1��ʾ��ͷ��-1��ʾ��ͷ��NaN��ʾ�����У�

if ~(isa(resTrading, 'table') &&...
    strcmp(resTrading.Properties.VariableNames{1}, 'Date'))
    error('resTrading should be a table with "Date" as 1st column!')
end

groupNum = evalin('base', 'tradingPara.groupNum');

% �������������ȥ���м����������ݣ���������ǲ���û�б�Ҫ����
% ֮ǰ��ѩ�Ĵ�����ȥ���м����������ݣ���Ϊ��ÿ��Ʒ�ֵķ������ݱ���������
% �б�Ҫ����������
% ֻȡ��һ������һ��Ϳ����ˣ����漰�м�Ĳ��֡������м����������= []�����Ժ������Բ���

% @2019.02.01�޸�Ϊÿ���Ʒ��������ÿ���������
% ��˵Ӧ������ô��ģ���Ȼ��ǰ��Ʒ���ٵ�ʱ����ܶ������֣���ò��Ҳ�ǿ������Ƶ�
resTrading = genRank(resTrading, 0);
% ��������Ѿ����޳���������Ʒ���Ժ��

resDirect = nan(height(resTrading), width(resTrading));
resDirect = array2table(resDirect, 'VariableNames', resTrading.Properties.VariableNames);
resDirect.Date = resTrading.Date;



for iDay = 1 : height(resTrading)
   % �������е�Ʒ��
   dataI = table2array(resTrading(iDay, 2:end));
   totalNumI = sum(~isnan(dataI));
   % ���������Ʒ��
   tradeNumI = floor(totalNumI / groupNum);
   
   directI = zeros(1, length(dataI));
   shortIdx = ismember(dataI, 1:tradeNumI);
   longIdx = ismember(dataI, totalNumI - tradeNumI + 1 : totalNumI);
   directI(shortIdx) = -1;
   directI(longIdx) = 1;
   resDirect(iDay, 2:end) = array2table(directI);
end

% 
% % ò�ƻ����б�Ҫ����ΪҲ�뿴���м�������ı��ְ�������������Ƿ������ֶ� �Ȳ��ù��ˣ��ڵ��������ӵ�ʱ�򿴹����ֶ���
% num = floor((size(resTrading, 2) - 1 ) / groupNum); % ÿ���м���Ʒ��
% 
% % ��resTrading��ÿһ�н���sort��ȡǰnum�����գ���num������
% % ��������ǿ���ֵ������2*num�������������ѡ��Ʒ�ָ���
% res = table2array(resTrading(:, 2:end));
% res = num2cell(res, 2);
% res = cellfun(@(o) labeldirect(o, num), res, 'UniformOutput', false);
% % res = cellfun(@(o) labelDirectRank(o, num), res, 'UniformOutput', false);
% res = [resTrading.Date cell2mat(res)]; % add Date and convert it to table
% res = array2table(res, 'VariableName', resTrading.Properties.VariableNames);
% % ����ط���rowfun�ܲ���ʵ�֣� �о�Ӧ���ǿ��Եģ���������һ�²��С���
% error msg: δ������ 'function_handle' ���͵�����������Ӧ�ĺ��� 'rowfun'��
% �о���2016B�汾��rowfun�е����⣬����Ҳ������������ʱ��arrayfun����cellfun���档
% 
% %% 12.28 ����MA����
% % ����MA
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
% labelMA = arrayfun(@(x, y, z) ifelse(x == 0, -1, x), labelMA); % ���ܼ���ô���� ��Ϊ0������С��MA Ҳ�����ǿ�ֵ
% labelNonNaN = ~isnan(table2array(adjClose(:, 2:end)));
% labelMA = [adjClose.Date, labelMA .* labelNonNaN]; % labelMA��1��ʾAdjClose>MA20��-1��ʾС�ڣ�0��ʾAdjClose��NaN
% 
% %% ����MAɸѡ��Ľ��
% 
% % ����ѡ�� 
% [~, idx, ~] = intersect(labelMA(:, 1), res.Date);
% labelMA = labelMA(idx, :);
% 
% % �ԱȽ��
% tmp = [res.Date, table2array(res(:, 2:end)) == labelMA(:, 2:end)];
% tmp = [res.Date, tmp(:, 2:end) .* table2array(res(:, 2:end))]; 
% 
% res = array2table(tmp, 'VariableNames', res.Properties.VariableNames);

end


