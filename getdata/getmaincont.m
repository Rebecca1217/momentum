function res = getmaincont()
%GETMAINCONT �õ�ÿ�����Ʒ�ֵ�������Լ����

%% ��ȡcode��name �Ķ�Ӧ��
contPath = 'Z:\baseData';
load([contPath, '\codeBet.mat']);

code = regexp(codeBet,'\w*(?=\.)','match');
code = cellfun(@str2double, code);
name = regexp(codeBet,'(?<=\_).*','match');

codename = table(code, name, 'VariableNames', {'ContCode', 'ContName'});

%% ��ȡÿ���code
load([contPath, '\TableData\futureData\TableData.mat'])
res = table(TableData.date, TableData.code, TableData.volume, TableData.mainCont, ...
    TableData.close, TableData.multifactor, ...
    'VariableNames', {'Date', 'ContCode', 'Volume', 'MainCont', 'Close', 'MultiFactor'});

%% match��ÿ���contname
res = outerjoin(res, codename, 'type', 'left', 'MergeKeys', true);

end

