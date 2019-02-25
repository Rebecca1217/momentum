function res = getVolatility(win, pct, dateFrom, dateTo, type)
%GETVOLATILITY win�Ǽ��㲨���ʵ�ʱ�䴰�ڣ��Ͷ������Ӵ���һ�£�pct��ɸѡ�İٷ�λ�㣬�ӵ͵�������
% ����pct = 0.25��ʾ���޳������ʴӵ͵�������ǰ25%�ģ���ǩΪ0��

tradingDay = gettradingday(dateFrom, dateTo);

basicData = getBasicData('future');
basicData.ContName = cellfun(@char, basicData.ContName, 'UniformOutput', false);


if strcmp(type, 'ATR')
    basicData.ATRRatio = basicData.ATRABS ./ basicData.Close; % ��ΪATRֵ����Ҳ�����ٲ��ɱȵ�
    % ֱ�ӳ���û��Ȩ�����̼ۣ���ΪATR��������õ���۸���ͬ��Լǰһ��۸����ģ����Գ��Ե������̼۾Ϳ���
    
    %% ����ÿ��win���ڣ�win = 14���Ĳ�����
    % resMovStd = [res.Date, movstd(table2array(res(:, 2:end)), [win - 1, 0])];
    volData = table(basicData.Date, basicData.ContName, basicData.ATRRatio, ...
        'VariableNames', {'Date', 'ContName', 'Vol'});
    volData = unstack(volData, 'Vol', 'ContName');
    %% ����0�۸�2019.1.2
    varNames = volData.Properties.VariableNames;
    volData = array2table([volData.Date, table2array(varfun(@fill0Price, volData(:, 2:end)))], ...
        'VariableNames', varNames);
    
else
    % @2019.1.2�ñ�׼��Ļ���Ҫdaily return�ı�׼������Ǿ��Լ۸�ı�׼��
    basicData.AdjClose = basicData.Close .* basicData.AdjFactor;
    volData = table(basicData.Date, basicData.ContName, basicData.AdjClose, ...
        'VariableNames', {'Date', 'ContName', 'AdjClose'});
    volData = unstack(volData, 'AdjClose', 'ContName');
    % FUƷ���жμ۸���0
    % ���۸��������ϲ��룬���������ʲ�Ȼ�ᱨ��
    % ����0�۸�2019.1.2
    varNames = volData.Properties.VariableNames;
    volData = array2table([volData.Date, table2array(varfun(@fill0Price, volData(:, 2:end)))], ...
        'VariableNames', varNames);
    % �۸����ֵת��Ϊdaily return
    volData = array2table([volData.Date, ...
        [nan(1, size(volData, 2) - 1);...
        price2ret(table2array(volData(:, 2:end)), [], 'Periodic')]], ...
        'VariableNames', volData.Properties.VariableNames);
    movStd = array2table([volData.Date, ...
        movstd(table2array(volData(:, 2:end)), [win - 1, 0])], ...
        'VariableName', volData.Properties.VariableNames);
    volData = movStd;
    clear movStd
end

volData = delStockBondIdx(volData);  % ԭʼ���ݱ�����û��TS������ֻɾ����5��

%% ɸѡ��λ������ǩ
dailyPrctile = prctile(table2array(volData(:, 2:end)), pct * 100, 2);
if size(volData, 1) ~= size(dailyPrctile, 1)
    error('Please check the dimention of movstd and quantile!')
end
% middle = prctile(table2array(volData(:, 2:end)), 50, 2);
% dailyPrctile2 = prctile(table2array(volData(:, 2:end)), (1 - pct) * 100, 2);

%% �Ƚϻ��volatility��ǩ
res = [volData.Date, table2array(volData(:, 2:end)) > dailyPrctile];
res = array2table(res, 'VariableNames', volData.Properties.VariableNames);
res = outerjoin(tradingDay, res, 'type', 'left', 'mergekeys', true);

end

