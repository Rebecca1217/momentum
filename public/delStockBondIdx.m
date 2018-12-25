function res = delStockBondIdx(inputTable)
%DELSTOCKBONDIDX �޳���ָ�͹�ծ�ڻ�

deleteColumn = cellfun(@(x) ismember(x, {'IC', 'IF', 'IH', 'T', 'TF', 'TS'}), ...
    inputTable.Properties.VariableNames);
deleteIdx = find(deleteColumn, size(deleteColumn, 2));
inputTable(:, deleteIdx) = [];

res = inputTable;

end

