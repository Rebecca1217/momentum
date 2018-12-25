function sigData = getSigData2(signal,tdDate)
% 每一个信号对应的开平仓所在行
% signal:单个品种对应的信号和日期
% 注：如果最后一个交易信号对应的平仓信号没有发出，则最后一个信号的平仓时间记为nan
% 20180710：大改动：平仓信号的行标是前一版行标+1

signal = signal(signal(:,1)>=tdDate(1) & signal(:,1)<=tdDate(end),:);
signal = signal(:,2);
% 分多空头分别处理
sigLong = signal;
sigLong(signal==-1) = 0;
sigShort = signal;
sigShort(signal==1) = 0;
sigShort(signal==-1) = 1;
if sum(sigLong)~=0
    sigLiLong = getSigLines(sigLong);
else
    sigLiLong = [];
end
if sum(sigShort)~=0
    sigLiShort = getSigLines(sigShort);
    sigLiShort(:,1) = -1;
else
    sigLiShort = [];
end
sigData = sortrows([sigLiLong;sigLiShort],2);

end


function sigLi = getSigLines(sigDirect) 
% 忽略了第一行就发出信号的情况
% 方向、信号发出所在行、信号结束所在行


difSig = [sigDirect(1);diff(sigDirect)];
locs = find(difSig==1); %信号发出所在行

sigLi = zeros(length(locs),3);
sigLi(:,1) = 1;
sigLi(:,2) = locs; %发出信号所在行
for l = 1:length(locs)
    edL = find(difSig(locs(l):end)==-1,1,'first')+locs(l)-1;
    if isempty(edL)
        sigLi(l,3) = nan;
    else
        sigLi(l,3) = edL;
    end
end

end
