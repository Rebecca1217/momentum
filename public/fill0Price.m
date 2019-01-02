function res = fill0Price(inputVector)
%fill the zero data with previous ~zero ones
% only used for vertical fillin now

idx = (inputVector ~= 0); % non zero
inputVectorValue = inputVector(idx); %挑出非0数值
if idx(1) ~= 0
    res = inputVectorValue(cumsum(idx));
else
    id = cumsum(idx);
    validID = id(id ~= 0);
    nanNum = length(idx) - length(validID);
    res = [ones(nanNum, 1); inputVectorValue(validID)];
end

end

