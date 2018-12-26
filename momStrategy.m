cd 'E:\Repository\momentum';
addpath getdata factorFunction getholding newSystem3.0 newSystem3.0\gen_for_BT2 public

%% ������
% getBasicData�õ�һ�����table���������ڣ���Ʒ��������Լÿ�յĸ�Ȩ�۸�

% global usualPath

usualPath = '\\Cj-lmxue-dt\�ڻ�����2.0\usualData';
dataPath = '\\Cj-lmxue-dt\�ڻ�����2.0\dlyData';

factorDataPath = 'E:\Repository\momentum\factorData\';

%% ��������
% ��������
% �ɱ��������������ʱ�䴰�ڣ����ּ�����ֲ����ڣ�
factorPara.dataPath = [dataPath, '\������Լ-������Ȩ'];
factorPara.dateFrom = 20100101; % ��������ݴ���ʱ��ʼ
% factorPara.dateFrom = 20100101; % ��̩�ڻ��ز���ʼʱ��
factorPara.dateTo = 20170831; % �Ƴ�ҹ�̽���ǰ
factorPara.priceType = 'Close';

window = [5:5:50 22 60 120 250]; % ���㶯����ʱ�䴰��

tradingPara.holdingTime = 10; % ���ּ�����ֲ����ڣ�
tradingPara.passway = tradingPara.holdingTime;
tradingPara.groupNum = 10; % �Գ����10%��20%��Ӧ5��
tradingPara.capital = 10000000;
% tradePara.futUnitPath = '\\Cj-lmxue-dt\�ڻ�����2.0\usualData\minTickInfo.mat'; %�ڻ���С�䶯��λ
tradingPara.futMainContPath = '\\Cj-lmxue-dt\�ڻ�����2.0\��Ʒ�ڻ�������Լ����';
tradingPara.futDataPath = '\\Cj-lmxue-dt\�ڻ�����2.0\dlyData\������Լ'; %�ڻ�������Լ����·��
tradingPara.futUnitPath = '\\Cj-lmxue-dt\�ڻ�����2.0\usualData\minTickInfo.mat'; %�ڻ���С�䶯��λ
tradingPara.futMultiPath = '\\Cj-lmxue-dt\�ڻ�����2.0\usualData\PunitInfo'; %�ڻ���Լ����
tradingPara.PType = 'open'; %���׼۸�һ����open�����̼ۣ�����avg(�վ��ۣ�
tradingPara.fixC = 0.0005; %�̶��ɱ�
tradingPara.slip = 2; %����

%
% @2018.12.24 ����factorData��ʱ��Ͱѹ�ծ�ڻ��͹�ָ�ڻ��޳�
% 
% % ����ÿ��ʱ�䴰�ڵ���������
% for iWin = 1:length(window)
%     factorPara.win = window(iWin);
%     factorData = factorGenerate(factorPara); % factorData��priceData���ʼ��win�����ݣ�����������һ��
%     % ������������table����ȫ����Ϣ���ã����ǲ𿪱���������ݸ��ã�������û���Ż��ռ�
%     % ���������Ǳ�������Ʒ�ֺû���ֻ����������Ʒ�ֺã��о��ȱ������У��ȼ���ֲ�Ҫ������ʱ�����޳������ԱȽϺ�
%     % ��Ϊ��table��ʽ����Ļ���ϣ������������ķ�ʽ�����������������ݴ�����Ʒ��
%     factorSavePath = [factorDataPath, 'momFactorData'];
%     save([factorSavePath, '\window', num2str(factorPara.win), '.mat'], 'factorData')
% end
% 
% clear factorData %����ڴ�ռ䣬��Ҫ��ʱ��ӱ��ض�ȡ��������

% ��ĿǰΪֹ�����������ȫ��54��Ʒ�ֵ����ݣ�����ֲֵ�ʱ�����޳���������

%% ����������õ������ϣ������ֲַ�������
% ���м��ȵõ������ն�շ��򣬲���ǵ����յķ���Ȼ���ٰ�������Լ���ȥ

% �ֲ����ݶ�40�������գ���Ϊ5��

% ���liquidityInfo�������Ƚ�������һ���ܲ��ܸĽ���
% ������ܸĽ��Ļ��ɲ����Դ���һ���ط������ڸ��£�ÿ���õ�ʱ��ȥ��
% ���ر���liquidityData��ʱ����һ������Date��������table
% ���������ݵ�˵�ʱ���õ��ǲ���Date��������matrix

factorName = 'momFactorData';
for iWin = 1:length(window) % ÿ��ʱ�䴰��
    load([factorDataPath, factorName, '\window', num2str(window(iWin)), '.mat']);
    factorData = factorData(factorData.Date >= factorPara.dateFrom & ...
        factorData.Date <= factorPara.dateTo, :);
    
    %     ÿ��ѭ����liquidityInfoʱ�䲻һ������factorData��ʱ�䱣��һ��
    load('E:\futureData\liquidityInfo.mat')
    liquidityInfo = liquidityInfo(...
        liquidityInfo.Date >= min(factorData.Date) &...
        liquidityInfo.Date <= max(factorData.Date), :);
    
    % @2018.12.24 liquidityInfoҲҪ�޳���ָ�͹�ծ�ڻ�
    liquidityInfo = delStockBondIdx(liquidityInfo);
    
    liquidityInfo = table2array(liquidityInfo(:, 2:end));
    totalRes = num2cell(nan(13, tradingPara.passway + 1));
   
    for jPassway = 1 : tradingPara.passway % ÿ��ͨ��  �Ƚϲ�ͬͨ���µĽ��
        win = window(iWin);
        passway = jPassway;
        posTradingDirect = getholding(win, passway); %�õ�iWin��jPassway�µĻ��������гֲַ���
        % ����ط��и�Ǳ�������⣺�ֲ־��������0������ȱʧ����NaN�ʹ����м�λ�ò��಻���������
        % ������Ϊ������������������ֲ������Ȳ��ùܣ����������Ҫ�Ļ��ټ������֣���ʱ�벻��ʲô�������Ҫ���ֵģ���
        
        % дһ�����²�ȫ�ĺ��������뻻���յĳֲֺ�Ŀ���������У���һ��������֮ǰ�Ĳ��ܣ�����Ĳ���
        %         posFullDirect = getfullholding(posTradingDirect, factorData.Date);
        % ��Ϊ������㷨���߼��Ǵ��������ݵĵ�һ�쿪ʼ���֣����������ĳֲ����ھ����������ݵ�����
        % @2018.12.21������MATLAB�Ժ������fillmissing��
        
        posFullDirect = factorData(:, 1);
        posFullDirect = outerjoin(posFullDirect, posTradingDirect, 'type', 'left', 'MergeKeys', true);
        posFullDirect = varfun(@(x) fillmissing(x, 'previous'), posFullDirect);
        posFullDirect.Properties.VariableNames = posTradingDirect.Properties.VariableNames;
        
        % posFullDirectȫΪNaN�޳�
        %         tst = rowfun(@(x) ~all(isnan(x)), posFullDirect(:, 2:end)); % �������
        % ��Ϊrowfun���ǰ�table��ÿһ����Ϊһ��vectorһ�������뺯��������ÿ�е�ÿ��Ԫ��һ��һ�����ȥ��
        % ������ô������һֱ��ʾ����Ĳ������࣬�൱����������isnan(1,2,3,4)������isnan([1 2 3 4])
        % ��������ֻ��һ������x������������2:end������
        % ��varfunȷ��ÿ����Ϊһ��vectorһ��������ģ���
        %         tst = arrayfun(@(x) ~all(isnan(table2array(posFullDirect(x,
        %         2:end)))), 1 : size(posFullDirect)); % ������Ե�̫��
        nonNaN = sum(~isnan(table2array(posFullDirect(:, 2:end))), 2);
        nonNaN = nonNaN ~= 0;
        posFullDirect = posFullDirect(nonNaN, :); % ����������Ȼ���뷱��һ�㣬���ٶȿ죬����Ҫ��arrayfun���ֱ���ѭ���Ķ���
        % ���油ȫ�ֲ�������������Լ����
        % �ֲ�������������Լ���������������ʽ������
        % �ֲ����� = (Ͷ�뱾��/�ֲ�Ʒ����)/(��Լ����/ * �۸�) ƽ�����䱾��
        % ����������С�䶯��λ���µ���
        
        posHands = getholdinghands(posTradingDirect, posFullDirect, tradingPara.capital);
        
        targetPortfolio = getMainContName(posHands);
        
        % targetPortfolio��Ҫ��һ��������
        % ��ʼ���մ���û�б�ѡ�й���Ʒ��Ҫ�ߵ���������Ȼ�ز�ʱ��һ��һ��Ʒ�ֲ�ģ��⵽���Ʒ��û��Ū������
        % ��Ҫ�Ļز�ƽ̨�������Լ������targetPortfolio���ϻز�ƽ̨��Ҫ����Ϊƽ̨�����Լ�д�ģ�Ϊ�˱���һ�£�
        
        [BacktestResult,err] = CTABacktest_GeneralPlatform_3(targetPortfolio,tradingPara);
        %         figure
        %         % ��ֵ����
        %         dn = datenum(num2str(BacktestResult.nv(:, 1)), 'yyyymmdd');
        %         plot(dn, (tradingPara.capital + BacktestResult.nv(:, 2)) ./ tradingPara.capital)
        %         datetick('x', 'yyyymmdd', 'keepticks', 'keeplimits')
        
        BacktestAnalysis = CTAAnalysis_GeneralPlatform_2(BacktestResult);
        if jPassway == 1
            totalRes(:, [1 2]) = BacktestAnalysis;
        else
            totalRes(:, jPassway + 1) = BacktestAnalysis(:, 2);
        end
        
    end
   
% �޸�getMainContName������ѭ��ͨ���ٶȴ�1��ͨ��38��������10��ͨ��ֻ��Ҫ23��
end



result = nan(size(targetPortfolio, 1), 1);
for i = 1 : size(targetPortfolio, 1)
    result(i) = isequal(targetPortfolio{i, 1}, targetPortfolio1{i, 1});
end









