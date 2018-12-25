function result = ifelse(condition, trueResult, falseResult)
%IFELSE input condition, ifture returns trueResult, vice versa
narginchk(3,3);  % check correct number of input args, min = 3, max = 3
if condition
    result = trueResult;
else
    result = falseResult;
    
end

