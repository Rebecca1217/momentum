function sigData = getSigData(signal,tdDate)
% 注：如果最后一个交易信号对应的平仓信号没有发出，则最后一个信号的平仓时间记为nan

signal(signal(:,1)<tdDate(1),:) = [];
signal(signal(:,1)>tdDate(end),:) = [];
signal = signal(:,2);
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

difSig = [0;diff(sigDirect)];
locs = find(difSig==1); %信号发出所在行

sigLi = zeros(length(locs),4);
sigLi(:,1) = 1;
sigLi(:,2) = locs;
for l = 1:length(locs)
    edL = find(difSig(locs(l):end)==-1,1,'first')+locs(l)-1;
    if isempty(edL)
        sigLi(l,3) = nan;
    else
        sigLi(l,3) = edL-1;
    end
end

end
