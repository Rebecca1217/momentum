cd 'E:\Repository\momentum';
addpath getdata factorFunction getholding newSystem3.0 newSystem3.0\gen_for_BT2 public

%% 读数据
% getBasicData得到一个面板table，包含日期，各品种主力合约每日的复权价格

% global usualPath

usualPath = '\\Cj-lmxue-dt\期货数据2.0\usualData';
dataPath = '\\Cj-lmxue-dt\期货数据2.0\dlyData';

factorDataPath = 'E:\Repository\momentum\factorData\';

%% 计算因子
% 动量因子
% 可变参数包括：动量时间窗口，调仓间隔（持仓日期）
factorPara.dataPath = [dataPath, '\主力合约-比例后复权'];
factorPara.dateFrom = 20100101; % 整理的数据从这时候开始
% factorPara.dateFrom = 20100101; % 华泰期货回测起始时间
factorPara.dateTo = 20170831; % 推出夜盘交易前
factorPara.priceType = 'Close';

window = [5:5:50 22 60 120 250]; % 计算动量的时间窗口

tradingPara.holdingTime = 10; % 调仓间隔（持仓日期）
tradingPara.passway = tradingPara.holdingTime;
tradingPara.groupNum = 10; % 对冲比例10%，20%对应5组
tradingPara.capital = 10000000;
% tradePara.futUnitPath = '\\Cj-lmxue-dt\期货数据2.0\usualData\minTickInfo.mat'; %期货最小变动单位
tradingPara.futMainContPath = '\\Cj-lmxue-dt\期货数据2.0\商品期货主力合约代码';
tradingPara.futDataPath = '\\Cj-lmxue-dt\期货数据2.0\dlyData\主力合约'; %期货主力合约数据路径
tradingPara.futUnitPath = '\\Cj-lmxue-dt\期货数据2.0\usualData\minTickInfo.mat'; %期货最小变动单位
tradingPara.futMultiPath = '\\Cj-lmxue-dt\期货数据2.0\usualData\PunitInfo'; %期货合约乘数
tradingPara.PType = 'open'; %交易价格，一般用open（开盘价）或者avg(日均价）
tradingPara.fixC = 0.0005; %固定成本
tradingPara.slip = 2; %滑点

%
% @2018.12.24 计算factorData的时候就把国债期货和股指期货剔除
% 
% % 计算每个时间窗口的因子数据
% for iWin = 1:length(window)
%     factorPara.win = window(iWin);
%     factorData = factorGenerate(factorPara); % factorData比priceData少最开始的win天数据，所以行数不一样
%     % 因子数据是以table保存全部信息更好，还是拆开保存截面数据更好？想想有没有优化空间
%     % 因子数据是保存所有品种好还是只保存流动性品种好？感觉先保存所有，等计算持仓要操作的时候再剔除流动性比较好
%     % 因为以table形式保存的话，希望因子以整齐的方式保存下来，所以先暂存所有品种
%     factorSavePath = [factorDataPath, 'momFactorData'];
%     save([factorSavePath, '\window', num2str(factorPara.win), '.mat'], 'factorData')
% end
% 
% clear factorData %清出内存空间，需要的时候从本地读取因子数据

% 到目前为止保存的因子是全部54个品种的数据，等算持仓的时候再剔除非流动性

%% 用因子排序得到多空组合，包括持仓方向，手数
% 这中间先得到调仓日多空方向，补齐非调仓日的方向，然后再把主力合约填补进去

% 持仓期暂定40个交易日，分为5组

% 这个liquidityInfo跑起来比较慢，想一下能不能改进？
% 如果不能改进的话可不可以存在一个地方，定期更新，每次用的时候去读
% 本地保存liquidityData的时候是一个包含Date及列名的table
% 和因子数据点乘的时候用的是不含Date和列名的matrix

factorName = 'momFactorData';
for iWin = 1:length(window) % 每个时间窗口
    load([factorDataPath, factorName, '\window', num2str(window(iWin)), '.mat']);
    factorData = factorData(factorData.Date >= factorPara.dateFrom & ...
        factorData.Date <= factorPara.dateTo, :);
    
    %     每次循环的liquidityInfo时间不一样，与factorData的时间保持一致
    load('E:\futureData\liquidityInfo.mat')
    liquidityInfo = liquidityInfo(...
        liquidityInfo.Date >= min(factorData.Date) &...
        liquidityInfo.Date <= max(factorData.Date), :);
    
    % @2018.12.24 liquidityInfo也要剔除股指和国债期货
    liquidityInfo = delStockBondIdx(liquidityInfo);
    
    liquidityInfo = table2array(liquidityInfo(:, 2:end));
    totalRes = num2cell(nan(13, tradingPara.passway + 1));
   
    for jPassway = 1 : tradingPara.passway % 每条通道  比较不同通道下的结果
        win = window(iWin);
        passway = jPassway;
        posTradingDirect = getholding(win, passway); %得到iWin和jPassway下的换仓日序列持仓方向
        % 这个地方有个潜在是问题：持仓矩阵里面的0包含了缺失数据NaN和处于中间位置不多不空两种情况
        % 现在因为不管是哪种情况，不持仓它们先不用管，后期如果需要的话再加以区分（暂时想不到什么情况是需要区分的？）
        
        % 写一个向下补全的函数，输入换仓日的持仓和目标日期序列，第一个换仓日之前的不管，下面的补齐
        %         posFullDirect = getfullholding(posTradingDirect, factorData.Date);
        % 因为后面的算法，逻辑是从因子数据的第一天开始换手，所以完整的持仓日期就是因子数据的日期
        % @2018.12.21更新了MATLAB以后可以用fillmissing了
        
        posFullDirect = factorData(:, 1);
        posFullDirect = outerjoin(posFullDirect, posTradingDirect, 'type', 'left', 'MergeKeys', true);
        posFullDirect = varfun(@(x) fillmissing(x, 'previous'), posFullDirect);
        posFullDirect.Properties.VariableNames = posTradingDirect.Properties.VariableNames;
        
        % posFullDirect全为NaN剔除
        %         tst = rowfun(@(x) ~all(isnan(x)), posFullDirect(:, 2:end)); % 这个不行
        % 因为rowfun不是把table的每一行作为一个vector一下子输入函数，而是每行的每个元素一个一个输进去，
        % 所以这么操作会一直提示输入的参数过多，相当于你在输入isnan(1,2,3,4)而不是isnan([1 2 3 4])
        % 函数定义只有一个参数x，而你输入了2:end个参数
        % 而varfun确是每列作为一个vector一次性输入的！坑
        %         tst = arrayfun(@(x) ~all(isnan(table2array(posFullDirect(x,
        %         2:end)))), 1 : size(posFullDirect)); % 这个可以但太慢
        nonNaN = sum(~isnan(table2array(posFullDirect(:, 2:end))), 2);
        nonNaN = nonNaN ~= 0;
        posFullDirect = posFullDirect(nonNaN, :); % 这样操作虽然代码繁琐一点，但速度快，不需要用arrayfun这种本质循环的东西
        % 下面补全持仓手数和主力合约名称
        % 持仓手数和主力合约名称以两个表的形式保存吗？
        % 持仓手数 = (投入本金/持仓品种数)/(合约乘数/ * 价格) 平均分配本金
        % 手数经过最小变动单位向下调整
        
        posHands = getholdinghands(posTradingDirect, posFullDirect, tradingPara.capital);
        
        targetPortfolio = getMainContName(posHands);
        
        % targetPortfolio需要做一个调整：
        % 从始至终从来没有被选中过的品种要踢掉。。（不然回测时是一个一个品种测的，测到这个品种没法弄。。）
        % 不要改回测平台，调整自己输入的targetPortfolio符合回测平台的要求（因为平台不是自己写的，为了保持一致）
        
        [BacktestResult,err] = CTABacktest_GeneralPlatform_3(targetPortfolio,tradingPara);
        %         figure
        %         % 净值曲线
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
   
% 修改getMainContName函数后，循环通道速度从1条通道38秒提升到10条通道只需要23秒
end



result = nan(size(targetPortfolio, 1), 1);
for i = 1 : size(targetPortfolio, 1)
    result(i) = isequal(targetPortfolio{i, 1}, targetPortfolio1{i, 1});
end









