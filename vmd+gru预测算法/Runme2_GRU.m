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

[T_train,T_test,Pxtrain,Txtrain,Pxtest,Txtest,Norm_I,Norm_O,indim,outdim]=func_process(dat);

%gru网络，
layers = [ ...
    sequenceInputLayer(indim)             
    gruLayer(30)                      
    reluLayer                           
    fullyConnectedLayer(outdim)        
    regressionLayer];

%参数设置
options = trainingOptions('adam', ...                 % 优化算法Adam
    'MaxEpochs', 2000, ...                             % 最大训练次数
    'GradientThreshold', 1, ...                       % 梯度阈值
    'InitialLearnRate', 0.005, ...                    % 初始学习率
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
TNpre1 = cell2mat(TNpre1);
TNpre2 = cell2mat(TNpre2);

%计算误差
error1=T_train-TNpre1';  
error2=T_test-TNpre2';  
rmse1=sqrt(mean(error1.^2))
rmse2=sqrt(mean(error2.^2))

save R1gru.mat TNpre2 T_test T_train TNpre1 Rerr Rlos rmse1 rmse2

 


 



