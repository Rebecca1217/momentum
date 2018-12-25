function [res] = getpricedata(dataPara)
%get price data in a table, including Date, Close_Price for all varieties.

if ~(isfield(dataPara, 'path') && ...
        isfield(dataPara, 'dateFrom') && isfield(dataPara, 'dateTo'))
    error('dataPara must contain path, dateFrom and dateTo!')
end
usualPath = evalin('base', 'usualPath');
varietyPath = [usualPath, '\fut_variety.mat'];
varieties = getallvarieties(varietyPath); % 得到所有品种名称，包括流动性差的
% @2018.12.24 先把国债期货和股指期货剔除
validIdx = rowfun(@(x) ~ismember(x, {'IC', 'IF', 'IH', 'T', 'TF', 'TS'}), varieties);
varieties = varieties(validIdx.Var1, 1);

pricePath = dataPara.path;
dateFrom = dataPara.dateFrom;
dateTo = dataPara.dateTo;
priceType = dataPara.priceType;

res = getrawprice(pricePath, varieties, dateFrom, dateTo, priceType);

% exclude illiquidity



end

