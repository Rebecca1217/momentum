function targetPortfolio = getMainContName(posHands)
%����ÿ�ճֲַ�������������ÿ�ճֲֵ�������Լ����
% 
% %% �õ�ÿ��ÿ��Ʒ�ֵ�������Լ����
mainContTable = getBasicData('future');

%% ��posFullDirect�� posHands��ϵ�һ��
hands = posHands.fullHands;
% if all(size(hands) ~= size(posFullDirect))
%     error('posFullDirect and posHands have different size!')
% end


%% ������targetPortfolio��ʽ
% ��һ������unstack maincontTable����Ʒ������ɢ���������ͳֲ���������һ��
mainContTrans = table(mainContTable.Date, mainContTable.ContName, mainContTable.MainCont, ...
    'VariableNames', {'Date', 'ContName', 'MainCont'}); % ��Ҫ��ѡȡ[1 4 5]�����ַ�ʽ������mainContTable�����������޸�
mainContTrans.ContName = cellfun(@char, mainContTrans.ContName, 'UniformOutput', false);
mainContTrans = unstack(mainContTrans, 'MainCont', 'ContName');
mainContTrans = delStockBondIdx(mainContTrans);

% idx = cellfun(@strcmp, mainContTrans.Properties.VariableNames, posFullDirect.Properties.VariableNames);
% if ~all(idx == 1)
%     error('Please check the variableNames of mainContTrans and posFullDirect!')
% end
% clear idx

% �ڶ�����hands����������������Ҫ�ٵ��
res = table2array(hands(:, 2:end));
% ��res������NaN������0��������һ������

% ��mainContTransѡ��posFullDirect��Ӧ���ڲ���

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

% ��������ǰ�������ݽ�ϣ�������targetPortfolio��ʽ
targetPortfolio = num2cell(NaN(size(hands, 1), 2));   %�����ڴ�
targetPortfolio(:, 2) = num2cell(hands.Date);

% ѭ����ֵ��û�б������Ļ��ܿ�
for iDate = 1 : size(res, 1)
    % �ȶ�tmp(:, :, iDate)����ȥNaN��0����
    tmpI = tmp(:, :, iDate);
    tmpITrans = cellfun(@(x, y, z) ifelse(isnan(x), 0, x), tmpI(:, 2));
    validIdx = find(tmpITrans, size(tmpI, 1));
    tmpI = tmpI(validIdx, :);
    % Ȼ��ֵ
    targetPortfolio{iDate, 1} = tmpI;
end

clear tmp tmp1 tmp2

%% 2018.12.24֮ǰд�İ汾��
% ����ÿ��ѭ����̫���ˡ�����취�Ľ�һ��
% 
% @2018.12.16�Ƚ��ٶȸĽ�ǰ��BacktestAnalysisһ��������targetPortfolio�г���
% ����һ��������ԭ�ȵ�д������Լ���ǻ���ǰ���£�����һ��ԭ��
% ԭ���ǣ�ʹ������Դ��һ����ԭ���õ���\\Cj-lmxue-dt\�ڻ�����2.0\��Ʒ�ڻ�������Լ���������������Լ���ݣ�
% �°汾�õ���Z:\baseData\codeBet.mat��������ݣ������ԭ�汾�Ƴ�һ�죬�൱���������ֲֵĺ�Լ��
% \\Cj-lmxue-dt\�ڻ�����2.0\��Ʒ�ڻ�������Լ���� �����汣��ĺ�Լ����Ȼʱ�䣬
% ����20���������̺���֪���˸û����ˣ����ﱣ��ľ���20�ţ�ʵ�ʳֲֵĻ�������21�Ų��ֲֵܳ��º�Լ
% Z:\baseData\codeBet.mat ���汣����ǳֲֺ�Լ���ȵ�֪���µ���Ȼʱ���ͺ�һ�졣

% ��Ӻ�Լ
% mainContPath = evalin('base', 'tradingPara.futMainContPath');
% 
% 
% targetPortfolio = num2cell(NaN(size(posFullDirect, 1), 2));   %�����ڴ�
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
%     varieties = getallvarieties(varietyPath); % �õ�����Ʒ�����ƣ����������Բ��
%     varieties.VarietyName = cellfun(@(x)char(x), varieties.VarietyName, 'UniformOutput', false);
%     % varieties �޳���ָ�͹�ծ
%     varieties.ValidLabel = arrayfun(@(x, y, z) ifelse(ismember(x, {'IC', 'IF', 'IH', 'T', 'TF', 'TS'}), 0, 1), varieties.VarietyName);
%     validIdx = find(varieties.ValidLabel, height(varieties));
%     varieties = varieties(validIdx, 1);
%     
%     res = outerjoin(varieties, mainCont, 'type', 'left', 'MergeKeys', true);
%    
%     res.MainCont = cellfun(@(x)char(x), res.MainCont, 'UniformOutput', false);
%     
% %     �õ�ÿ��ֲ�������Լ���� + ������������ѩ���ɵĸ�ʽ��������ز�ƽ̨
%     direct = posFullDirect(iDate, 2:end);
%     selecIdx = find(table2array(direct) ~= 0);
%     contName = res(selecIdx, :);
%     hands = posHands.fullHands;
%     contHands = hands(iDate, selecIdx + 1);
%     % ����ط�����ֲַ���~=0����������round֮��=0����Ҫ�����޳�����Ȼ�ز��ܲ�ͨ
%     if sum(table2array(contHands) == 0 ) > 0
%         idx0 = find(table2array(contHands) ~= 0);
%         contName = contName(idx0, :);
%         contHands = contHands(:, idx0);
%     end
%     
%     % targetPortfolio���������и��ţ�����ز��ܲ�ͨ�Ļ��ȸĳ���������
%     mainContract = contName.MainCont;
%     contractHands = num2cell(transpose(table2array(contHands)));
%     if all(isnan(cell2mat(contractHands)))
%         % ����������ǿ�ֵ��passway ~= 1��ʱ��ǰ����������������
%         validIdx = find(cellfun(@(x) ~isempty(x), mainContract), size(mainContract, 1));
%         mainContract = mainContract(validIdx);
%         contractHands = num2cell(zeros(size(mainContract, 1), 1));
%     end
%     targetPortfolio{iDate, 1} = [mainContract, contractHands];
%     targetPortfolio{iDate, 2} = posFullDirect.Date(iDate);
%       
% end

end