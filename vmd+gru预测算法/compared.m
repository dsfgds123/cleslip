clc;
clear;
close all;
warning off;
addpath(genpath(pwd));
rng('default')
%MATLAB/verilog/python/opencv/tensorflow/caffe/C/C++等算法仿真
%微信公众号：matlabworld
 
 
 
figure;
subplot(311)
load R1gru.mat 
plot(T_train)
hold on
plot(TNpre1)
legend('真实数据','GRU预测数据');rmse1a=rmse1;
title(['GRU预测误差:',num2str(rmse1)]);

subplot(312)
load R2vdmlgru.mat
plot(T_train)
hold on
plot(TNpre1)
legend('真实数据','VDM-GRU预测数据');
title(['VDM-GRU预测误差:',num2str(rmse1)]);rmse1b=rmse1;

subplot(313)
load R3psovdmlgru.mat
plot(T_train)
hold on
plot(TNpre1)
legend('真实数据','PSO-VDM-GRU预测数据');
title(['PSO-VDM-GRU预测误差:',num2str(rmse1)]);rmse1c=rmse1;
 


figure;
bar([rmse1a,rmse1b,rmse1c]);
xlabel('1:GRU,  2:VDM-GRU,  3:PSO-VDM-GRU');
ylabel('预测误差');


%%试集结果
figure
load R1gru.mat 
plotregression(T_test,TNpre2,['GRU预测回归']);


figure
load R2vdmlgru.mat 
plotregression(T_testsum,TNpre2sum,['VDM-GRU预测回归']);

figure
load R3psovdmlgru.mat 
plotregression(T_testsum,TNpre2sum,['PSO-VDM-GRU预测回归']);