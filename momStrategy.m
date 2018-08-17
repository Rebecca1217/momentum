cd 'E:\Repository\momentum';
addpath getdata factorFunction getholding

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
factorPara.dateFrom = '20100101';
factorPara.dateTo = '20170731';
factorPara.priceType = 'Close';

window = 5:5:50;

tradingPara.holdingTime = 40;
tradingPara.passway = tradingPara.holdingTime;
tradingPara.groupNum = 5;

% ����ÿ��ʱ�䴰�ڵ���������
for iWin = 1:length(window)
    factorPara.win = window(iWin);
    factorData = factorGenerate(factorPara); % ����洢���ݵ�ʱ���õ��ˣ����������ʾ����
    % ������������table����ȫ����Ϣ���ã����ǲ𿪱���������ݸ��ã�������û���Ż��ռ�
    % ���������Ǳ�������Ʒ�ֺû���ֻ����������Ʒ�ֺã��о��ȱ������У��ȼ���ֲ�Ҫ������ʱ������������ԱȽϺ�
    % ��Ϊ��table��ʽ����Ļ���ϣ������������ķ�ʽ�����������������ݴ�����Ʒ��
    factorSavePath = [factorDataPath, 'momFactorData'];
    save([factorSavePath, '\window', num2str(factorPara.win), '.mat'], 'factorData')
end

clear facorData iWin%����ڴ�ռ䣬��Ҫ��ʱ��ӱ��ض�ȡ��������

% ��ĿǰΪֹ�����������ȫ��54��Ʒ�ֵ����ݣ�����ֲֵ�ʱ���������������

%% ����������õ������ϣ������ֲַ�������
% ���м��ȵõ������ն�շ��򣬲���ǵ����յķ���Ȼ���ٰ�������Լ���ȥ

% �ֲ����ݶ�40�������գ���Ϊ5��

% ���liquidityInfo�������Ƚ�������һ���ܲ��ܸĽ���
% ������ܸĽ��Ļ��ɲ����Դ���һ���ط������ڸ��£�ÿ���õ�ʱ��ȥ��
liquidityInfo = getliquidinfo(factorPara.dateFrom, factorPara.dateTo);
 
factorName = 'momFactorData';
for iWin = 1:length(window) % ÿ��ʱ�䴰��
    load([factorDataPath, factorName, '\window', num2str(window(iWin)), '.mat']);
    for jPassway = 1:tradingPara.passway % ÿ��ͨ��  ����10 * 40 �ֲֳ�
    win = window(iWin);
    passway = jPassway;
    posTradingDirect = getholding(win, passway); %�õ�iWin��jPassway�µĻ��������гֲַ���
    % ����ط��и�Ǳ�������⣺�ֲ־��������0������ȱʧ����NaN�ʹ����м�λ�ò��಻���������
    % ������Ϊ������������������ֲ������Ȳ��ùܣ����������Ҫ�Ļ��ټ������֣���ʱ�벻��ʲô�������Ҫ���ֵģ���

    % дһ�����²�ȫ�ĺ��������뻻���յĳֲֺ�Ŀ���������У���һ��������֮ǰ�Ĳ��ܣ�����Ĳ���
    posFullDirect = getfullholding(posTradingDirect, factorData.Date);
    % ��Ϊ������㷨���߼��Ǵ��������ݵĵ�һ�쿪ʼ���֣����������ĳֲ����ھ����������ݵ�����
    
    
    
    %���油ȫ�ֲ�������������Լ����
    % �ֲ�������������Լ���������������ʽ������
    
    
    
    
    
    end
end

    









%% �ز�














