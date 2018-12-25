function tdList = calRtnByRealData(sigLi,tradeData,HoldingHandsFut,Cost)
% sig�Ǿ���ֹӯֹ���������ź�
% ����ʵ���׺�Լ�����ݼ���

% ��ʵ��Լ����
tdDate = tradeData.tdDate;
tdData = tradeData.tdData;
tdAdj = tradeData.tdAdj; %���µ�ʱ��ɺ�Լ�Ŀ��̼�����
ttData = tradeData.ttData; %������Լ�ļ۸�����
% ���׳ɱ�
fixC = Cost.fix;
slip = Cost.float;
unit = Cost.unit;
% �ֲ�������ʱ�����
hdDate = HoldingHandsFut(:,1);
stL = find(hdDate==tdDate(1),1);
edL = find(hdDate==tdDate(end),1);
HoldingHandsFut = HoldingHandsFut(stL:edL,2);

%----------------------------------------------------------------------%
% �ز����
% ��ƽ�֣��󿪲�
% ÿ���ý���۽���
tdList = zeros(length(tdDate),6); %���򣬿��ֲ�����ƽ�ֲ������ֲ�����������ӯ�����Ƿ�ֹӯֹ��
if isempty(sigLi) %û�н����ź�
    return;
end
if sigLi(end,3)==length(tdDate) || isnan(sigLi(end,3)) %ƽ���ź������һ�л��ߵ���ֹʱ�仹δƽ��
    num = size(sigLi,1)-1;
else
    num = size(sigLi,1);
end
for i = 1:num %����źż���
    opL = sigLi(i,2); %�����ź�������
    clL = sigLi(i,3); %ƽ���ź�������
    sgn = sigLi(i,1); %���ַ���
    ifCut = sigLi(i,4); %�Ƿ�ֹӯֹ��ķ�ʽƽ��
    HandsI = HoldingHandsFut(opL+1:clL); %ÿ��Ӧ��������
    tdDataI = tdData(opL+1:clL+1); %���׼۸�
    tdAdjI = tdAdj(opL+1:clL+1); %�������
    ttDataI = ttData(opL+1:clL+1,:); %������Լ����
    if clL-opL>1 %���ǵ��������¸�ƽ�����
        tdList(opL+1:clL-1,1) = sgn; %��¼���ַ���
        tdList(opL+1,2) = 2-sgn; %��տ�
        tdList(clL,3) = 3-sgn; %���ƽ
        tdList(opL+1:clL,4) = HandsI; %ÿ�ճֲ�����
        % 
        opP = (tdDataI(1)+sgn*slip*unit)*(1+sgn*fixC); %���ּ�
        HandsAdd = [0;diff(HandsI)]; %�ֲ������ĸı�
        tdList(opL+1,5) = sgn*(ttDataI(1,5)-opP)*tdList(opL+1,4); %������
        setP = ttDataI(1,5); %�����
        for d = 2:clL-opL %�������ӯ��-����ӯ����3���ֹ��ɣ���ʷ�ֲֵ�ӯ��+�������ֲֵ�ӯ��+���µ�ӯ��
            HisPft = sgn*(ttDataI(d,5)-setP)*tdList(opL+d-1,4); %��ʷ�ֲֵ�ӯ��
            if tdAdjI(d)~=0%���ջ���
                opN = (tdDataI(d)+sgn*slip*unit)*(1+sgn*fixC); %�º�Լ���濪��
                chgPft = sgn*(tdAdjI(d)-opN)*tdList(opL+d-1,4); %����ӯ��
            else
                chgPft = 0;
            end
            if HandsAdd(d)>0 %�ֲ���������-ֱ����������Լ�ļ۸�Ϳ���
                opN = (tdDataI(d)+sgn*slip*unit)*(1+sgn*fixC); 
                addPft = sgn*(ttDataI(d,5)-opN)*HandsAdd(d);
            elseif HandsAdd(d)<0 %�ֲ���������
                if tdAdjI(d)~=0 %���ջ���-�ھɺ�Լ����ƽ��,�þɺ�Լ�Ŀ��̼�ƽ
                    clN = tdAdjI(d);
                else
                    clN = tdDataI(d);
                end
                clN = (clN-sgn*slip*unit)*(1-sgn*fixC);
                addPft = sgn*(clN-setP)*HandsAdd(d);
            else
                addPft = 0;
            end        
            tdList(opL+d,5) = HisPft+chgPft+addPft; %����ӯ��
            setP = ttDataI(d,5); 
        end
        % ƽ��ӯ��
        % ƽ�ּ�
        if tdAdjI(end)~=0 %ƽ���ոպ��ǻ�����,���þ�������Լ�Ŀ��̼�ƽ���������������ƽ�ּ�ƽ
            clP = (tdAdjI(end)-sgn*slip*unit)*(1-sgn*fixC);
        else
            if ifCut==1 %ֹӯֹ����
                clP = (ttDataI(end,1)-sgn*slip*unit)*(1-sgn*fixC); %��Լ���̼�ƽ
            else
                clP = (tdDataI(end)-sgn*slip*unit)*(1-sgn*fixC); %��Լ���׼�ƽ
            end
        end
        tdList(clL,5) = tdList(clL,5)+sgn*(clP-setP)*tdList(clL,4);
        tdList(clL,6) = ifCut;
    elseif clL-opL==1 %���쿪������ƽ
        tdList(opL+1,1) = sgn;
        tdList(opL+1,2) = 2-sgn;
        tdList(opL+1,3) = 5.5-0.5*sgn;
        tdList(opL+1,4) = HandsI; %�ֲ�����
        %
        opP = (tdDataI(1)+sgn*slip*unit)*(1+sgn*fixC); %���ּ�
        if tdAdjI(end)~=0 %ƽ���ոպ��ǻ�����,���þ�������Լ�Ŀ��̼�ƽ���������������ƽ�ּ�ƽ
            clP = (tdAdjI(end)-sgn*slip*unit)*(1-sgn*fixC);
        else
            if ifCut==1 %ֹӯֹ����
                clP = (ttDataI(end,1)-sgn*slip*unit)*(1-sgn*fixC); %��Լ���̼�ƽ
            else
                clP = (tdDataI(end)-sgn*slip*unit)*(1-sgn*fixC); %��Լ���׼�ƽ
            end
        end
        tdList(opL+1,5) = sgn*(clP-opP)*tdList(opL+1,4); %����
        tdList(opL+1,6) = ifCut;
    end
end
% ���һ���ź�-�����ֹ�����ݽ�β��ûƽ�֣�����ʽ��׻�û����
if sigLi(end,3)==length(tdDate) || isnan(sigLi(end,3)) %nan:���һ������δ��ɣ�length(tddate)���պ������ƽ��
    opL = sigLi(end,2); %�����ź�������
%     clL = sigLi(end,3); %ƽ���ź�������
    clL = length(tdDate); %ƽ���ź������У������ǲ�����ʱ��ƽ�֣�������һ����
    sgn = sigLi(end,1); %���ַ���
    ifCut = sigLi(end,4); %�Ƿ�ֹӯֹ��ķ�ʽƽ��
    HandsI = HoldingHandsFut(opL+1:clL); %ÿ��Ӧ��������
    tdDataI = tdData(opL+1:clL); %���׼۸�
    tdAdjI = tdAdj(opL+1:clL); %�������
    ttDataI = ttData(opL+1:clL,:); %������Լ����
    if clL-opL>1 %���ǵ��������¸�ƽ�����
        tdList(opL+1:clL-1,1) = sgn; %��¼���ַ���
        tdList(opL+1,2) = 2-sgn; %��տ�
        if ~isnan(sigLi(end,3))
            tdList(clL,3) = 3-sgn; %���ƽ
        else
            tdList(clL,1) = sgn;
        end
        tdList(opL+1:clL,4) = HandsI; %ÿ�ճֲ�����
        %
        opP = (tdDataI(1)+sgn*slip*unit)*(1+sgn*fixC); %���ּ�
        HandsAdd = [0;diff(HandsI)]; %�ֲ������ĸı�
        tdList(opL+1,5) = sgn*(ttDataI(1,5)-opP)*tdList(opL+1,4); %������
        setP = ttDataI(1,5); %�����
        for d = 2:clL-opL %�������ӯ��-����ӯ����3���ֹ��ɣ���ʷ�ֲֵ�ӯ��+�������ֲֵ�ӯ��+���µ�ӯ��
            HisPft = sgn*(ttDataI(d,5)-setP)*tdList(opL+d-1,4); %��ʷ�ֲֵ�ӯ��
            if tdAdjI(d)~=0%���ջ���
                opN = (tdDataI(d)+sgn*slip*unit)*(1+sgn*fixC); %�º�Լ���濪��
                chgPft = sgn*(tdAdjI(d)-opN)*tdList(opL+d-1,4); %����ӯ��
            else
                chgPft = 0;
            end
            if HandsAdd(d)>0 %�ֲ���������-ֱ����������Լ�ļ۸�Ϳ���
                opN = (tdDataI(d)+sgn*slip*unit)*(1+sgn*fixC);
                addPft = sgn*(ttDataI(d,5)-opN)*HandsAdd(d);
            elseif HandsAdd(d)<0 %�ֲ���������
                if tdAdjI(d)~=0 %���ջ���-�ھɺ�Լ����ƽ��,�þɺ�Լ�Ŀ��̼�ƽ
                    clN = tdAdjI(d);
                else
                    clN = tdDataI(d);
                end
                clN = (clN-sgn*slip*unit)*(1-sgn*fixC);
                addPft = sgn*(clN-setP)*HandsAdd(d);
            else
                addPft = 0;
            end
            tdList(opL+d,5) = HisPft+chgPft+addPft; %����ӯ��
            setP = ttDataI(d,5);
        end
        tdList(clL,6) = ifCut;
    elseif clL-opL==1 %���쿪������ƽ
        tdList(opL+1,1) = sgn;
        tdList(opL+1,2) = 2-sgn;
        if ~isnan(sigLi(end,3))
            tdList(opL+1,3) = 5.5-0.5*sgn;
        end
        tdList(opL+1,4) = HandsI; %�ֲ�����
        %
        opP = (tdDataI(1)+sgn*slip*unit)*(1+sgn*fixC); %���ּ�
        clP = ttDataI(end); %���һ�������յĽ����
        tdList(opL+1,5) = sgn*(clP-opP)*tdList(opL+1,4); %����
        tdList(opL+1,6) = ifCut;
    end
end
% ���Ժ�Լ����
tdList(:,5) = tdList(:,5)*Cost.multi;


   



