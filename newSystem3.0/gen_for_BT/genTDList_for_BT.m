function [tradeList,hisList] = genTDList_for_BT(realTD,realTM)
% Ϊ�ز�ϵͳ���ɽ����嵥
% ������պ����յ�ʵ�ʳֲ����
% tradeListΪ���ɵ����յĽ����嵥
% tradeList�ĸ�ʽΪ��(AL1803,-5,1)������Ϊ1��ƽ��Ϊ-1


% ���ɽ��׵�-TD��TM����
% ��Ʒ�ִ�������
if ~isempty(realTD)
    realTD = sortrows(realTD,1);
end
if ~isempty(realTM)
    realTM = sortrows(realTM,1);
end

if ~isempty(realTD) && ~isempty(realTM)
    ttFut = unique([realTD(:,1);realTM(:,1)]);
elseif isempty(realTD) && isempty(realTM) %��������ղ�
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
tradeListStd = cell(1,5); %Ʒ�ִ��룬Ʒ���·ݣ����ַ�������
hisListStd = cell(1,4); %Ʒ�ִ��룬Ʒ���·ݣ����ַ�������
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
        if isempty(liTD) && ~isempty(liTM) %����û�ֲ֣�������-�¿��ֵ�Ʒ��
            tradeListStd(t,:) = [realTM{liTM,1},realTM{liTM,2},realTM(liTM,3),realTM(liTM,4),num2cell(1)];
        elseif ~isempty(liTD) && isempty(liTM) %�����гֲ֣�����û�гֲ�-ƽ��Ʒ��
            tradeListStd(t,:) = [realTD{liTD,1},realTD{liTD,2},num2cell(-realTD{liTD,3}),realTD(liTD,4),num2cell(-1)];
        elseif ~isempty(liTD) && ~isempty(liTM) %���պ����ն��гֲ�-������
            hdTD = realTD(liTD,:); %���ճֲ����
            hdTM = realTM(liTM,:); %���ճֲ����
            if strcmp(hdTD{2},hdTM{2}) %�������ճ���ͬһ��Ʒ�ֵ�ͬһ����Լ-��Լ�·��ж�
                tradeListStd{t,1} = hdTD{1}; %Ʒ�ִ���
                tradeListStd{t,2} = hdTD{2}; %Ʒ���·�
                if hdTD{3}==hdTM{3} %�������ճֲַ�����ͬ
                    hands = hdTM{4}-hdTD{4}; %����������
                    if hands>0 %����
                        if hdTD{3}==-1 %ԭ��Ϊ�ղ�
                            tradeListStd{t,3} = -1;
                            tradeListStd{t,4} = hands;
                        elseif hdTD{3}==1 %ԭ��Ϊ���
                            tradeListStd{t,3} = 1;
                            tradeListStd{t,4} = hands;
                        end
                        tradeListStd{t,5} = 1; %ֻҪ�ǼӲ֣���Ϊ����
                        hisListStd(t,:) = hdTD(1:4);
                    elseif hands<0 %����
                        if hdTD{3}==1 %ԭ��Ϊ���
                            tradeListStd{t,3} = -1;
                            tradeListStd{t,4} = -hands;
                        elseif hdTD{3}==-1 %ԭ��Ϊ�ղ�
                            tradeListStd{t,3} = 1;
                            tradeListStd{t,4} = -hands;
                        end
                        tradeListStd{t,5} = -1; %ֻҪ�Ǽ��֣���Ϊƽ��
                        hisListStd(t,:) = hdTM(1:4);
                    else %������������λ����
                        tradeListStd{t,3} = 0;
                        tradeListStd{t,4} = 0;
                        tradeListStd{t,5} = 0;
                        hisListStd(t,:) = hdTM(1:4);
                    end
                elseif hdTD{3}~=hdTM{3} %�������շ���ֲ�
                    % ��ƽ�֣��󿪲�
                    tradeListStd(t,:) = [hdTD{1},hdTD{2},num2cell(-hdTD{3}),hdTD(4),num2cell(-1)]; %ƽ��
                    tradeListStd(t+1,:) = [hdTM{1},hdTM{2},hdTM(3),hdTM(4),num2cell(1)]; %����
                    t = t+1;
                end
            else %�������ճ���ͬһ��Ʒ�ֵĲ�ͬ��Լ-����
                % ƽ�ɺ�Լ�����º�Լ�����¾ɺ�Լ���������ܲ�ͬ
                tradeListStd(t,:) = [hdTD{1},hdTD{2},num2cell(-hdTD{3}),hdTD(4),num2cell(-1)]; %ƽ��-ƽ���ɺ�Լ
                tradeListStd(t+1,:) = [hdTM{1},hdTM{2},hdTM(3),hdTM(4),num2cell(1)]; %����-���º�Լ���濪��
                t = t+1;
            end
        end
        t = t+1;
    end
    % �Ѳ���Ҫ���׵�Ʒ��ȥ��
    hands = cell2mat(tradeListStd(:,3));
    tradeListStd(hands==0,:) = [];
    
    % ��tradeListStd���������
    if isempty(tradeListStd)
        tradeList = {};
    else
        tradeList = [strcat(tradeListStd(:,1),tradeListStd(:,2)),num2cell(cell2mat(tradeListStd(:,3)).*cell2mat(tradeListStd(:,4))),tradeListStd(:,5)];
    end
    % ��û����ʷ�ֲֵ�Ʒ��ȥ��
    ifEmp = cellfun(@(x) isempty(x),hisListStd(:,1));
    hisListStd(ifEmp,:) = [];
    if isempty(hisListStd)
        hisList = {};
    else
        hisList = [strcat(hisListStd(:,1),hisListStd(:,2)),num2cell(cell2mat(hisListStd(:,3)).*cell2mat(hisListStd(:,4)))];
    end
end


end

