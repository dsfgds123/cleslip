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


%������ģ
for d=1:Rc
    X_imf = [dat(:,1:end-1) imf(d,:)'];
    [T_train,T_test,Pxtrain,Txtrain,Pxtest,Txtest,Norm_I,Norm_O,indim,outdim]=func_process2(X_imf,dims);

    %LSTM���磬
    layers = [ ...
        sequenceInputLayer(indim)             
        gruLayer(Nlayer)                      
        reluLayer                           
        fullyConnectedLayer(outdim)        
        regressionLayer];
    
    %��������
    options = trainingOptions('adam', ...                 % �Ż��㷨Adam
        'MaxEpochs', 200, ...                             % ���ѵ������
        'GradientThreshold', 1, ...                       % �ݶ���ֵ
        'InitialLearnRate', LR, ...                    % ��ʼѧϰ��
        'LearnRateSchedule', 'piecewise', ...             % ѧϰ�ʵ���
        'LearnRateDropPeriod', 60, ...                   
        'LearnRateDropFactor',0.2, ...                  
        'L2Regularization', 0.01, ...                     % ���򻯲���
        'ExecutionEnvironment', 'cpu',...                 % ѵ������
        'Verbose', 0, ...                                 % �ر��Ż�����
        'Plots', 'none');                    % ��������
    
    %ѵ��
    [net,INFO] = trainNetwork(Pxtrain, Txtrain, layers, options);
    Rerr = INFO.TrainingRMSE;
    Rlos = INFO.TrainingLoss;
    %Ԥ��
    Tpre1  = predict(net, Pxtrain); 
    Tpre2  = predict(net, Pxtest); 
    
    %����һ��
    TNpre1 = mapminmax('reverse', Tpre1, Norm_O); 
    TNpre2 = mapminmax('reverse', Tpre2, Norm_O); 
    %���ݸ�ʽת��
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


%�������
error1=T_trainsum-TNpre1sum;  
error2=T_testsum-TNpre2sum;  
rmse1=sqrt(mean(error1.^2));
rmse2=sqrt(mean(error2.^2));


 
%FPGA/MATLAB/simulink����
%΢�Ź��ںţ�matlabworld
%�������䣺920619501@qq.com