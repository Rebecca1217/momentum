function res = fillnan(inputVector)
%fill the nan data with previous ~nan ones

idx = (~isnan(inputVector)); % non nans
inputVectorValue = inputVector(idx); %�����ǿ���ֵ
res = inputVectorValue(cumsum(idx));

end

