function nanL = NanL_from_chgCode(code,nannum)
% TableData����Ʒ�ָı䵼����Ҫ���nan��λ��
% nannum:���׸���Ϊnan��ֵ֮ǰ�����м���nan
% ע�⣺win��nannum֮����һ��ת�������⣬nannum��һ������win

chgL = find([0;diff(code)~=0]~=0); %��Ʒ���У���ǵ�����Ʒ�ֵ���ʼ��
nanL = zeros(length(chgL),nannum);
for n = 1:nannum
    nanL(:,n) = chgL+n-1;
end
nanL = unique(nanL(:)); %������¹����У������ݳ��ȿ��ܻ��nannum��
nanL(nanL>length(code)) = []; %������е��¹ɸպô�����������ǿ��ܻᳬ������Ӧ�еĳ���
