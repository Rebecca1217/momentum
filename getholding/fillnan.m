function res = fillnan(inputVector)
%fill the nan data with previous ~nan ones
% only used for vertical fillin now

idx = (~isnan(inputVector)); % non nans
inputVectorValue = inputVector(idx); %挑出非空数值
if idx(1) ~= 0
    res = inputVectorValue(cumsum(idx));
else
    id = cumsum(idx);
    validID = id(id ~= 0);
    nanNum = length(idx) - length(validID);
    res = [NaN(nanNum, 1); inputVectorValue(validID)];
end

end

