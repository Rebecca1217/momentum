function nanL = NanL_from_chgCode(code,nannum)
% TableData由于品种改变导致需要填充nan的位置
% nannum:在首个不为nan的值之前，共有几个nan
% 注意：win和nannum之间有一个转换的问题，nannum不一定就是win

chgL = find([0;diff(code)~=0]~=0); %换品种行，标记的是新品种的起始行
nanL = zeros(length(chgL),nannum);
for n = 1:nannum
    nanL(:,n) = chgL+n-1;
end
nanL = unique(nanL(:)); %如果有新股上市，其数据长度可能会比nannum短
nanL(nanL>length(code)) = []; %如果上市的新股刚好代码排在最后，那可能会超出矩阵应有的长度
