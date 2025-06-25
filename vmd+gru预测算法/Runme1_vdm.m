clc;
clear;
close all;
warning off;
addpath(genpath(pwd));
rng('default')
%MATLAB/verilog/python/opencv/tensorflow/caffe/C/C++等算法仿真
%微信公众号：matlabworld
%如程序有报错，请将报错截图发邮件920619501@qq.com

% 加载数据文件
load data.mat;

% 设置采样频率（单位：小时），即相邻两个采样点之间的时间间隔为1小时
Fs = 1;

% 计算采样周期（单位：小时），采样周期是采样频率的倒数
Ts = 1/Fs;

% 获取数据长度，即采样点的总数
Len= length(dat);

% 生成时间序列向量，从0开始，以采样周期为间隔，直到最后一个采样点
t  = (0:Len-1)*Ts;

% 设置采样起始位置（单位：小时），从第0小时开始采样
STA= 0;
%--------- VMD分解的相关参数设置 ---------------
% 带宽约束参数，控制分解后各模态的带宽，值越大带宽越窄
alpha = 2500;
% 噪声容限参数，设置为0表示不进行严格的保真度约束
tau   = 0;

% 分解的模态数，即希望将原始信号分解为多少个固有模态函数(IMF)
K     = 5;
% 是否保留直流分量，0表示不保留
DC    = 0;
% 初始化中心频率的方法，1表示均匀初始化
init  = 1;
% 收敛容差，当迭代误差小于此值时停止迭代
tol   = 1e-7;

%--------------- 执行VMD分解算法 ---------------------------
% 调用VMD函数对数据进行分解
% u: 分解得到的各模态函数矩阵，每行代表一个IMF
% u_hat: 各模态函数的频谱
% omega: 各模态函数的中心频率
[datu, u_hat, omega] = VMD(dat(:,end), alpha, tau, K, DC, init, tol);



save datavdm.mat datu dat
