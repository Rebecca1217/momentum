cd 'E:\Repository\momentum';
addpath getdata factorFunction getholding

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
factorPara.dateFrom = '20100101';
factorPara.dateTo = '20170731';
factorPara.priceType = 'Close';

window = 5:5:50;

tradingPara.holdingTime = 40;
tradingPara.passway = tradingPara.holdingTime;
tradingPara.groupNum = 5;

% 计算每个时间窗口的因子数据
for iWin = 1:length(window)
    factorPara.win = window(iWin);
    factorData = factorGenerate(factorPara); % 后面存储数据的时候用到了，忽略这个提示即可
    % 因子数据是以table保存全部信息更好，还是拆开保存截面数据更好？想想有没有优化空间
    % 因子数据是保存所有品种好还是只保存流动性品种好？感觉先保存所有，等计算持仓要操作的时候再提出流动性比较好
    % 因为以table形式保存的话，希望因子以整齐的方式保存下来，所以先暂存所有品种
    factorSavePath = [factorDataPath, 'momFactorData'];
    save([factorSavePath, '\window', num2str(factorPara.win), '.mat'], 'factorData')
end

clear facorData iWin%清出内存空间，需要的时候从本地读取因子数据

% 到目前为止保存的因子是全部54个品种的数据，等算持仓的时候再提出非流动性

%% 用因子排序得到多空组合，包括持仓方向，手数
% 这中间先得到调仓日多空方向，补齐非调仓日的方向，然后再把主力合约填补进去

% 持仓期暂定40个交易日，分为5组

% 这个liquidityInfo跑起来比较慢，想一下能不能改进？
% 如果不能改进的话可不可以存在一个地方，定期更新，每次用的时候去读
liquidityInfo = getliquidinfo(factorPara.dateFrom, factorPara.dateTo);
 
factorName = 'momFactorData';
for iWin = 1:length(window) % 每个时间窗口
    load([factorDataPath, factorName, '\window', num2str(window(iWin)), '.mat']);
    for jPassway = 1:tradingPara.passway % 每条通道  计算10 * 40 种持仓
    win = window(iWin);
    passway = jPassway;
    posTradingDirect = getholding(win, passway); %得到iWin和jPassway下的换仓日序列持仓方向
    % 这个地方有个潜在是问题：持仓矩阵里面的0包含了缺失数据NaN和处于中间位置不多不空两种情况
    % 现在因为不管是哪种情况，不持仓它们先不用管，后期如果需要的话再加以区分（暂时想不到什么情况是需要区分的？）

    % 写一个向下补全的函数，输入换仓日的持仓和目标日期序列，第一个换仓日之前的不管，下面的补齐
    posFullDirect = getfullholding(posTradingDirect, factorData.Date);
    % 因为后面的算法，逻辑是从因子数据的第一天开始换手，所以完整的持仓日期就是因子数据的日期
    
    
    
    %下面补全持仓手数和主力合约名称
    % 持仓手数和主力合约名称以两个表的形式保存吗？
    
    
    
    
    
    end
end

    









%% 回测














