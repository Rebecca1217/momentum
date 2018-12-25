function [TargetTraListDly,HisListDly] = get_TargetTraListDly(TargetPortfolio,nextTraday)
% 根据每日目标持仓生成每日实际的交易单
% 根据每日的目标持仓做轧差
% 当天要交易的单子对应的日期就是当天的日期
% TargetTraListDly中20180209要交易的单子标记的日期为20180209
% TargetTraListDly中的格式与TargetPortfolio中的格式相同
% TargetTraListDly第一列是交易清单（三列：品种代码、交易手数与方向、开仓or平仓），第二列是日期
% HisListDly记录历史持仓，20180209的历史持仓记录在20180209这一天

TargetTraListDly = cell(size(TargetPortfolio));
TargetTraListDly(:,2) = num2cell(nextTraday);
TargetTraListDly{1,1} = [TargetPortfolio{1,1},num2cell(ones(size(TargetPortfolio{1,1},1),1))];
HisListDly = cell(size(TargetPortfolio));
HisListDly(:,2) = num2cell(nextTraday);
HisListDly{1,1} = {}; %第一天没有历史持仓
if length(nextTraday)==1 %就一个交易日
    return;
end
% 将TargetPortfolio整理成目标格式：代码、月份、方向、手数
TargetPortfolioStd = get_stdFormat(TargetPortfolio(:,1));
% 计算轧差的结果-需要用到当日和前一日的目标持仓
for d = 2:length(nextTraday)
    realTM = TargetPortfolioStd{d,1}; %当日生成的目标单，是明天的目标持仓,20180208的目标单
    realTD = TargetPortfolioStd{d-1,1}; %前一日生成的目标单，是当日的目标持仓,20180207的目标单
    [tradeList,hisList] = genTDList_for_BT(realTD,realTM); %tradeList:与TargetPortfolio中的格式相同
    TargetTraListDly{d,1} = tradeList;
    HisListDly{d,1} = hisList;
end
end

function stdFormat = get_stdFormat(oriFormat)

stdFormat = cell(length(oriFormat),1);
for d = 1:length(oriFormat)
    tmp = oriFormat{d};
    code = regexp(tmp(:,1),'\D*(?=\d)','match');
    code = reshape([code{:}],size(code));
    cont = regexp(tmp(:,1),'(?<=\D)\d*','match');
    cont = reshape([cont{:}],size(cont));
    info = cell2mat(tmp(:,2));
    direct = sign(info);
    hands = abs(info);
    stdFormat{d} = [code,cont,num2cell(direct),num2cell(hands)];
end
end