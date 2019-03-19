function targetPortfolio = getMainContName(fullHands)
%输入每日持仓方向和手数，输出每日持仓的主力合约名称
% 
% %% 得到每天每个品种的主力合约代码
mainContTable = getBasicData('future');

%% 和posFullDirect， posHands结合到一起
hands = fullHands;
% if all(size(hands) ~= size(posFullDirect))
%     error('posFullDirect and posHands have different size!')
% end


%% 调整成targetPortfolio格式
% 第一步，先unstack maincontTable，把品种名称散到列名，和持仓手数表保持一致
mainContTrans = table(mainContTable.Date, mainContTable.ContName, mainContTable.MainCont, ...
    'VariableNames', {'Date', 'ContName', 'MainCont'}); % 不要用选取[1 4 5]列这种方式，后期mainContTable列数可能有修改
mainContTrans.ContName = cellfun(@char, mainContTrans.ContName, 'UniformOutput', false);
mainContTrans = unstack(mainContTrans, 'MainCont', 'ContName');
mainContTrans = delStockBondIdx(mainContTrans);

% idx = cellfun(@strcmp, mainContTrans.Properties.VariableNames, posFullDirect.Properties.VariableNames);
% if ~all(idx == 1)
%     error('Please check the variableNames of mainContTrans and posFullDirect!')
% end
% clear idx

% 第二步，hands就是最终手数不需要再点乘
res = table2array(hands(:, 2:end));
% 把res中手数NaN都换成0，便于下一步处理

% 把mainContTrans选出posFullDirect对应日期部分

mainContTransSelec = hands(:, 1);
mainContTransSelec = outerjoin(mainContTransSelec, mainContTrans, 'type', 'left', 'MergeKeys', true);
mainContTrans = mainContTransSelec;
mainContTrans = table2array(mainContTrans(:, 2:end));
clear mainContTransSelec

tmp1 = reshape(mainContTrans', [size(mainContTrans, 2), size(mainContTrans, 1)]);
tmp2 = reshape(res', [size(res, 2), size(res, 1)]);

tmp = num2cell(nan(numel(tmp1), 2));
tmp(:, 1) = reshape(tmp1, numel(tmp1), 1);
tmp(:, 2) = num2cell(reshape(tmp2, numel(tmp2), 1));
tmp = reshape(tmp', 2, size(res, 2), size(res, 1));
tmp = permute(tmp, [2 1 3]);

% 第三步，前两步内容结合，调整成targetPortfolio格式
targetPortfolio = num2cell(NaN(size(hands, 1), 2));   %分配内存
targetPortfolio(:, 2) = num2cell(hands.Date);

% 循环赋值，没有别的运算的话很快
for iDate = 1 : size(res, 1)
    % 先对tmp(:, :, iDate)进行去NaN和0操作
    tmpI = tmp(:, :, iDate);
    tmpITrans = cellfun(@(x, y, z) ifelse(isnan(x), 0, x), tmpI(:, 2));
    validIdx = find(tmpITrans, size(tmpI, 1));
    tmpI = tmpI(validIdx, :);
    % 然后赋值
    targetPortfolio{iDate, 1} = tmpI;
end

clear tmp tmp1 tmp2

%% 2018.12.24之前写的版本：
% 这里每天循环，太慢了。。想办法改进一下
% 
% @2018.12.16比较速度改进前后BacktestAnalysis一样，但是targetPortfolio有出入
% 手数一样，但是原先的写法，合约总是会提前换月，查找一下原因
% 原因是：使用数据源不一样，原版用的是\\Cj-lmxue-dt\期货数据2.0\商品期货主力合约代码里面的主力合约数据；
% 新版本用的是Z:\baseData\codeBet.mat里面的数据，这个比原版本推迟一天，相当于是真正持仓的合约。
% \\Cj-lmxue-dt\期货数据2.0\商品期货主力合约代码 这里面保存的合约是自然时间，
% 比如20号下午收盘后你知道了该换月了，这里保存的就是20号，实际持仓的话交易日21号才能持仓到新合约
% Z:\baseData\codeBet.mat 里面保存的是持仓合约，比得知换月的自然时间滞后一天。

% 添加合约
% mainContPath = evalin('base', 'tradingPara.futMainContPath');
% 
% 
% targetPortfolio = num2cell(NaN(size(posFullDirect, 1), 2));   %分配内存
% for iDate = 1:size(posFullDirect, 1)
%     load([mainContPath, '\', num2str(posFullDirect.Date(iDate)), '.mat'])
%     futCont = regexp(maincont(:,1),'\w*(?=\.)','match');
% %     futCont = reshape([futCont{:}],size(futCont));
%     mainCont = regexp(maincont(:,2),'\w*(?=\.)','match');
% %     mainCont = reshape([mainCont{:}],size(mainCont)); 
%     mainCont = array2table([futCont mainCont],...
%         'VariableNames', {'VarietyName', 'MainCont'});
%     mainCont.VarietyName = cellfun(@(x)char(x), mainCont.VarietyName, 'UniformOutput', false);
%     
%     usualPath = evalin('base', 'usualPath');
%     varietyPath = [usualPath, '\fut_variety.mat'];
%     varieties = getallvarieties(varietyPath); % 得到所有品种名称，包括流动性差的
%     varieties.VarietyName = cellfun(@(x)char(x), varieties.VarietyName, 'UniformOutput', false);
%     % varieties 剔除股指和国债
%     varieties.ValidLabel = arrayfun(@(x, y, z) ifelse(ismember(x, {'IC', 'IF', 'IH', 'T', 'TF', 'TS'}), 0, 1), varieties.VarietyName);
%     validIdx = find(varieties.ValidLabel, height(varieties));
%     varieties = varieties(validIdx, 1);
%     
%     res = outerjoin(varieties, mainCont, 'type', 'left', 'MergeKeys', true);
%    
%     res.MainCont = cellfun(@(x)char(x), res.MainCont, 'UniformOutput', false);
%     
% %     得到每天持仓主力合约名称 + 手数，按照漫雪生成的格式便于输入回测平台
%     direct = posFullDirect(iDate, 2:end);
%     selecIdx = find(table2array(direct) ~= 0);
%     contName = res(selecIdx, :);
%     hands = posHands.fullHands;
%     contHands = hands(iDate, selecIdx + 1);
%     % 这个地方如果持仓方向~=0，但是手数round之后=0，需要做个剔除，不然回测跑不通
%     if sum(table2array(contHands) == 0 ) > 0
%         idx0 = find(table2array(contHands) ~= 0);
%         contName = contName(idx0, :);
%         contHands = contHands(:, idx0);
%     end
%     
%     % targetPortfolio里面手数有负号，如果回测跑不通的话先改成正号试试
%     mainContract = contName.MainCont;
%     contractHands = num2cell(transpose(table2array(contHands)));
%     if all(isnan(cell2mat(contractHands)))
%         % 如果手数都是空值（passway ~= 1的时候前几天会有这种情况）
%         validIdx = find(cellfun(@(x) ~isempty(x), mainContract), size(mainContract, 1));
%         mainContract = mainContract(validIdx);
%         contractHands = num2cell(zeros(size(mainContract, 1), 1));
%     end
%     targetPortfolio{iDate, 1} = [mainContract, contractHands];
%     targetPortfolio{iDate, 2} = posFullDirect.Date(iDate);
%       
% end

end