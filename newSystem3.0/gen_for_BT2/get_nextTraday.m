function nextTraday = get_nextTraday(oriDate)
% ��ȡoriDate����һ��������

% ����ȫ���Ľ�����
load Z:\baseData\TdaysAdd1\future\Tdays_dly.mat % ��������յ�������20080101-today+1
dateCalendar = Tdays(:,1);
stL = find(dateCalendar==oriDate(1),1,'first');
edL = find(dateCalendar>oriDate(end),1,'first');
dateCalendar = dateCalendar(stL:edL); %��Ӧ�����佻����
li = find(ismember(dateCalendar,oriDate))+1; %��������յĺ�һ��������������
nextTraday = dateCalendar(li);
