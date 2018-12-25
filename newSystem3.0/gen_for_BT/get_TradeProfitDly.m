function [ProfitDly,sizeDly] = get_TradeProfitDly(tradeList,tradePrice,setPrice,setPriceBF,paraT)
% 持仓变化造成的盈亏
% 根据轧差之后的交易单计算
% 如果是开仓单，用今交易价和今结算价
% 如果是平仓单，用今交易价和昨结算价

fixC = paraT.fixC;
slip = paraT.slip;
minTickInfo = paraT.minTickInfo;
MultiInfo = paraT.MultiInfo;

tradeFut = regexp(tradeList(:,1),'\D*(?=\d)','match'); %当天交易的品种
tradeFut = reshape([tradeFut{:}],size(tradeFut));
[~,li0,li1] = intersect(tradeFut,minTickInfo(:,1));% 最小变动价位
tradeList(li0,4) = minTickInfo(li1,2);
[~,li0,li1] = intersect(tradeFut,MultiInfo(:,1)); %合约乘数
tradeList(li0,5) = MultiInfo(li1,2);
% [~,liA,liF] = unique(tradeList(:,1));% 针对当日反向的品种，要添加上其最小变动价位和合约乘数
% tmp = tradeList(liA,4:5);
% tradeList(:,4:5) = tmp(liF,:);
% 换月的品种也要补充-不考虑月份
[~,liA,liF] = unique(tradeFut);% 针对当日反向的品种，要添加上其最小变动价位和合约乘数
tmp = tradeList(liA,4:5);
tradeList(:,4:5) = tmp(liF,:);

profitFut = zeros(length(tradeFut),5); %交易方向、交易手数、交易价、结算价、合约乘数
% 将交易的品种分成开仓单和平仓单，分别处理
% 开仓单：今交易价和今结算价
% 平仓单：今交易价和昨结算价
profitFut(:,1) = sign(cell2mat(tradeList(:,2))); %交易方向
profitFut(:,2) = abs(cell2mat(tradeList(:,2))); %交易手数
[~,li0] = intersect(tradePrice(:,1),tradeList(:,1));
tradePrice = cell2mat(tradePrice(li0,2));
[~,~,liF] = unique(tradeList(:,1));
tradePrice = tradePrice(liF);


profitFut(:,3) = (tradePrice+profitFut(:,1).*cell2mat(tradeList(:,4))*slip).*(1+profitFut(:,1)*fixC); %考虑交易成本的交易价格
% 结算价要区分开仓单和平仓单
OpenOrClose = cell2mat(tradeList(:,3));
liOpen = find(OpenOrClose==1); %开仓单
liClose = find(OpenOrClose==-1); %平仓单
if ~isempty(liOpen)
%     setPrice = setPrice(li0,:);
%     setPrice = setPrice(liF,:);
    [~,li0] = intersect(setPrice(:,1),tradeList(liOpen,1));
    setPrice = cell2mat(setPrice(li0,2));
    profitFut(liOpen,4) = setPrice;
end
if ~isempty(liClose)
%     setPriceBF = setPriceBF(li0,:);
%     setPriceBF = setPriceBF(liF,:);
    [~,li0] = intersect(setPriceBF(:,1),tradeList(liClose,1));
    setPriceBF = cell2mat(setPriceBF(li0,2));
    profitFut(liClose,4) = setPriceBF;
end
profitFut(:,5) = cell2mat(tradeList(:,5)); %合约乘数

% 计算各个品种的收益
profit = (profitFut(:,4)-profitFut(:,3)).*profitFut(:,5).*profitFut(:,1).*profitFut(:,2);
profit(isnan(profit)) = 0; %profit是nan的情况发生在换月的时候，这个时候就默认平旧合约没有产生收益了%%%%%%%%%%%%%%%%%%%%%%%%%
ProfitDly = sum(profit);

% 市值=新开仓带来的市值，平仓的部分不计算
sizeDly = zeros(1,2);
if ~isempty(liOpen)
    sizeDly(1) = sum(profitFut(liOpen,4).*profitFut(liOpen,2).*profitFut(liOpen,5)); %不轧差
    sizeDly(2) = sum(profitFut(liOpen,4).*profitFut(liOpen,2).*profitFut(liOpen,1).*profitFut(liOpen,5)); %敞口，轧差
end



