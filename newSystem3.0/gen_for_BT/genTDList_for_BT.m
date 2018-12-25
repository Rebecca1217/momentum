function [tradeList,hisList] = genTDList_for_BT(realTD,realTM)
% 为回测系统生成交易清单
% 输入今日和明日的实际持仓情况
% tradeList为生成的明日的交易清单
% tradeList的格式为：(AL1803,-5,1)，开仓为1，平仓为-1


% 生成交易单-TD与TM轧差
% 按品种代码排序
if ~isempty(realTD)
    realTD = sortrows(realTD,1);
end
if ~isempty(realTM)
    realTM = sortrows(realTM,1);
end

if ~isempty(realTD) && ~isempty(realTM)
    ttFut = unique([realTD(:,1);realTM(:,1)]);
elseif isempty(realTD) && isempty(realTM) %今明天均空仓
    tradeList = {};
    hisList = {};
    return;
else
    if ~isempty(realTD)
        ttFut = realTD(:,1);
    else
        ttFut = realTM(:,1);
    end
end
tradeListStd = cell(1,5); %品种代码，品种月份，开仓方向，手数
hisListStd = cell(1,4); %品种代码，品种月份，开仓方向，手数
if ~ isempty(realTD) || ~isempty(realTM)
    t = 1;
    for i = 1:length(ttFut)
        fut = ttFut{i};
        try
            liTD = find(ismember(realTD(:,1),fut),1);
        catch
            liTD = {};
        end
        try
            liTM = find(ismember(realTM(:,1),fut),1);
        catch
            liTM = {};
        end
        if isempty(liTD) && ~isempty(liTM) %今日没持仓，明日有-新开仓的品种
            tradeListStd(t,:) = [realTM{liTM,1},realTM{liTM,2},realTM(liTM,3),realTM(liTM,4),num2cell(1)];
        elseif ~isempty(liTD) && isempty(liTM) %今日有持仓，明日没有持仓-平仓品种
            tradeListStd(t,:) = [realTD{liTD,1},realTD{liTD,2},num2cell(-realTD{liTD,3}),realTD(liTD,4),num2cell(-1)];
        elseif ~isempty(liTD) && ~isempty(liTM) %今日和明日都有持仓-做轧差
            hdTD = realTD(liTD,:); %今日持仓情况
            hdTM = realTM(liTM,:); %明日持仓情况
            if strcmp(hdTD{2},hdTM{2}) %今明两日持有同一个品种的同一个合约-合约月份判断
                tradeListStd{t,1} = hdTD{1}; %品种代码
                tradeListStd{t,2} = hdTD{2}; %品种月份
                if hdTD{3}==hdTM{3} %今明两日持仓方向相同
                    hands = hdTM{4}-hdTD{4}; %增减仓手数
                    if hands>0 %增仓
                        if hdTD{3}==-1 %原本为空仓
                            tradeListStd{t,3} = -1;
                            tradeListStd{t,4} = hands;
                        elseif hdTD{3}==1 %原本为多仓
                            tradeListStd{t,3} = 1;
                            tradeListStd{t,4} = hands;
                        end
                        tradeListStd{t,5} = 1; %只要是加仓，均为开仓
                        hisListStd(t,:) = hdTD(1:4);
                    elseif hands<0 %减仓
                        if hdTD{3}==1 %原本为多仓
                            tradeListStd{t,3} = -1;
                            tradeListStd{t,4} = -hands;
                        elseif hdTD{3}==-1 %原本为空仓
                            tradeListStd{t,3} = 1;
                            tradeListStd{t,4} = -hands;
                        end
                        tradeListStd{t,5} = -1; %只要是减仓，均为平仓
                        hisListStd(t,:) = hdTM(1:4);
                    else %不增不减，仓位不变
                        tradeListStd{t,3} = 0;
                        tradeListStd{t,4} = 0;
                        tradeListStd{t,5} = 0;
                        hisListStd(t,:) = hdTM(1:4);
                    end
                elseif hdTD{3}~=hdTM{3} %今明两日反向持仓
                    % 先平仓，后开仓
                    tradeListStd(t,:) = [hdTD{1},hdTD{2},num2cell(-hdTD{3}),hdTD(4),num2cell(-1)]; %平仓
                    tradeListStd(t+1,:) = [hdTM{1},hdTM{2},hdTM(3),hdTM(4),num2cell(1)]; %开仓
                    t = t+1;
                end
            else %今明两日持有同一个品种的不同合约-换月
                % 平旧合约，开新合约，且新旧合约的手数可能不同
                tradeListStd(t,:) = [hdTD{1},hdTD{2},num2cell(-hdTD{3}),hdTD(4),num2cell(-1)]; %平仓-平掉旧合约
                tradeListStd(t+1,:) = [hdTM{1},hdTM{2},hdTM(3),hdTM(4),num2cell(1)]; %开仓-在新合约上面开仓
                t = t+1;
            end
        end
        t = t+1;
    end
    % 把不需要交易的品种去掉
    hands = cell2mat(tradeListStd(:,3));
    tradeListStd(hands==0,:) = [];
    
    % 把tradeListStd整理成两列
    if isempty(tradeListStd)
        tradeList = {};
    else
        tradeList = [strcat(tradeListStd(:,1),tradeListStd(:,2)),num2cell(cell2mat(tradeListStd(:,3)).*cell2mat(tradeListStd(:,4))),tradeListStd(:,5)];
    end
    % 把没有历史持仓的品种去掉
    ifEmp = cellfun(@(x) isempty(x),hisListStd(:,1));
    hisListStd(ifEmp,:) = [];
    if isempty(hisListStd)
        hisList = {};
    else
        hisList = [strcat(hisListStd(:,1),hisListStd(:,2)),num2cell(cell2mat(hisListStd(:,3)).*cell2mat(hisListStd(:,4)))];
    end
end


end

