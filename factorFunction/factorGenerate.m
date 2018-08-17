function res = factorGenerate(factorPara)
% factor generate for momentum

% get price data
dataPara.path = factorPara.dataPath;
dataPara.dateFrom = factorPara.dateFrom;
dataPara.dateTo = factorPara.dateTo;
dataPara.priceType = factorPara.priceType;

priceData = getpricedata(dataPara);

% ����factorPara.win�õ���λһ��ʱ�䴰�ڵļ۸������������������
forwardPrice = priceData((factorPara.win + 1) : end, :);
resDate = forwardPrice.Date;
resFactor = table2array(forwardPrice(:, 2:end)) ./ ...
    table2array(priceData(1:(size(priceData, 1) - factorPara.win), 2:end));
res = [resDate, resFactor];
res = array2table(res, 'VariableNames', priceData.Properties.VariableNames);
end

