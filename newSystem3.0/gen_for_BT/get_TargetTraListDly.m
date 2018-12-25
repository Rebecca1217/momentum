function [TargetTraListDly,HisListDly] = get_TargetTraListDly(TargetPortfolio,nextTraday)
% ����ÿ��Ŀ��ֲ�����ÿ��ʵ�ʵĽ��׵�
% ����ÿ�յ�Ŀ��ֲ�������
% ����Ҫ���׵ĵ��Ӷ�Ӧ�����ھ��ǵ��������
% TargetTraListDly��20180209Ҫ���׵ĵ��ӱ�ǵ�����Ϊ20180209
% TargetTraListDly�еĸ�ʽ��TargetPortfolio�еĸ�ʽ��ͬ
% TargetTraListDly��һ���ǽ����嵥�����У�Ʒ�ִ��롢���������뷽�򡢿���orƽ�֣����ڶ���������
% HisListDly��¼��ʷ�ֲ֣�20180209����ʷ�ֲּ�¼��20180209��һ��

TargetTraListDly = cell(size(TargetPortfolio));
TargetTraListDly(:,2) = num2cell(nextTraday);
TargetTraListDly{1,1} = [TargetPortfolio{1,1},num2cell(ones(size(TargetPortfolio{1,1},1),1))];
HisListDly = cell(size(TargetPortfolio));
HisListDly(:,2) = num2cell(nextTraday);
HisListDly{1,1} = {}; %��һ��û����ʷ�ֲ�
if length(nextTraday)==1 %��һ��������
    return;
end
% ��TargetPortfolio�����Ŀ���ʽ�����롢�·ݡ���������
TargetPortfolioStd = get_stdFormat(TargetPortfolio(:,1));
% ��������Ľ��-��Ҫ�õ����պ�ǰһ�յ�Ŀ��ֲ�
for d = 2:length(nextTraday)
    realTM = TargetPortfolioStd{d,1}; %�������ɵ�Ŀ�굥���������Ŀ��ֲ�,20180208��Ŀ�굥
    realTD = TargetPortfolioStd{d-1,1}; %ǰһ�����ɵ�Ŀ�굥���ǵ��յ�Ŀ��ֲ�,20180207��Ŀ�굥
    [tradeList,hisList] = genTDList_for_BT(realTD,realTM); %tradeList:��TargetPortfolio�еĸ�ʽ��ͬ
    TargetTraListDly{d,1} = tradeList;
    HisListDly{d,1} = hisList;
end
end

function stdFormat = get_stdFormat(oriFormat)

stdFormat = cell(length(oriFormat),1);
for d = 1:length(oriFormat)
    tmp = oriFormat{d};
    code = regexp(tmp(:,1),'\D*(?=\d)','match');
    code = reshape([code{:}],size(code));
    cont = regexp(tmp(:,1),'(?<=\D)\d*','match');
    cont = reshape([cont{:}],size(cont));
    info = cell2mat(tmp(:,2));
    direct = sign(info);
    hands = abs(info);
    stdFormat{d} = [code,cont,num2cell(direct),num2cell(hands)];
end
end