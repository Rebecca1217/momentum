function BacktestAnalysis = CTAAnalysis_GeneralPlatform_2(BacktestResult)
% ======================CTA通用回测平台-绩效评价==============================
% -------------------------输入------------------------------
% BacktestResult:回测结果，累计收益、风险敞口、各期持仓
% -------------------------输出------------------------------
% BacktestAnalysis:对回测结果的分析
% 20180710修正：
% 1.日胜率改成有仓位情况下的日胜率(有小的偏差，因为存在收益=0的交易日）
% 2.平均敞口改成有仓位下的平均敞口

nv = BacktestResult.nv; %金额

tt = {'累计收益';'年化收益';'年化波动';'日胜率';'盈亏比';'最大回撤';'回撤最长持续时间';'夏普比';'收益回撤比';'最大敞口';'平均敞口';'回测开始日期';'回测结束日期'};

analysis = zeros(length(tt),1);
analysis(1) = nv(end,2); %累计收益
analysis(2) = mean(nv(:,3))*244; %年化收益
analysis(3) = std(nv(:,3))*sqrt(244); %年化波动
analysis(4) = sum(nv(:,3)>0)/sum(nv(:,3)~=0); %有仓位的情况下的日胜率
analysis(5) = mean(nv(nv(:,3)>0,3))/-mean(nv(nv(:,3)<0,3)); %盈亏比
dd = nv(:,2)-cummax(nv(:,2)); 
% dd由0变负，开始回撤；dd由负变0，结束回撤
sgn = sign(dd);
noDDLocs = find(sgn==0); %没有回撤的时间点所在行
analysis(6) = -min(dd); %最大回撤
analysis(7) = max(diff(noDDLocs)); %回撤最长持续时长
analysis(8) = analysis(2)/analysis(3); %sr
analysis(9) = analysis(2)/-min(dd); %calmar
if ismember('riskExposure',fieldnames(BacktestResult))
    riskExposure = BacktestResult.riskExposure;
    analysis(10) = max(riskExposure(:,2));
    analysis(11) = mean(riskExposure(riskExposure(:,2)~=0,2));
end
analysis(12) = nv(1,1);
analysis(13) = nv(end,1);

BacktestAnalysis = [tt,num2cell(analysis)];





