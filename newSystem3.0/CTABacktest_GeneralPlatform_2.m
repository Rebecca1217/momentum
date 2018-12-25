function [BacktestResult,err] = CTABacktest_GeneralPlatform_2(TargetPortfolio,TradePara)
% ======================CTA通用回测平台2.0-20180329==============================
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
Cost.fix = TradePara.fixC;
Cost.float = TradePara.slip;
load(futUnitPath) %最小变动单位数据-minTickInfo
load([futMultiPath,'\',num2str(TargetPortfolio{end,2}),'.mat']) %合约乘数数据-导入最后一个交易日对应的合约乘数数据

% 计算调仓日的日期序列
tradaySeries = cell2mat(TargetPortfolio(:,2)); %目标持仓生成日，交易日
nextTraday = get_nextTraday(tradaySeries); %目标持仓对应的调仓日
if length(nextTraday)~=length(tradaySeries) %如果调仓日期的数目不等于组合生成日的数目，报错
    fprintf('日期序列有缺失，检查一下dateCalendar！！！\n')
    err = 1;
    return;
end

% 先将TargetPortfolio改成矩阵形式：两个矩阵，一个是信号，一个是持仓,日期和TargetPortfolio是对齐的
[signalMtrx,HoldingMtrx,fut_variety] = getSigMtrx(TargetPortfolio);

% 逐个品种测试
signalDate = signalMtrx(:,1);
rtnFut = zeros(size(signalMtrx));
rtnFut(:,1) = signalDate;
riskExposure = zeros(length(signalDate),3); %风险敞口序列，日期、不轧差的敞口、轧差的敞口
riskExposure(:,1) = signalDate;
for i_fut = 1:length(fut_variety)
    fut = fut_variety{i_fut};
    Cost.unit = minTickInfo{ismember(minTickInfo(:,1),fut),2};
    Cost.multi = infoData{ismember(infoData(:,1),fut),2};
    % 生成所需格式的数据
    % 交易数据
    load([futDataPath,'\',fut,'.mat'])
    tradeData = getTradeData(futureData,signalDate(1),signalDate(end),PType);
    % 信号数据
    sigData = getSigData(signalMtrx(:,[1,i_fut+1]),tradeData.tdDate);
    % 持仓手数数据
    HoldingHandsFut = HoldingMtrx(:,[1,i_fut+1]);
    HoldingHandsFut(HoldingHandsFut(:,2)==0,2) = nan;
    % 计算收益
    tdList = calRtnByRealData(sigData,tradeData,HoldingHandsFut,Cost);
    %
    [~,li0,li1] = intersect(signalDate,tradeData.tdDate);
    rtnFut(li0,i_fut+1) = tdList(li1,5);
    %
    riskExposure(li0,2) = riskExposure(li0,2)+tdList(li1,4).*tradeData.ttData(li1,2);
    riskExposure(li0,3) = riskExposure(li0,2)+tdList(li1,1).*tdList(li1,4).*tradeData.ttData(li1,2);
end

nv = [rtnFut(:,1),cumsum(sum(rtnFut(:,2:end),2)),sum(rtnFut(:,2:end),2)];
% 存储结果
BacktestResult.rtnFut = rtnFut;
BacktestResult.fut_variety = fut_variety;
BacktestResult.riskExposure = riskExposure;
    
    