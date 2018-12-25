function BacktestAnalysis = CTAAnalysis_GeneralPlatform_2(BacktestResult)
% ======================CTAͨ�ûز�ƽ̨-��Ч����==============================
% -------------------------����------------------------------
% BacktestResult:�ز������ۼ����桢���ճ��ڡ����ڳֲ�
% -------------------------���------------------------------
% BacktestAnalysis:�Իز����ķ���
% 20180710������
% 1.��ʤ�ʸĳ��в�λ����µ���ʤ��(��С��ƫ���Ϊ��������=0�Ľ����գ�
% 2.ƽ�����ڸĳ��в�λ�µ�ƽ������

nv = BacktestResult.nv; %���

tt = {'�ۼ�����';'�껯����';'�껯����';'��ʤ��';'ӯ����';'���س�';'�س������ʱ��';'���ձ�';'����س���';'��󳨿�';'ƽ������';'�ز⿪ʼ����';'�ز��������'};

analysis = zeros(length(tt),1);
analysis(1) = nv(end,2); %�ۼ�����
analysis(2) = mean(nv(:,3))*244; %�껯����
analysis(3) = std(nv(:,3))*sqrt(244); %�껯����
analysis(4) = sum(nv(:,3)>0)/sum(nv(:,3)~=0); %�в�λ������µ���ʤ��
analysis(5) = mean(nv(nv(:,3)>0,3))/-mean(nv(nv(:,3)<0,3)); %ӯ����
dd = nv(:,2)-cummax(nv(:,2)); 
% dd��0�为����ʼ�س���dd�ɸ���0�������س�
sgn = sign(dd);
noDDLocs = find(sgn==0); %û�лس���ʱ���������
analysis(6) = -min(dd); %���س�
analysis(7) = max(diff(noDDLocs)); %�س������ʱ��
analysis(8) = analysis(2)/analysis(3); %sr
analysis(9) = analysis(2)/-min(dd); %calmar
if ismember('riskExposure',fieldnames(BacktestResult))
    riskExposure = BacktestResult.riskExposure;
    analysis(10) = max(riskExposure(:,2));
    analysis(11) = mean(riskExposure(riskExposure(:,2)~=0,2));
end
analysis(12) = nv(1,1);
analysis(13) = nv(end,1);

BacktestAnalysis = [tt,num2cell(analysis)];





