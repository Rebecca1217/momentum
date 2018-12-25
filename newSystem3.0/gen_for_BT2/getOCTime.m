function sig = getOCTime(signal,type)
% type1:long
% type2:short

if type==2
    signal = -signal;
end

difSig = [signal(1);diff(signal)];
num = sum(difSig==1); %开仓信号个数
sig = zeros(num,2);
for n = 1:num
    opL = find(difSig==1,n,'first');
    sig(n,1) = opL(end);
    clL = find(difSig(sig(n,1)+1:end)==-1,1,'first')+sig(n,1);
    if isempty(clL)
        sig(n,2) = nan;
    else
        sig(n,2) = find(difSig

