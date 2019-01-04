function res = getPremium()
%GETPREMIUM �õ�����ȫ��ʱ����ֻ��������
% spot/future�� ��1��ʾ�ֻ���ۣ���1��ʾ�ڻ����

% ע���ֻ������и����⣬��ȫ��������������ֱ�Ӷ�Ӧ��������Բ���outerjoin����ʽ
%% �ڻ�����
future = getBasicData('future');
future = table(future.Date, future.ContName, future.Close, ...
    'VariableNames', {'Date', 'ContName', 'Close'});
future.ContName = cellfun(@char, future.ContName, 'UniformOutput', false);

%% �ֻ�����
spot = getBasicData('spot');
spot = table(spot.Date, spot.ContName, spot.SpotPrice, ...
    'VariableNames', {'Date', 'ContName', 'SpotPrice'});
spot.ContName = cellfun(@char, spot.ContName, 'UniformOutput', false);

%% ��۽��
res = outerjoin(future, spot, 'type', 'left', 'MergeKeys', true, 'Keys', [1, 2]);
res.SpotPremium = res.SpotPrice ./ res.Close;
res = table(res.Date, res.ContName, res.SpotPremium, ...
    'VariableNames', {'Date', 'ContName', 'SpotPremium'});

res = unstack(res, 'SpotPremium', 'ContName');
res = delStockBondIdx(res);


end

