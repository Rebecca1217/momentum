function res = delStockBondIdx(inputTable)
%DELSTOCKBONDIDX 剔除股指和国债期货

deleteColumn = cellfun(@(x) ismember(x, {'IC', 'IF', 'IH', 'T', 'TF', 'TS'}), ...
    inputTable.Properties.VariableNames);
deleteIdx = find(deleteColumn, size(deleteColumn, 2));
inputTable(:, deleteIdx) = [];

res = inputTable;

end

