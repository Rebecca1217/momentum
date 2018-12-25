function tdList = calRtnByRealData2(sigLi,tradeData,HoldingHandsFut,Cost)
% sig是经过止盈止损调整后的信号
% 用真实交易合约的数据计算
% 换月的时候统一用开盘价进行换月
% 不考虑止盈止损的情况
% 20180710:
% 1.换月时考虑上平旧合约的手续费
% 2.不考虑止盈止损的情况，这个在生成targetportfolio的时候考虑，改变targetportfolio
% 3.改变计算每日收益的方式

% 真实合约数据
tdDate = tradeData.tdDate;
tdData = tradeData.tdData;
tdAdj = tradeData.tdAdj; %换月的时候旧合约的开盘价数据
ttData = tradeData.ttData; %主力合约的价格数据，ochls

% 交易成本
fixC = Cost.fix;
slip = Cost.float;
unit = Cost.unit;
%
HoldingHandsFut = HoldingHandsFut(:,2);

%----------------------------------------------------------------------%
% 回测规则
% 先平仓，后开仓
% 每日用结算价结算
tdList = zeros(length(tdDate),5); %方向(如果当日持仓，则当日有标记），开仓操作，平仓操作，持仓手数，当日盈亏
if isempty(sigLi) %没有交易信号
    return;
end
num = sum(sigLi(:,3)<length(tdDate));
if num~=0 %num=0的情况：只有一个信号，且该信号到截止时间还未结束或者该信号在最后一行发出
    for i = 1:num %逐个信号计算
        opL = sigLi(i,2); %开仓信号所在行
        clL = sigLi(i,3); %平仓信号所在行,opL后面第一个sig=0的行
        sgn = sigLi(i,1); %开仓方向
        HandsI = HoldingHandsFut(opL+1:clL); %每日应开仓手数
        tdDataI = tdData(opL+1:clL+1); %交易价格
        tdAdjI = tdAdj(opL+1:clL+1); %换月情况
        ttDataI = ttData(opL+1:clL+1,:); %主力合约数据
        if clL-opL>1 %不是当根开，下根平的情况
            tdList(opL+1:clL,1) = sgn; %记录开仓方向，如果当日持有，则当日标记为相应的开仓方向
            tdList(opL+1,2) = 2-sgn; %多空开，以当天的开盘价开仓
            tdList(clL,3) = 3-sgn; %多空平，以后一天的开盘价平仓
            tdList(opL+1:clL,4) = HandsI; %每日持仓手数
            %
            opP = (tdDataI(1)+sgn*slip*unit)*(1+sgn*fixC); %开仓价
            HandsAdd = [0;diff(HandsI)]; %持仓手数的改变
            tdList(opL+1,5) = sgn*(ttDataI(1,5)-opP)*tdList(opL+1,4); %开仓日
            setP = ttDataI(1,5); %结算价
            for d = 2:clL-opL %逐天计算盈亏
                if tdAdjI(d)~=0 %当日换月，把旧合约全部平掉，然后在新合约上开对应的手数
                    % 平旧合约
                    clOld = sgn*((tdAdjI(d)-sgn*slip*unit)*(1-sgn*fixC)-setP)*tdList(opL+d-1,4);
                    % 开新合约
                    opNew = sgn*(ttDataI(d,5)-(tdDataI(d)+sgn*slip*unit)*(1+sgn*fixC))*tdList(opL+d,4);
                    pftDly = clOld+opNew;
                else %当日非换月
                    if HandsAdd(d)==0 %如果持仓手数没有变
                        pftDly = sgn*(ttDataI(d,5)-setP)*tdList(opL+d-1,4);
                    elseif HandsAdd(d)>0 %手数增加
                        pftDly = sgn*(ttDataI(d,5)-setP)*tdList(opL+d-1,4)+sgn*(ttDataI(d,5)-(tdDataI(d)+sgn*slip*unit)*(1+sgn*fixC))*HandsAdd(d);
                    elseif HandsAdd(d)<0 %手数减少
                        pftDly = sgn*(ttDataI(d,5)-setP)*tdList(opL+d,4)+sgn*((tdDataI(d)-sgn*slip*unit)*(1-sgn*fixC)-setP)*abs(HandsAdd(d));
                    end
                end
                tdList(opL+d,5) = pftDly; %当日盈亏
                setP = ttDataI(d,5);
            end
            % 平仓盈亏
            % 平仓价
            if tdAdjI(end)~=0 %平仓日刚好是换月日,则用旧主力合约的开盘价平，否则就是正常的平仓价平
                clP = (tdAdjI(end)-sgn*slip*unit)*(1-sgn*fixC);
            else
                clP = (tdDataI(end)-sgn*slip*unit)*(1-sgn*fixC); %合约交易价平              
            end
            tdList(clL,5) = tdList(clL,5)+sgn*(clP-setP)*tdList(clL,4); %最后一天记录了当天的收益和用下一天开盘价平仓产生的平仓收益
        elseif clL-opL==1 %当天开，次天平，持仓只有一天
            tdList(opL+1,1) = sgn;
            tdList(opL+1,2) = 2-sgn;
            tdList(opL+1,3) = 5.5-0.5*sgn;
            tdList(opL+1,4) = HandsI; %持仓手数
            %
            opP = (tdDataI(1)+sgn*slip*unit)*(1+sgn*fixC); %开仓价
            if tdAdjI(end)~=0 %平仓日刚好是换月日,则用旧主力合约的开盘价平，否则就是正常的平仓价平
                clP = (tdAdjI(end)-sgn*slip*unit)*(1-sgn*fixC);
            else
                clP = (tdDataI(end)-sgn*slip*unit)*(1-sgn*fixC); %合约交易价平
            end
            tdList(opL+1,5) = sgn*(clP-opP)*tdList(opL+1,4); %收益
        end
    end
end

% 还未处理的信号有两种情况：
% 1.在数据结尾发出了平仓信号：sigLi的第三列=length(tdDate)
% 2.截止到数据结尾还没有发出平仓信号：sigLi的第三列=nan & sigLi的第二列~=length(tdDate)
% 3.数据的最后一天发出了开仓信号：sigLi的第三列=nan & sigLi的第二列=length(tdDate)
%
% 先确认一下有没有第三种情况发生，如果有，可以直接删掉该信号
sigLi(sigLi(:,2)==length(tdDate) & isnan(sigLi(:,3)),:) = [];
% 第一二种情况的处理方式相同，都是没有平仓
Locs = find(sigLi(:,3)==length(tdDate) | (isnan(sigLi(:,3)) & sigLi(:,2)~=length(tdDate)));
if ~isempty(Locs)
    opL = sigLi(Locs,2); %开仓信号所在行
    clL = length(tdDate); %虚拟的平仓信号所在行
    sgn = sigLi(Locs,1); %开仓方向
    HandsI = HoldingHandsFut(opL+1:clL); %每日应开仓手数
    tdDataI = tdData(opL+1:clL); 
    tdAdjI = tdAdj(opL+1:clL); %换月情况
    ttDataI = ttData(opL+1:clL,:); %主力合约数据
    if clL-opL>1 %不是当根开，下根平的情况
        tdList(opL+1:clL,1) = sgn; %记录开仓方向，如果当日持有，则当日标记为相应的开仓方向
        tdList(opL+1,2) = 2-sgn; %多空开，以当天的开盘价开仓
        tdList(opL+1:clL,4) = HandsI; %每日持仓手数
        %
        opP = (tdDataI(1)+sgn*slip*unit)*(1+sgn*fixC); %开仓价
        HandsAdd = [0;diff(HandsI)]; %持仓手数的改变
        tdList(opL+1,5) = sgn*(ttDataI(1,5)-opP)*tdList(opL+1,4); %开仓日
        setP = ttDataI(1,5); %结算价
        for d = 2:clL-opL %逐天计算盈亏
            if tdAdjI(d)~=0 %当日换月，把旧合约全部平掉，然后在新合约上开对应的手数
                % 平旧合约
                clOld = sgn*((tdAdjI(d)-sgn*slip*unit)*(1-sgn*fixC)-setP)*tdList(opL+d-1,4);
                % 开新合约
                opNew = sgn*(ttDataI(d,5)-(tdDataI(d)+sgn*slip*unit)*(1+sgn*fixC))*tdList(opL+d,4);
                pftDly = clOld+opNew;
            else %当日非换月
                if HandsAdd(d)==0 %如果持仓手数没有变
                    pftDly = sgn*(ttDataI(d,5)-setP)*tdList(opL+d-1,4);
                elseif HandsAdd(d)>0 %手数增加
                    pftDly = sgn*(ttDataI(d,5)-setP)*tdList(opL+d-1,4)+sgn*(ttDataI(d,5)-(tdDataI(d)+sgn*slip*unit)*(1+sgn*fixC))*HandsAdd(d);
                elseif HandsAdd(d)<0 %手数减少
                    pftDly = sgn*(ttDataI(d,5)-setP)*tdList(opL+d,4)+sgn*((tdDataI(d)-sgn*slip*unit)*(1-sgn*fixC)-setP)*abs(HandsAdd(d));
                end
            end
            tdList(opL+d,5) = pftDly; %当日盈亏
            setP = ttDataI(d,5);
        end
    elseif clL-opL==1 %当天开，次天平，持仓只有一天,但是没有平仓的数据
        tdList(opL+1,1) = sgn;
        tdList(opL+1,2) = 2-sgn;
        tdList(opL+1,4) = HandsI; %持仓手数
        %
        opP = (tdDataI(1)+sgn*slip*unit)*(1+sgn*fixC); %开仓价
        tdList(opL+1,5) = sgn*(ttDataI(end,5)-opP)*tdList(opL+1,4); %收益
    end
end

% 乘以合约乘数
tdList(:,5) = tdList(:,5)*Cost.multi;


   



