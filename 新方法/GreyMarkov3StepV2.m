function [mre,c,p,varargout]=GreyMarkov3StepV2(realvalue,vervalue,verfore,RE,varargin)
%% ��ɫ����Ʒ�ģ�ͣ����вв���������3��ת�Ƹ�����Ԥ��ֵ
% ��ģ���裺1������VerhulstԤ��ֵ���в�����2������״̬ 3��״̬ת�Ƹ��ʾ���
% 4������Ԥ��ֵ
% input��
%          realvalue - ��ʵֵ����
%          vervalue  - Verhulstģ�����ֵ
%          verfore   - Verhulstģ��Ԥ��ֵ
%          RE        - Verhulstģ��Ԥ��������
%          sn        - ����״̬�ĸ��� state number
% output��
%          mre - ���ģ��ƽ��������
%          c   - ���ģ�ͺ�����
%          p   - ���ģ��С������
% modify on 2018/10/30
% -------------------------------------------------------------------------------

if nargout>5
    error('Too many output arguments!');
end
if ~isempty(find(isinf(RE),1))
    error('����RE�д���INFԪ�أ�');
end
if nargin==4
    sn=3; % ����Ĭ��״̬����
    tiaoshi=1; % ���õ�����ϢĬ�ϲ���ʾ
elseif nargin==5
    tiaoshi=1;
elseif nargin<4||nargin>6
    error('Too many/less input argument! ');
end
tiaoshi=0; 
%% 2��״̬����
[state,wl,wu]=DivideState(RE,sn);
if tiaoshi
%     disp(['��ʼstate= ',num2str(state)]);
    for i=1:length(wl)
        disp(['��',num2str(i),'��״̬�ķ�ΧΪ��[',num2str(wl(i)),...
            ' , ',num2str(wu(i)),']']);
    end
end
%% 3����״̬ת�Ƹ��ʾ���
[R1,R2,R3]=transmatrixV2(state,sn);
if tiaoshi
    disp('-------------- �������״̬ת�Ƹ��ʾ��� -------------');
    disp('R1 = ');disp(R1);
    disp('R2 = ');disp(R2);
    disp('R3 = ');disp(R3);
    disp('------------------------ end ----------------------');
    disp([' --- ���һ��������ݵ�״̬Ϊ��',num2str(state(end))]);
end
%% ����Ԥ��ֵ
% �������ֵ
for i=2:length(vervalue)
    switch state(i)
        case 1
            y(i)=((1+(wl(1)+wu(1))/2)*vervalue(i)); 
        case 2
            y(i)=((1+(wl(2)+wu(2))/2)*vervalue(i)); 
        case 3
            y(i)=((1+(wl(3)+wu(3))/2)*vervalue(i)); 
    end
end
if tiaoshi
    disp('-------------- ״̬������ֵ -------------- ');
    disp(['1+(wl(1)+wu(1))/2= ',num2str(1+(wl(1)+wu(1))/2)]);
    disp(['1+(wl(2)+wu(2))/2= ',num2str(1+(wl(2)+wu(2))/2)]);
    disp(['1+(wl(3)+wu(3))/2= ',num2str(1+(wl(3)+wu(3))/2)]);
    disp('----------------- end -------------------');
end
y(1)=realvalue(1);
% ******************* ����Ԥ��ֵ ******************************

% �ж�1����2����3��ת�ƺ��״̬
switch state(end)
    case 1
        v0=[1 0 0]; % ��ʼ������
        s1=v0*R1;   % 1��ת�ƺ��״̬
        s2=v0*R2;   % 2��ת�ƺ��״̬ 
        s3=v0*R3;   % 3��ת�ƺ��״̬
    case 2
        v0=[0 1 0]; % ��ʼ������
        s1=v0*R1;   % 1��ת�ƺ��״̬
        s2=v0*R2;   % 2��ת�ƺ��״̬
        s3=v0*R3;   % 3��ת�ƺ��״̬
        
    case 3
        v0=[0 0 1]; % ��ʼ������
        s1=v0*R1;   % 1��ת�ƺ��״̬
        s2=v0*R2;   % 2��ת�ƺ��״̬
        s3=v0*R3;   % 3��ת�ƺ��״̬        
end
% ����state����
state=[state,find(s1==max(s1),1,'first'),find(s2==max(s2),1,'first'),...
    find(s3==max(s3),1,'first')];
% ����δ��3����Ԥ��ֵ
for i=1:3
    switch state(length(state)-3+i)
        case 1
            y(end+1)=((1+(wl(1)+wu(1))/2)*verfore(i)); 
        case 2
            y(end+1)=((1+(wl(2)+wu(2))/2)*verfore(i)); 
        case 3
            y(end+1)=((1+(wl(3)+wu(3))/2)*verfore(i)); 
    end
end
if tiaoshi 
    disp([' --- Ԥ��ĺ�����״̬�ֱ�Ϊ��',num2str(state(end-2)),' , ',...
        num2str(state(end-1)),' , ',num2str(state(end))]);
    disp([' --- ���������Ԥ���3�����ݷֱ�Ϊ��',num2str(y(end-2:end))]);
end
% *************** ���¼���״̬ת�Ƹ��ʾ��� **************
nstate=state(end-3:end);
[R1,R2,R3]=transmatrixV2(nstate,sn);
if tiaoshi
    disp('-------------- Ԥ������״̬ת�Ƹ��ʾ��� -------------');
    disp('R1 = ');disp(R1);
    disp('R2 = ');disp(R2);
    disp('R3 = ');disp(R3);
    disp('------------------------ end ----------------------');
end

% *********************** ���¼���Ԥ��ֵ **********************
% �ж�1����2����3��ת�ƺ��״̬
switch state(end)
    case 1
        v0=[1 0 0]; % ��ʼ������
        s1=v0*R1;   % 1��ת�ƺ��״̬
        s2=v0*R2;   % 2��ת�ƺ��״̬
        s3=v0*R3;   % 3��ת�ƺ��״̬
    case 2
        v0=[0 1 0]; % ��ʼ������
        s1=v0*R1;   % 1��ת�ƺ��״̬
        s2=v0*R2;   % 2��ת�ƺ��״̬
        s3=v0*R3;   % 3��ת�ƺ��״̬
        
    case 3
        v0=[0 0 1]; % ��ʼ������
        s1=v0*R1;   % 1��ת�ƺ��״̬
        s2=v0*R2;   % 2��ת�ƺ��״̬
        s3=v0*R3;   % 3��ת�ƺ��״̬        
end
% ����state����
state=[state,find(s1==max(s1),1,'first'),find(s2==max(s2),1,'first'),...
    find(s3==max(s3),1,'first')];
% ����δ��3����Ԥ��ֵ
for i=1:3
    switch state(length(state)-3+i)
        case 1
            y(end+1)=((1+(wl(1)+wu(1))/2)*verfore(3+i)); 
        case 2
            y(end+1)=((1+(wl(2)+wu(2))/2)*verfore(3+i)); 
        case 3
            y(end+1)=((1+(wl(3)+wu(3))/2)*verfore(3+i)); 
    end
end
if tiaoshi
    disp([' --- Ԥ��ĺ�����״̬�ֱ�Ϊ��',num2str(state(end-2)),' , ',...
        num2str(state(end-1)),' , ',num2str(state(end))]);
    disp([' --- ���������Ԥ���3�����ݷֱ�Ϊ��',num2str(y(end-2:end))]);
end
%% ģ�;�������
% % ������
% relaterr=abs(realvalue-y(1:length(realvalue)))./realvalue;
% % ƽ��������
% mre=mean(relaterr)
% % �������ֵC
% C1=std(realvalue);
% C2=std(realvalue-y(1:length(realvalue)));
% C=C2/C1;
[Markov_re,mre,c,p]=CalculateGMAccuracy(realvalue,y);

if nargout==4
    varargout{1}=num2cell(y);
elseif nargout==5
    varargout{1}=num2cell(y);
    varargout{2}=num2cell(Markov_re);
end
if tiaoshi
%     disp('---------******------------');
%     disp(['ƽ��������Ϊ ',num2str(mre)]);
%     disp(['������Ϊ     ',num2str(c)]);
%     disp(['С������Ϊ   ',num2str(p)]);
    disp('-----------end-------------');
end
