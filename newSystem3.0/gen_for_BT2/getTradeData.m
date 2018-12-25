function tradeData = getTradeData(futureData,stDate,edDate,tradeP)
% 交易用的数据-真实主力合约数据
% tdAdj-记录换月时的换月价格
% adjFactor改变的当天进行换月，用旧合约的开盘价平，用新合约的开盘进
% 导入的是主力合约的数据

tdDate = futureData.Date;
stL = find(tdDate>=stDate,1,'first');
edL = find(tdDate<=edDate,1,'last');
tdDate = tdDate(stL:edL);
tmpData = [futureData.Open,futureData.Close,futureData.High,futureData.Low,futureData.Settle];
tmpData = tmpData(stL:edL,:);
adjFactor = futureData.adjFactor(:,2); %比例复权因子
adjFactor = [1;tick2ret(adjFactor)+1];  %当期的换月乘数
adjFactor = adjFactor(stL:edL);
chgL = find(futureData.adjFactor(stL:edL,3)==1); %换月所在行
tdAdj = zeros(length(adjFactor),1);
if ~isempty(chgL)
    tdAdj(chgL) = tmpData(chgL,1).*adjFactor(chgL); %旧合约在换月当日的开盘价
end
% 交易数据
if strcmpi(tradeP,'open')
    tdData = tmpData(:,1);
elseif strcmpi(tradeP,'avg')
    tdData = mean(tmpData(:,1:4),2);
elseif strcmpi(tradeP,'close')
    tdData = tmpData(:,2);
elseif strcmpi(tradeP,'High')
    tdData = tmpData(:,3);
elseif strcmpi(tradeP,'Low')
    tdData = tmpData(:,4);
elseif strcmpi(tradeP,'set')
    tdData = tmpData(:,5);
end
ttData = tmpData;

tradeData.tdDate = tdDate;
tradeData.tdData = tdData;
tradeData.tdAdj = tdAdj;
tradeData.ttData = ttData; %开盘价数据-因为如果止盈止损要用开盘价成交