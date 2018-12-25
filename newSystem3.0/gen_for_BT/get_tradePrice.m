function [tradePrice,setPrice] = get_tradePrice(CS,PType)
% ���ɽ��׼۸�ͽ���۸�
% ���׼۸񣺰����������;������ڵ���Ľ��׼۸�
% ����۸��������ڵ���Ľ����
futName = CS.futName;
futNameO = CS.futNameO;
dataOri = [CS.Open,CS.Close,CS.High,CS.Low,CS.ifChg,CS.OpenO,CS.CloseO,CS.HighO,CS.LowO];
if strcmpi(PType,'open')
    c = 1;
elseif strcmpi(PType,'close')
    c = 2;
elseif strcmpi(PType,'high')
    c = 3;
elseif strcmpi(PType,'low')
    c = 4;
end
if strcmpi(PType,'avgP')
    tradeP = [mean(dataOri(:,1:4),2);mean(dataOri(:,6:9),2)];
else
    tradeP = [dataOri(:,c);dataOri(:,c+5)];
end
tradePrice = [[futName;futNameO],num2cell(tradeP)];
tradePrice(tradeP==0,:) = [];
%
setPrice = [futName,num2cell(CS.Settle)];


