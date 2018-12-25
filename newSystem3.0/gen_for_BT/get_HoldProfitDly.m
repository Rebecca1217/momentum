function [profitDly,sizeDly] = get_HoldProfitDly(hisList,setPrice,setPriceBF,paraT)
% 计算历史持仓带来的盈亏
% 根据当日的历史持仓单来计算
% 昨结算价和金结算价

MultiInfo = paraT.MultiInfo;

profitFut = zeros(size(hisList,1),5); %交易方向、交易手数、昨结算价、结算价、合约乘数
profitFut(:,1) = sign(cell2mat(hisList(:,2)));
profitFut(:,2) = abs(cell2mat(hisList(:,2)));
[~,li0,li1] = intersect(hisList(:,1),setPriceBF(:,1));
profitFut(li0,3) = cell2mat(setPriceBF(li1,2));
[~,li0,li1] = intersect(hisList(:,1),setPrice(:,1));
profitFut(li0,4) = cell2mat(setPrice(li1,2));
hisFut = regexp(hisList(:,1),'\D*(?=\d)','match');
hisFut = reshape([hisFut{:}],size(hisFut));
[~,li0,li1] = intersect(hisFut,MultiInfo(:,1));
profitFut(li0,5) = cell2mat(MultiInfo(li1,2));

profit = (profitFut(:,4)-profitFut(:,3)).*profitFut(:,5).*profitFut(:,1).*profitFut(:,2);
profitDly = sum(profit);

sizeDly = zeros(1,2);
sizeDly(1) = sum(profitFut(:,4).*profitFut(:,2).*profitFut(:,5)); %敞口,不轧差
sizeDly(2) = sum(profitFut(:,4).*profitFut(:,2).*profitFut(:,1).*profitFut(:,5)); %敞口，轧差



