function BacktestAnalysis = CTAAnalysis_GeneralPlatform(BacktestResult)
% ======================CTAͨ�ûز�ƽ̨-��Ч����==============================
% -------------------------����------------------------------
% BacktestResult:�ز������ۼ����桢���ճ��ڡ����ڳֲ�
% -------------------------���------------------------------
% BacktestAnalysis:�Իز����ķ���

nv = BacktestResult.nv; %���
if exist('BacktestResult.riskExposure','var')~=0
    riskExposure = BacktestResult.riskExposure;
end

tt = {'�ۼ�����';'�껯����';'�껯����';'��ʤ��';'ӯ����';'���س�';'���س���ʼ����';'���س���������';'�س������ʱ��';'�س�ƽ������ʱ��';'���ձ�';'����س���';'��󳨿�';'ƽ������';'�ز⿪ʼ����';'�ز��������'};

analysis = zeros(length(tt),1);
analysis(1) = nv(end,2);
analysis(2) = mean(nv(:,3))*244;
analysis(3) = std(nv(:,3))*sqrt(244);
analysis(4) = sum(nv(:,3)>0)/size(nv,1);
analysis(5) = mean(nv(nv(:,3)>0,3))/-mean(nv(nv(:,3)<0,3));
dd = nv(:,2)-cummax(nv(:,2));
ddtime = zeros(length(dd),3);
t = 1;
for d = 1:length(dd)
    stL = find(dd(t:end)<0,1,'first')+t-1;
    if isempty(stL)
        break;
    end
    ddtime(d,1) = stL;
    edL = find(dd(stL:end)>=0,1,'first')+stL-1;
    if isempty(edL)
        edL = length(dd);
    end
    ddtime(d,2) = edL;
    ddtime(d,3) = edL-stL+1;
    t = edL;
    if t==length(dd)
        break;
    end
end
analysis(6) = -min(dd);
Cmax = cummax(nv(:,2));
analysis(8) = nv(find(dd==min(dd),1),1);
analysis(7) = nv(find(nv(:,2)==Cmax,1),1);
ddtime(ddtime(:,1)==0,:) = [];
analysis(9) = max(ddtime(:,3));
analysis(10) = median(ddtime(:,3));
analysis(11) = analysis(2)/analysis(3);
analysis(12) = analysis(2)/-min(dd);
if exist('riskExposure','var')~=0
    analysis(13) = max(riskExposure(:,2));
    analysis(14) = mean(riskExposure(:,2));
end
analysis(15) = nv(1,1);
analysis(16) = nv(end,1);

BacktestAnalysis = [tt,num2cell(analysis)];





