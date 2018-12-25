function tdList = calRtnByRealData(sigLi,tradeData,HoldingHandsFut,Cost)
% sig是经过止盈止损调整后的信号
% 用真实交易合约的数据计算

% 真实合约数据
tdDate = tradeData.tdDate;
tdData = tradeData.tdData;
tdAdj = tradeData.tdAdj; %换月的时候旧合约的开盘价数据
ttData = tradeData.ttData; %主力合约的价格数据
% 交易成本
fixC = Cost.fix;
slip = Cost.float;
unit = Cost.unit;
% 持仓手数的时间对齐
hdDate = HoldingHandsFut(:,1);
stL = find(hdDate==tdDate(1),1);
edL = find(hdDate==tdDate(end),1);
HoldingHandsFut = HoldingHandsFut(stL:edL,2);

%----------------------------------------------------------------------%
% 回测规则
% 先平仓，后开仓
% 每日用结算价结算
tdList = zeros(length(tdDate),6); %方向，开仓操作，平仓操作，持仓手数，当日盈亏，是否止盈止损
if isempty(sigLi) %没有交易信号
    return;
end
if sigLi(end,3)==length(tdDate) || isnan(sigLi(end,3)) %平仓信号在最后一行或者到截止时间还未平仓
    num = size(sigLi,1)-1;
else
    num = size(sigLi,1);
end
for i = 1:num %逐个信号计算
    opL = sigLi(i,2); %开仓信号所在行
    clL = sigLi(i,3); %平仓信号所在行
    sgn = sigLi(i,1); %开仓方向
    ifCut = sigLi(i,4); %是否止盈止损的方式平仓
    HandsI = HoldingHandsFut(opL+1:clL); %每日应开仓手数
    tdDataI = tdData(opL+1:clL+1); %交易价格
    tdAdjI = tdAdj(opL+1:clL+1); %换月情况
    ttDataI = ttData(opL+1:clL+1,:); %主力合约数据
    if clL-opL>1 %不是当根开，下根平的情况
        tdList(opL+1:clL-1,1) = sgn; %记录开仓方向
        tdList(opL+1,2) = 2-sgn; %多空开
        tdList(clL,3) = 3-sgn; %多空平
        tdList(opL+1:clL,4) = HandsI; %每日持仓手数
        % 
        opP = (tdDataI(1)+sgn*slip*unit)*(1+sgn*fixC); %开仓价
        HandsAdd = [0;diff(HandsI)]; %持仓手数的改变
        tdList(opL+1,5) = sgn*(ttDataI(1,5)-opP)*tdList(opL+1,4); %开仓日
        setP = ttDataI(1,5); %结算价
        for d = 2:clL-opL %逐天计算盈亏-当日盈亏由3部分构成：历史持仓的盈亏+新增减持仓的盈亏+换月的盈亏
            HisPft = sgn*(ttDataI(d,5)-setP)*tdList(opL+d-1,4); %历史持仓的盈亏
            if tdAdjI(d)~=0%当日换月
                opN = (tdDataI(d)+sgn*slip*unit)*(1+sgn*fixC); %新合约上面开仓
                chgPft = sgn*(tdAdjI(d)-opN)*tdList(opL+d-1,4); %换月盈亏
            else
                chgPft = 0;
            end
            if HandsAdd(d)>0 %持仓手数增加-直接用主力合约的价格就可以
                opN = (tdDataI(d)+sgn*slip*unit)*(1+sgn*fixC); 
                addPft = sgn*(ttDataI(d,5)-opN)*HandsAdd(d);
            elseif HandsAdd(d)<0 %持仓手数减少
                if tdAdjI(d)~=0 %当日换月-在旧合约上面平仓,用旧合约的开盘价平
                    clN = tdAdjI(d);
                else
                    clN = tdDataI(d);
                end
                clN = (clN-sgn*slip*unit)*(1-sgn*fixC);
                addPft = sgn*(clN-setP)*HandsAdd(d);
            else
                addPft = 0;
            end        
            tdList(opL+d,5) = HisPft+chgPft+addPft; %当日盈亏
            setP = ttDataI(d,5); 
        end
        % 平仓盈亏
        % 平仓价
        if tdAdjI(end)~=0 %平仓日刚好是换月日,则用旧主力合约的开盘价平，否则就是正常的平仓价平
            clP = (tdAdjI(end)-sgn*slip*unit)*(1-sgn*fixC);
        else
            if ifCut==1 %止盈止损了
                clP = (ttDataI(end,1)-sgn*slip*unit)*(1-sgn*fixC); %合约开盘价平
            else
                clP = (tdDataI(end)-sgn*slip*unit)*(1-sgn*fixC); %合约交易价平
            end
        end
        tdList(clL,5) = tdList(clL,5)+sgn*(clP-setP)*tdList(clL,4);
        tdList(clL,6) = ifCut;
    elseif clL-opL==1 %当天开，次天平
        tdList(opL+1,1) = sgn;
        tdList(opL+1,2) = 2-sgn;
        tdList(opL+1,3) = 5.5-0.5*sgn;
        tdList(opL+1,4) = HandsI; %持仓手数
        %
        opP = (tdDataI(1)+sgn*slip*unit)*(1+sgn*fixC); %开仓价
        if tdAdjI(end)~=0 %平仓日刚好是换月日,则用旧主力合约的开盘价平，否则就是正常的平仓价平
            clP = (tdAdjI(end)-sgn*slip*unit)*(1-sgn*fixC);
        else
            if ifCut==1 %止盈止损了
                clP = (ttDataI(end,1)-sgn*slip*unit)*(1-sgn*fixC); %合约开盘价平
            else
                clP = (tdDataI(end)-sgn*slip*unit)*(1-sgn*fixC); %合约交易价平
            end
        end
        tdList(opL+1,5) = sgn*(clP-opP)*tdList(opL+1,4); %收益
        tdList(opL+1,6) = ifCut;
    end
end
% 最后一个信号-如果截止到数据结尾还没平仓，则这笔交易还没做完
if sigLi(end,3)==length(tdDate) || isnan(sigLi(end,3)) %nan:最后一个交易未完成；length(tddate)：刚好在最后平仓
    opL = sigLi(end,2); %开仓信号所在行
%     clL = sigLi(end,3); %平仓信号所在行
    clL = length(tdDate); %平仓信号所在行，不管是不是这时候平仓，都用这一天算
    sgn = sigLi(end,1); %开仓方向
    ifCut = sigLi(end,4); %是否止盈止损的方式平仓
    HandsI = HoldingHandsFut(opL+1:clL); %每日应开仓手数
    tdDataI = tdData(opL+1:clL); %交易价格
    tdAdjI = tdAdj(opL+1:clL); %换月情况
    ttDataI = ttData(opL+1:clL,:); %主力合约数据
    if clL-opL>1 %不是当根开，下根平的情况
        tdList(opL+1:clL-1,1) = sgn; %记录开仓方向
        tdList(opL+1,2) = 2-sgn; %多空开
        if ~isnan(sigLi(end,3))
            tdList(clL,3) = 3-sgn; %多空平
        else
            tdList(clL,1) = sgn;
        end
        tdList(opL+1:clL,4) = HandsI; %每日持仓手数
        %
        opP = (tdDataI(1)+sgn*slip*unit)*(1+sgn*fixC); %开仓价
        HandsAdd = [0;diff(HandsI)]; %持仓手数的改变
        tdList(opL+1,5) = sgn*(ttDataI(1,5)-opP)*tdList(opL+1,4); %开仓日
        setP = ttDataI(1,5); %结算价
        for d = 2:clL-opL %逐天计算盈亏-当日盈亏由3部分构成：历史持仓的盈亏+新增减持仓的盈亏+换月的盈亏
            HisPft = sgn*(ttDataI(d,5)-setP)*tdList(opL+d-1,4); %历史持仓的盈亏
            if tdAdjI(d)~=0%当日换月
                opN = (tdDataI(d)+sgn*slip*unit)*(1+sgn*fixC); %新合约上面开仓
                chgPft = sgn*(tdAdjI(d)-opN)*tdList(opL+d-1,4); %换月盈亏
            else
                chgPft = 0;
            end
            if HandsAdd(d)>0 %持仓手数增加-直接用主力合约的价格就可以
                opN = (tdDataI(d)+sgn*slip*unit)*(1+sgn*fixC);
                addPft = sgn*(ttDataI(d,5)-opN)*HandsAdd(d);
            elseif HandsAdd(d)<0 %持仓手数减少
                if tdAdjI(d)~=0 %当日换月-在旧合约上面平仓,用旧合约的开盘价平
                    clN = tdAdjI(d);
                else
                    clN = tdDataI(d);
                end
                clN = (clN-sgn*slip*unit)*(1-sgn*fixC);
                addPft = sgn*(clN-setP)*HandsAdd(d);
            else
                addPft = 0;
            end
            tdList(opL+d,5) = HisPft+chgPft+addPft; %当日盈亏
            setP = ttDataI(d,5);
        end
        tdList(clL,6) = ifCut;
    elseif clL-opL==1 %当天开，次天平
        tdList(opL+1,1) = sgn;
        tdList(opL+1,2) = 2-sgn;
        if ~isnan(sigLi(end,3))
            tdList(opL+1,3) = 5.5-0.5*sgn;
        end
        tdList(opL+1,4) = HandsI; %持仓手数
        %
        opP = (tdDataI(1)+sgn*slip*unit)*(1+sgn*fixC); %开仓价
        clP = ttDataI(end); %最后一个交易日的结算价
        tdList(opL+1,5) = sgn*(clP-opP)*tdList(opL+1,4); %收益
        tdList(opL+1,6) = ifCut;
    end
end
% 乘以合约乘数
tdList(:,5) = tdList(:,5)*Cost.multi;


   



