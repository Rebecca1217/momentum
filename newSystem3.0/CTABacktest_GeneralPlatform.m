function [BacktestResult,err] = CTABacktest_GeneralPlatform(TargetPortfolio,TradePara)
% ======================CTA通用回测平台==============================
% -------------------------输入------------------------------
% TargetPortfolio:目标持仓，当个交易日记录的是后一个交易日的目标持仓
% TargetPortfolio:cell,第一列为组合;第二列为目标组合生成日，生成日为交易日，记录的是后一个交易日应该做到的持仓
% TargetPortfolio:第二列cell中的元素包括两列，第一列是品种代码(A0809),第二列是目标手数(带方向)
% TradePara:交易参数，数据路径、交易成本
% -------------------------输出------------------------------
% BacktestResult:回测结果，累计收益、风险敞口、各期持仓
err = 0;
% 交易参数确定
% 路径
futDataPath = TradePara.futDataPath; %期货数据路径
futUnitPath = TradePara.futUnitPath; %期货最小变动单位数据路径
futMultiPath = TradePara.futMultiPath; %期货合约乘数数据路径
% 交易
PType = TradePara.PType; %成交价格类型
fixC = TradePara.fixC; %固定成本
slip = TradePara.slip; %滑点


% 计算调仓日的日期序列
tradaySeries = cell2mat(TargetPortfolio(:,2)); %目标持仓生成日，交易日
nextTraday = get_nextTraday(tradaySeries); %目标持仓对应的调仓日
if length(nextTraday)~=length(tradaySeries) %如果调仓日期的数目不等于组合生成日的数目，报错
    fprintf('日期序列有缺失，检查一下dateCalendar！！！\n')
    err = 1;
    return;
end

% 计算每日实际的交易单子
% 当天要交易的单子对应的日期就是当天的日期
% TargetTraListDly中20180209要交易的单子标记的日期为20180209
% HisListDly中20180209记录的是20180209当天的历史持仓
% TargetPortfolio中20180209要达成的目标持仓标记的日期为20180208
[TargetTraListDly,HisListDly] = get_TargetTraListDly(TargetPortfolio,nextTraday); 
% TargetTraListDly与TargetPortfolio的日期错开一天

nv = zeros(length(nextTraday),3); %净值序列，日期、累计收益、单日收益
nv(:,1) = nextTraday;
riskExposure = zeros(length(nextTraday),3); %风险敞口序列，日期、不轧差的敞口、轧差的敞口
riskExposure(:,1) = nextTraday;
% 交易单子已经生成好了，开始逐日回测
load(futUnitPath) %导入合约最小变动单位
% 建仓
tradeDayI = nextTraday(1); %首个交易日
tradeList = TargetTraListDly{1,1}; %首个交易单
load([futDataPath,'\',num2str(tradeDayI),'.mat']) %截面价格数据
load([futMultiPath,'\',num2str(tradeDayI),'.mat']) %合约乘数
[tradePrice,setPrice] = get_tradePrice(futureDataCS,PType); %交易价格和结算价格
paraT.fixC = fixC;
paraT.slip = slip;
paraT.minTickInfo = minTickInfo;
paraT.MultiInfo = infoData;
[nv(1,3),riskExposure(1,2:3)] = get_TradeProfitDly(tradeList,tradePrice,setPrice,[],paraT);

% 每日盈亏=历史持仓盈亏+新的交易产生的盈亏
for d = 2:length(nextTraday) %
    tradeDayI = nextTraday(d); %比如20180102
    % 当日的交易单
    tradeList = TargetTraListDly{d,1}; %导入20180102对应的交易单，记录20180102应该完成的交易
    % 当日的历史持仓
    hisList = HisListDly{d,1}; %导入20180102对应的持仓单，记录20180102应该持有的历史持仓
    % 导入当日的数据
    load([futDataPath,'\',num2str(tradeDayI),'.mat']) %截面价格数据
    load([futMultiPath,'\',num2str(tradeDayI),'.mat']) %合约乘数
    setPriceBF = setPrice;
    [tradePrice,setPrice] = get_tradePrice(futureDataCS,PType);
    if isempty(tradeList) %如果当日无需交易
        tradeProfit = 0;
        tradeRE = [0,0];
    else
        paraT.MultiInfo = infoData;
        [tradeProfit,tradeRE] = get_TradeProfitDly(tradeList,tradePrice,setPrice,setPriceBF,paraT);
    end
    if isempty(hisList) %如果当日没有历史持仓
        holdProfit = 0;
        holdRE = [0,0];
    else
        [holdProfit,holdRE] = get_HoldProfitDly(hisList,setPrice,setPriceBF,paraT);
    end
    nv(d,3) = tradeProfit+holdProfit;
    riskExposure(d,2:3) = tradeRE+holdRE;
end

nv(:,2) = cumsum(nv(:,3));
BacktestResult.nv = nv; %金额
BacktestResult.riskExposure = riskExposure;
BacktestResult.TargetPortfolio = TargetPortfolio;



