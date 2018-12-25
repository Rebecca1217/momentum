function [edDate,tmDate,ifTD] = getCalendar

conn = database('wind_fsync','query','query','com.microsoft.sqlserver.jdbc.SQLServerDriver','jdbc:sqlserver://10.201.4.164:1433;databaseName=wind_fsync');

sql = 'select TRADE_DAYS from CFuturesCalendar where S_INFO_EXCHMARKET = ''CZCE'' order by TRADE_DAYS';
cursorA = exec(conn,sql);
cursorB = fetch(cursorA);
dateCalendar = str2double(cursorB.Data);

todayNum = str2num(datestr(today,'yyyymmdd'));
edDate = dateCalendar(find(dateCalendar<=todayNum,1,'last'));
tmDate = dateCalendar(find(dateCalendar>todayNum,1,'first'));
dateCalendar(or(dateCalendar<20080101,dateCalendar>edDate)) = [];
save dateCalendar.mat dateCalendar
if edDate~=todayNum %判断今天是不是交易日
    ifTD = 0;
else
    ifTD = 1;
end