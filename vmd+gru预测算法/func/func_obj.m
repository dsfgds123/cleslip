function [rmse1] = func_obj(X);

global datu;
global imf;
global Rc;
global dims;
global dat;

imf = datu;
Rc  = size(imf,1);
dims= size(dat,2);

Nlayer = floor(X(1))+1;
LR     = X(2);


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
        'Plots', 'none');                    % 画出曲线
    
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
rmse1=sqrt(mean(error1.^2));
rmse2=sqrt(mean(error2.^2));


 
%FPGA/MATLAB/simulink仿真
%微信公众号：matlabworld
%作者邮箱：920619501@qq.com