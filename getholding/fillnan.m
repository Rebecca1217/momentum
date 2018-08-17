function res = fillnan(inputVector)
%fill the nan data with previous ~nan ones

idx = (~isnan(inputVector)); % non nans
inputVectorValue = inputVector(idx); %挑出非空数值
res = inputVectorValue(cumsum(idx));

end

