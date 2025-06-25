function [mre,c,p,varargout]=GreyMarkov3StepV2(realvalue,vervalue,verfore,RE,varargin)
%% 灰色马尔科夫模型，进行残差修正后用3步转移概率求预测值
% 建模步骤：1、计算Verhulst预测值及残差（相对误差）2、划分状态 3、状态转移概率矩阵
% 4、计算预测值
% input：
%          realvalue - 真实值序列
%          vervalue  - Verhulst模型拟合值
%          verfore   - Verhulst模型预测值
%          RE        - Verhulst模型预测相对误差
%          sn        - 划分状态的个数 state number
% output：
%          mre - 组合模型平均相对误差
%          c   - 组合模型后验差比
%          p   - 组合模型小误差概率
% modify on 2018/10/30
% -------------------------------------------------------------------------------

if nargout>5
    error('Too many output arguments!');
end
if ~isempty(find(isinf(RE),1))
    error('参数RE中存在INF元素！');
end
if nargin==4
    sn=3; % 设置默认状态个数
    tiaoshi=1; % 设置调试信息默认不显示
elseif nargin==5
    tiaoshi=1;
elseif nargin<4||nargin>6
    error('Too many/less input argument! ');
end
tiaoshi=0; 
%% 2、状态划分
[state,wl,wu]=DivideState(RE,sn);
if tiaoshi
%     disp(['初始state= ',num2str(state)]);
    for i=1:length(wl)
        disp(['第',num2str(i),'个状态的范围为：[',num2str(wl(i)),...
            ' , ',num2str(wu(i)),']']);
    end
end
%% 3、求状态转移概率矩阵
[R1,R2,R3]=transmatrixV2(state,sn);
if tiaoshi
    disp('-------------- 拟合数据状态转移概率矩阵 -------------');
    disp('R1 = ');disp(R1);
    disp('R2 = ');disp(R2);
    disp('R3 = ');disp(R3);
    disp('------------------------ end ----------------------');
    disp([' --- 最后一个拟合数据的状态为：',num2str(state(end))]);
end
%% 计算预测值
% 计算拟合值
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
    disp('-------------- 状态区间中值 -------------- ');
    disp(['1+(wl(1)+wu(1))/2= ',num2str(1+(wl(1)+wu(1))/2)]);
    disp(['1+(wl(2)+wu(2))/2= ',num2str(1+(wl(2)+wu(2))/2)]);
    disp(['1+(wl(3)+wu(3))/2= ',num2str(1+(wl(3)+wu(3))/2)]);
    disp('----------------- end -------------------');
end
y(1)=realvalue(1);
% ******************* 计算预测值 ******************************

% 判断1步、2步、3步转移后的状态
switch state(end)
    case 1
        v0=[1 0 0]; % 初始行向量
        s1=v0*R1;   % 1步转移后的状态
        s2=v0*R2;   % 2步转移后的状态 
        s3=v0*R3;   % 3步转移后的状态
    case 2
        v0=[0 1 0]; % 初始行向量
        s1=v0*R1;   % 1步转移后的状态
        s2=v0*R2;   % 2步转移后的状态
        s3=v0*R3;   % 3步转移后的状态
        
    case 3
        v0=[0 0 1]; % 初始行向量
        s1=v0*R1;   % 1步转移后的状态
        s2=v0*R2;   % 2步转移后的状态
        s3=v0*R3;   % 3步转移后的状态        
end
% 更新state向量
state=[state,find(s1==max(s1),1,'first'),find(s2==max(s2),1,'first'),...
    find(s3==max(s3),1,'first')];
% 计算未来3个的预测值
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
    disp([' --- 预测的后三个状态分别为：',num2str(state(end-2)),' , ',...
        num2str(state(end-1)),' , ',num2str(state(end))]);
    disp([' --- 由拟合数据预测的3个数据分别为：',num2str(y(end-2:end))]);
end
% *************** 重新计算状态转移概率矩阵 **************
nstate=state(end-3:end);
[R1,R2,R3]=transmatrixV2(nstate,sn);
if tiaoshi
    disp('-------------- 预测数据状态转移概率矩阵 -------------');
    disp('R1 = ');disp(R1);
    disp('R2 = ');disp(R2);
    disp('R3 = ');disp(R3);
    disp('------------------------ end ----------------------');
end

% *********************** 重新计算预测值 **********************
% 判断1步、2步、3步转移后的状态
switch state(end)
    case 1
        v0=[1 0 0]; % 初始行向量
        s1=v0*R1;   % 1步转移后的状态
        s2=v0*R2;   % 2步转移后的状态
        s3=v0*R3;   % 3步转移后的状态
    case 2
        v0=[0 1 0]; % 初始行向量
        s1=v0*R1;   % 1步转移后的状态
        s2=v0*R2;   % 2步转移后的状态
        s3=v0*R3;   % 3步转移后的状态
        
    case 3
        v0=[0 0 1]; % 初始行向量
        s1=v0*R1;   % 1步转移后的状态
        s2=v0*R2;   % 2步转移后的状态
        s3=v0*R3;   % 3步转移后的状态        
end
% 更新state向量
state=[state,find(s1==max(s1),1,'first'),find(s2==max(s2),1,'first'),...
    find(s3==max(s3),1,'first')];
% 计算未来3个的预测值
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
    disp([' --- 预测的后三个状态分别为：',num2str(state(end-2)),' , ',...
        num2str(state(end-1)),' , ',num2str(state(end))]);
    disp([' --- 由拟合数据预测的3个数据分别为：',num2str(y(end-2:end))]);
end
%% 模型精度评定
% % 相对误差
% relaterr=abs(realvalue-y(1:length(realvalue)))./realvalue;
% % 平均相对误差
% mre=mean(relaterr)
% % 均方差比值C
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
%     disp(['平均相对误差为 ',num2str(mre)]);
%     disp(['后验差比为     ',num2str(c)]);
%     disp(['小误差概率为   ',num2str(p)]);
    disp('-----------end-------------');
end
