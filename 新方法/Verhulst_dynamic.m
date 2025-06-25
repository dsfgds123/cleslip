function [forecast,err,varargout]=Verhulst_dynamic(x,L,PL)
%% 2018/4/22 build 改进型Verhulst模型，以滑动窗口来动态更新a，b，预测数据的个数为 PL
% function [forecast,mre,c,p]=Verhulst_dynamic(x,L,PL)
% forecast: 预测值
% err： 预测相对误差
% mre: 平均相对误差
% c  ：后验差比
% p  ：小误差概率
% x： 输入数据，行向量形式
% L： 滑动窗口长度
% PL：预测数据个数
% 5/2修改： 将累加序列、紧邻生成序列、B、YN，a，b的计算过程移动到循环外。
% 5/6修改： 动态更新a b算法完成，效果还可以
% 10/27修改： 增加一个输入变量PL，增加对输入变量的默认设置
if nargout>3
    error('Too many Output arguements!');
end
% if ~isempty(find(diff(x)<0,1))   
%     error('输入序列不是单调递增！');
% end
switch nargin
    case 1
        L=3;PL=1;
    case 2
        PL=1;
end

%% 由初始数据计算a，b
xx=x;
n=length(x);
looplength=n+PL;
for jj=1:n
    s1(jj)=sum(x(1:jj));   % 计算一次累加序列 cumsum函数也可实现此功能
    if jj>=2
        z1(jj-1)=0.5*(s1(jj)+s1(jj-1));   % 计算紧邻生成序列
    end
end
% 构建矩阵B，YN
B=[-z1' (z1.^2)'];
YN=x(2:end)';
for ii=1:n-1-L+1 
    Bi=B(ii:ii+L-1,:);
    YNi=YN(ii:ii+L-1);
    AB=inv(Bi'*Bi)*Bi'*YNi;
    a(ii)=AB(1);
    b(ii)=AB(2);
end 
%% 数据动态更新
for i=1:looplength 
%     for j=2:L
%         z1(j-1)=0.5*(s1(i-1+j)+s1(i-1+j-1));  % 计算紧邻生成序列
%         Z_1(i,j-1)=z1(j-1);  % 存储z1值
%     end
%     % 构建矩阵B，YN
%     B=[-z1' (z1.^2)'];
%     YN=x(i-1+2:i-1+L)';
%     AB=inv(B'*B)*B'*YN;
%     a=AB(1);
%     b=AB(2);
%     save_a(i)=a;    % save a,b
%     save_b(i)=b;
    if i<=n-L+1     % 对前n-1个数据进行拟合
        if i==n-L+1
            a(i)=a(n-L);
            b(i)=b(n-L);
        end
        % 计算时间响应序列
        for k=0:L-1
            s1_tr(k+1)=a(i)*s1(i)/(b(i)*s1(i)+(a(i)-b(i)*s1(i))*exp(a(i)*k));
        end
        % 累减得到还原值序列
        for k=1:L-1
            s0(k+1)=s1_tr(k+1)-s1_tr(k);
        end
        % 2018/11/1 modify 将第一个数据补充到还原值序列中
        s0=[x(i) s0];
        % 将还原值序列存放到数组中
%         for k=1:L-1
%             ss0(i,k+i)=s0(k+1);
%         end
        for k=1:L
            ss0(i,k+i)=s0(k);
        end
    else     % 对第n个数据拟合并预测L-2个数据
%         length(a)
%         length(b)
        for k=0:L-1
            % 计算时间响应序列
            s1_tr(k+1)=a(end)*s1(i)/(b(end)*s1(i)+(a(end)-b(end)*s1(i))*exp(a(end)*k));
            if k>=1
               s0(k+1)=s1_tr(k+1)-s1_tr(k);  % 累减得到还原值序列
%                ss0(i,k+i)=s0(k+1);             % 将还原值序列存放到数组中
            end
            s0=[x(i) s0];
            ss0(i,k+i+1)=s0(k+1);             % 将还原值序列存放到数组中
        end
        % 重构累加序列 和 原始数据序列x
        s1=[s1 s1_tr(end)];
        x=[x s0(end)];
        % 重新计算紧邻生成序列
        for jj=i:i+L-1
            z1(jj-1)=0.5*(s1(jj)+s1(jj-1));
        end    
        % 重构B，YN
        R_B=[-z1(i-1:i-1+L-1)' (z1(i-1:i-1+L-1).^2)'];
        R_YN=x(i:i+L-1)';
        % 重新计算a，b
        AB=inv(R_B'*R_B)*R_B'*R_YN;
        a(i)=AB(1);
        b(i)=AB(2);
    end 
end  

%% 取出预测值
[row,col]=size(ss0);
forec=zeros(1,col-1); 
for i1=2:col
    forec(i1-1)=sum(ss0(:,i1))/numel(find(ss0(:,i1))); % 求每列的非0数据的平均值
%       if i1<=row  % 取对角线数据及最后一行数据 此种求法平均相对误差和后验差比略大
%         forec(i1-1)=ss0(i1-1,i1);
%       else
%         forec(i1-1)=ss0(row,i1);
%       end   
end
 forecast = forec(1:looplength);

 %% 求预测误差   
if length(forecast)>=n
    err=abs(forecast(1:n)-xx)./xx;
else
    err=abs(forecast-xx(1:length(forecast)))./xx(1:length(forecast));
end
% 平均相对误差
mre=mean(err);
% 后验差比
c1=sqrt(1/length(xx)*sum((xx-mean(xx)).^2)); % 标准差
cancha=xx-forecast(1:length(xx));
c2=sqrt(1/length(cancha)*sum((cancha-mean(cancha)).^2)); % 标准差
c=c2/c1;
% 小误差概率
tmp=abs(cancha-mean(cancha));
sn=find(tmp<0.6745*c1);
p=length(sn)/length(err);
% 结果显示
% disp('-------动态模型精度---------');
% disp(['滑动窗口长度为 ',num2str(L)]);
% disp(['预测数据个数为 ',num2str(PL)]);
% disp(['平均相对误差为 ',num2str(mre)]);
% disp(['后验差比为     ',num2str(c)]);
% disp(['小误差概率为   ',num2str(p)]);
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
