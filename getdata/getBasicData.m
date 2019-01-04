function res = getBasicData(type)
%GETMAINCONT �õ�ÿ�����Ʒ�ֵ�������Լ����

%% ��ȡcode��name �Ķ�Ӧ��
contPath = 'Z:\baseData';
load([contPath, '\codeBet.mat']);

code = regexp(codeBet,'\w*(?=\.)','match');
code = cellfun(@str2double, code);
name = regexp(codeBet,'(?<=\_).*','match');

codename = table(code, name, 'VariableNames', {'ContCode', 'ContName'});
if strcmp(type, 'future')
    %% ��ȡÿ���code
    load([contPath, '\TableData\futureData\TableData.mat'])
    res = table(TableData.date, TableData.code, TableData.volume, TableData.mainCont, ...
        TableData.close, TableData.multifactor, TableData.adjfactor, TableData.atrABS, ...
        'VariableNames', {'Date', 'ContCode', 'Volume', 'MainCont', 'Close', 'MultiFactor', 'AdjFactor', 'ATRABS'});
else % ��ȡÿ����ֻ�����
    load('\\Cj-lmxue-dt\�ڻ�����2.0\SpotGoodsData_v2\spotData.mat')
    res = table(spotData.date, spotData.code, spotData.v1, ...
        'VariableNames', {'Date', 'ContCode', 'SpotPrice'});
end

%% match��ÿ���contname
res = outerjoin(res, codename, 'type', 'left', 'MergeKeys', true);

end

