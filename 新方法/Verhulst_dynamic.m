function [forecast,err,varargout]=Verhulst_dynamic(x,L,PL)
%% 2018/4/22 build �Ľ���Verhulstģ�ͣ��Ի�����������̬����a��b��Ԥ�����ݵĸ���Ϊ PL
% function [forecast,mre,c,p]=Verhulst_dynamic(x,L,PL)
% forecast: Ԥ��ֵ
% err�� Ԥ��������
% mre: ƽ��������
% c  ��������
% p  ��С������
% x�� �������ݣ���������ʽ
% L�� �������ڳ���
% PL��Ԥ�����ݸ���
% 5/2�޸ģ� ���ۼ����С������������С�B��YN��a��b�ļ�������ƶ���ѭ���⡣
% 5/6�޸ģ� ��̬����a b�㷨��ɣ�Ч��������
% 10/27�޸ģ� ����һ���������PL�����Ӷ����������Ĭ������
if nargout>3
    error('Too many Output arguements!');
end
% if ~isempty(find(diff(x)<0,1))   
%     error('�������в��ǵ���������');
% end
switch nargin
    case 1
        L=3;PL=1;
    case 2
        PL=1;
end

%% �ɳ�ʼ���ݼ���a��b
xx=x;
n=length(x);
looplength=n+PL;
for jj=1:n
    s1(jj)=sum(x(1:jj));   % ����һ���ۼ����� cumsum����Ҳ��ʵ�ִ˹���
    if jj>=2
        z1(jj-1)=0.5*(s1(jj)+s1(jj-1));   % ���������������
    end
end
% ��������B��YN
B=[-z1' (z1.^2)'];
YN=x(2:end)';
for ii=1:n-1-L+1 
    Bi=B(ii:ii+L-1,:);
    YNi=YN(ii:ii+L-1);
    AB=inv(Bi'*Bi)*Bi'*YNi;
    a(ii)=AB(1);
    b(ii)=AB(2);
end 
%% ���ݶ�̬����
for i=1:looplength 
%     for j=2:L
%         z1(j-1)=0.5*(s1(i-1+j)+s1(i-1+j-1));  % ���������������
%         Z_1(i,j-1)=z1(j-1);  % �洢z1ֵ
%     end
%     % ��������B��YN
%     B=[-z1' (z1.^2)'];
%     YN=x(i-1+2:i-1+L)';
%     AB=inv(B'*B)*B'*YN;
%     a=AB(1);
%     b=AB(2);
%     save_a(i)=a;    % save a,b
%     save_b(i)=b;
    if i<=n-L+1     % ��ǰn-1�����ݽ������
        if i==n-L+1
            a(i)=a(n-L);
            b(i)=b(n-L);
        end
        % ����ʱ����Ӧ����
        for k=0:L-1
            s1_tr(k+1)=a(i)*s1(i)/(b(i)*s1(i)+(a(i)-b(i)*s1(i))*exp(a(i)*k));
        end
        % �ۼ��õ���ԭֵ����
        for k=1:L-1
            s0(k+1)=s1_tr(k+1)-s1_tr(k);
        end
        % 2018/11/1 modify ����һ�����ݲ��䵽��ԭֵ������
        s0=[x(i) s0];
        % ����ԭֵ���д�ŵ�������
%         for k=1:L-1
%             ss0(i,k+i)=s0(k+1);
%         end
        for k=1:L
            ss0(i,k+i)=s0(k);
        end
    else     % �Ե�n��������ϲ�Ԥ��L-2������
%         length(a)
%         length(b)
        for k=0:L-1
            % ����ʱ����Ӧ����
            s1_tr(k+1)=a(end)*s1(i)/(b(end)*s1(i)+(a(end)-b(end)*s1(i))*exp(a(end)*k));
            if k>=1
               s0(k+1)=s1_tr(k+1)-s1_tr(k);  % �ۼ��õ���ԭֵ����
%                ss0(i,k+i)=s0(k+1);             % ����ԭֵ���д�ŵ�������
            end
            s0=[x(i) s0];
            ss0(i,k+i+1)=s0(k+1);             % ����ԭֵ���д�ŵ�������
        end
        % �ع��ۼ����� �� ԭʼ��������x
        s1=[s1 s1_tr(end)];
        x=[x s0(end)];
        % ���¼��������������
        for jj=i:i+L-1
            z1(jj-1)=0.5*(s1(jj)+s1(jj-1));
        end    
        % �ع�B��YN
        R_B=[-z1(i-1:i-1+L-1)' (z1(i-1:i-1+L-1).^2)'];
        R_YN=x(i:i+L-1)';
        % ���¼���a��b
        AB=inv(R_B'*R_B)*R_B'*R_YN;
        a(i)=AB(1);
        b(i)=AB(2);
    end 
end  

%% ȡ��Ԥ��ֵ
[row,col]=size(ss0);
forec=zeros(1,col-1); 
for i1=2:col
    forec(i1-1)=sum(ss0(:,i1))/numel(find(ss0(:,i1))); % ��ÿ�еķ�0���ݵ�ƽ��ֵ
%       if i1<=row  % ȡ�Խ������ݼ����һ������ ������ƽ��������ͺ������Դ�
%         forec(i1-1)=ss0(i1-1,i1);
%       else
%         forec(i1-1)=ss0(row,i1);
%       end   
end
 forecast = forec(1:looplength);

 %% ��Ԥ�����   
if length(forecast)>=n
    err=abs(forecast(1:n)-xx)./xx;
else
    err=abs(forecast-xx(1:length(forecast)))./xx(1:length(forecast));
end
% ƽ��������
mre=mean(err);
% ������
c1=sqrt(1/length(xx)*sum((xx-mean(xx)).^2)); % ��׼��
cancha=xx-forecast(1:length(xx));
c2=sqrt(1/length(cancha)*sum((cancha-mean(cancha)).^2)); % ��׼��
c=c2/c1;
% С������
tmp=abs(cancha-mean(cancha));
sn=find(tmp<0.6745*c1);
p=length(sn)/length(err);
% �����ʾ
% disp('-------��̬ģ�;���---------');
% disp(['�������ڳ���Ϊ ',num2str(L)]);
% disp(['Ԥ�����ݸ���Ϊ ',num2str(PL)]);
% disp(['ƽ��������Ϊ ',num2str(mre)]);
% disp(['������Ϊ     ',num2str(c)]);
% disp(['С������Ϊ   ',num2str(p)]);
% disp('---------------------------');  
if nargout==3
    varargout{1}=num2cell(mre);
    varargout{2}=num2cell(c);
    varargout{3}=num2cell(p);
elseif nargout==2
    varargout{1}=num2cell(mre);
    varargout{2}=num2cell(c);    
elseif nargout==1
    varargout{1}=num2cell(mre);
end
