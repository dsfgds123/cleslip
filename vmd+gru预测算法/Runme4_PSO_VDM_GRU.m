clc;
clear;
close all;
warning off;
addpath(genpath(pwd));
rng('default')
%MATLAB/verilog/python/opencv/tensorflow/caffe/C/C++等算法仿真
%微信公众号：matlabworld
%如程序有报错，请将报错截图发邮件920619501@qq.com


load datavdm.mat

global datu;
global imf;
global Rc;
global dims;
global dat;
 




Npeop        = 10;  %搜索数量
Iter         = 10; %迭代次数
DD           = 2; %搜索空间维数
 
%每个变量的取值范围
tmps(1,:)    = [10,100]; %
tmps(2,:)    = [0.0001;0.05]; %
 

%学习因子
c1    = 2;                   
c2    = 2;             
%用线性递减因子粒子群算法
Wmax  = 1; %惯性权重最大值
Wmin  = 0.8; %惯性权重最小值

tmps     = tmps';
xv       = rand(Npeop,2*DD); 

for d=1:DD
    xv(:,d)     = xv(:,d)*(tmps(2,d)-tmps(1,d))+tmps(1,d);  
    xv(:,DD+d)= (2*xv(:,DD+d)-1 )*(tmps(2,d)-tmps(1,d))*0.2;
end

%位置%速度
x1     = xv(:,1:DD);
v1     = xv(:,DD+1:2*DD);
p1     = x1;
pbest1 = ones(Npeop,1);
for i=1:Npeop
    i
    pbest1(i)=func_obj(x1(i,:));
end
gbest1=min(pbest1);
lab=find(min(pbest1)==pbest1);
g1=x1(lab,:);
gb1=ones(1,Iter);

for i=1:Iter
    i
    for j=1:Npeop
        rng(i+j)
        if func_obj(x1(j,:))<pbest1(j)
           p1(j,:)   = x1(j,:);%变量
           pbest1(j) = func_obj(x1(j,:));
        end
        if pbest1(j)<gbest1
           g1     = p1(j,:);%变量
           gbest1 = pbest1(j);
        end
        
        v1(j,:) = 0.8*v1(j,:)+c1*rand*(p1(j,:)-x1(j,:))+c2*rand*(g1-x1(j,:));
        x1(j,:) = x1(j,:)+v1(j,:); 
         
        for k=1:DD
            if x1(j,k) >= tmps(2,k)
               x1(j,k) = tmps(2,k);
            end
            if x1(j,k) <= tmps(1,k)
               x1(j,k) = tmps(1,k);
            end
        end

        for k=1:DD
            if v1(j,k) >= tmps(2,k)/2
               v1(j,k) =  tmps(2,k)/2;
            end
            if v1(j,k) <= tmps(1,k)/2
               v1(j,k) =  tmps(1,k)/2;
            end
        end

    end
end


X     = g1;

Nlayer = floor(X(1))+1;
LR     = X(2);


imf = datu;
Rc  = size(imf,1);
dims= size(dat,2);
%分量建模
for d=1:Rc
    X_imf = [dat(:,1:end-1) imf(d,:)'];
    [T_train,T_test,Pxtrain,Txtrain,Pxtest,Txtest,Norm_I,Norm_O,indim,outdim]=func_process2(X_imf,dims);

    %LSTM网络，
    layers = [ ...
        sequenceInputLayer(indim)             
        gruLayer(Nlayer)                      
        reluLayer                           
        fullyConnectedLayer(outdim)        
        regressionLayer];
    
    %参数设置
    options = trainingOptions('adam', ...                 % 优化算法Adam
        'MaxEpochs', 200, ...                             % 最大训练次数
        'GradientThreshold', 1, ...                       % 梯度阈值
        'InitialLearnRate', LR, ...                    % 初始学习率
        'LearnRateSchedule', 'piecewise', ...             % 学习率调整
        'LearnRateDropPeriod', 60, ...                   
        'LearnRateDropFactor',0.2, ...                  
        'L2Regularization', 0.01, ...                     % 正则化参数
        'ExecutionEnvironment', 'cpu',...                 % 训练环境
        'Verbose', 0, ...                                 % 关闭优化过程
        'Plots', 'training-progress');                    % 画出曲线
    
    %训练
    [net,INFO] = trainNetwork(Pxtrain, Txtrain, layers, options);
    Rerr = INFO.TrainingRMSE;
    Rlos = INFO.TrainingLoss;
    %预测
    Tpre1  = predict(net, Pxtrain); 
    Tpre2  = predict(net, Pxtest); 
    
    %反归一化
    TNpre1 = mapminmax('reverse', Tpre1, Norm_O); 
    TNpre2 = mapminmax('reverse', Tpre2, Norm_O); 
    %数据格式转换
    TNpre1s(d,:)  = cell2mat(TNpre1);
    TNpre2s(d,:)  = cell2mat(TNpre2);
    T_trains(d,:) = T_train;
    T_tests(d,:)  = T_test;
    Rerrs(d,:)=Rerr;
    Rloss(d,:)=Rlos;
end

TNpre1sum =sum(TNpre1s);
TNpre2sum =sum(TNpre2s);
T_trainsum=sum(T_trains);
T_testsum =sum(T_tests);


%计算误差
error1=T_trainsum-TNpre1sum;  
error2=T_testsum-TNpre2sum;  
rmse1=sqrt(mean(error1.^2))
rmse2=sqrt(mean(error2.^2))


save R3psovdmlgru.mat TNpre2sum T_testsum T_trainsum TNpre1sum Rerrs Rloss rmse1 rmse2