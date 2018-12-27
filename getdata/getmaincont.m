function res = getmaincont()
%GETMAINCONT 得到每天各个品种的主力合约代码

%% 获取code和name 的对应表
contPath = 'Z:\baseData';
load([contPath, '\codeBet.mat']);

code = regexp(codeBet,'\w*(?=\.)','match');
code = cellfun(@str2double, code);
name = regexp(codeBet,'(?<=\_).*','match');

codename = table(code, name, 'VariableNames', {'ContCode', 'ContName'});

%% 获取每天的code
load([contPath, '\TableData\futureData\TableData.mat'])
res = table(TableData.date, TableData.code, TableData.volume, TableData.mainCont, ...
    TableData.close, TableData.multifactor, ...
    'VariableNames', {'Date', 'ContCode', 'Volume', 'MainCont', 'Close', 'MultiFactor'});

%% match到每天的contname
res = outerjoin(res, codename, 'type', 'left', 'MergeKeys', true);

end

