
% �Ƚϲֵ����ݺͽ���������
load('E:\futureData\dataWarrant.mat')
codeName = getVarietyCode();
dataWarrant = outerjoin(dataWarrant, codeName, 'type', 'left', 'MergeKeys', true, 'LeftKeys', 'ContCode', 'RightKeys', 'ContCode');
dataWarrant.ContName = cellfun(@char, dataWarrant.ContName, 'UniformOutput', false);
dataWarrant = unstack(dataWarrant(:, {'Date', 'ContName', 'Warrant'}), 'Warrant', 'ContName');


basicData = getBasicData('future');
basicData.ContName = cellfun(@char, basicData.ContName, 'UniformOutput', false);
volume = unstack(basicData(:, {'Date', 'ContName', 'Volume'}), 'Volume', 'ContName');

ratio = array2table([dataWarrant.Date, table2array(dataWarrant(:, 2:end)) ./ table2array(volume(:, 2:end))], ...
    'VariableNames', dataWarrant.Properties.VariableNames);

% 2019.03.04
%% �������涯������
% ��һ���֣��г����ӣ�����Ʒָ����ͷ���ۼƾ�ֵ���У���ֵ�������ʶ���һ�飩
tradingDay = gettradingday(factorPara.dateFrom, factorPara.dateTo);
w = windmatlab();
[w_wsd_data,~,~,w_wsd_times,w_wsd_errorid,~]=w.wsd(...
    'CCFI.WI','close',num2str(factorPara.dateFrom),num2str(factorPara.dateTo),'Fill=Previous');
if w_wsd_errorid ~= 0
    error('Wind data error!')
end
market = tradingDay;
market.MarketPrice = w_wsd_data;
market.MarketCum = market.MarketPrice / market.MarketPrice(1);
save('C:\Users\fengruiling\Desktop\market.mat', 'market')
% �ڶ����֣����޽ṹ �������ۼƾ�ֵ����
spotStruc = totalBacktestResult.nv;
spotStruc(:, 2) = spotStruc(:, 2) / 100000000 + 1;
spotStruc(:, 3) = [];
spotStruc = array2table(spotStruc, 'VariableNames', {'Date', 'Cum'});
save('C:\Users\fengruiling\Desktop\spotStruc.mat', 'spotStruc')

% �������֣���ģ �����Ӳ����ۼƾ�ֵ����
basicData = getBasicData('future');
codeName = getVarietyCode();

% ����ֲ���ֵ = �ֲ��� * ��Լ���� * ��Լ��ֵ
basicData.Capital = basicData.OI .* basicData.MultiFactor .* basicData.Close;
basicData.ContName = cellfun(@char, basicData.ContName, 'UniformOutput', false);
capital = unstack(basicData(:, {'Date', 'Capital', 'ContName'}), 'Capital', 'ContName');
% capital = zscoreValid(capital); %
% �����ȱ���ԭʼֵ����singleFactorStrategy�����õ�ʱ���ٱ�׼��
capital = stack(capital, 2:width(capital), ...
    'NewDataVariableName', 'Capital', 'IndexVariableName', 'ContName');
capital.ContName = arrayfun(@char, capital.ContName, 'UniformOutput', false);
codeName.ContName = cellfun(@char, codeName.ContName, 'UniformOutput', false);
capital = outerjoin(capital, codeName, 'type', 'left', 'MergeKeys', true, ...
    'LeftKeys', 'ContName', 'RightKeys', 'ContName');



load('E:\Repository\factorTest\factorDataTT.mat')
factorDataTT = outerjoin(factorDataTT, capital(:, {'Date', 'ContCode', 'Capital'}), 'type', 'left', 'MergeKeys', true, ...
    'LeftKeys', {'date', 'code'}, 'RightKeys', {'Date', 'ContCode'});
factorDataTT.Properties.VariableNames{1} = 'date';
factorDataTT.Properties.VariableNames{3} = 'code';
save('E:\Repository\factorTest\factorDataTT.mat', 'factorDataTT')


% ȡһ��holding = 90��ĵ���ֵ���Ӹ�����ԣ�����ֵ������ûɶЧ����
capitalSize = totalBacktestResult.nv;
capitalSize(:, 2) = capitalSize(:, 2) / 100000000 + 1;
capitalSize(:, 3) = [];
capitalSize = array2table(capitalSize, 'VariableNames', {'Date', 'Cum'});
save('C:\Users\fengruiling\Desktop\capitalSize.mat', 'capitalSize')

%% �ֽ����ʶ���
load('C:\Users\fengruiling\Desktop\market.mat')
load('C:\Users\fengruiling\Desktop\spotStruc.mat')
load('C:\Users\fengruiling\Desktop\capitalSize.mat');
load('E:\Repository\factorTest\factorDataTT.mat');

% ÿ��Ʒ�ֵ��ܶ�������������3�����������лع�
regressX = [ones(size(market, 1), 1), market.MarketCum, spotStruc.Cum, capitalSize.Cum];

momData = factorDataTT(:, {'date', 'code', 'mom120'});
codeName = getVarietyCode();
codeName.ContName = cellfun(@char, codeName.ContName, 'UniformOutput', false);
momData = outerjoin(momData, codeName, 'type', 'left', 'MergeKeys', true, 'LeftKeys', 'code', 'RightKeys', 'ContCode');
% momData.ContName = cellfun(@char, momData.ContName, 'UniformOutput', false);
momData = unstack(momData(:, {'date', 'ContName', 'mom120'}), 'mom120', 'ContName');
momData = momData(momData.date >= factorPara.dateFrom & momData.date <= factorPara.dateTo, :);

idioMomData = nan(height(momData), width(momData));
idioMomData(:, 1) = momData.date;

for iCol = 1 : width(momData) - 1
    momY = table2array(momData(:, iCol + 1));
    [~, ~, rI, ~, stats] = regress(momY, regressX);
    idioMomData(:, iCol + 1) = rI;
end

idioMomData = array2table(idioMomData, 'VariableNames', momData.Properties.VariableNames);
idioMomData = stack(idioMomData, 2:width(idioMomData), ...
    'NewDataVariableName', 'IdioMom', 'IndexVariableName', 'ContName');
idioMomData.ContName = arrayfun(@char, idioMomData.ContName, 'UniformOutput', false);
idioMomData = outerjoin(idioMomData, codeName, 'type', 'left', 'MergeKeys', true, ...
    'LeftKeys', 'ContName', 'RightKeys', 'ContName');

factorDataTT = outerjoin(factorDataTT, idioMomData(:, {'date', 'ContCode', 'IdioMom'}), 'type', 'left', 'MergeKeys', true, ...
    'LeftKeys', {'date', 'code'}, 'RightKeys', {'date', 'ContCode'});
factorDataTT.Properties.VariableNames{3} = 'code';
save('E:\Repository\factorTest\factorDataTT.mat', 'factorDataTT');
