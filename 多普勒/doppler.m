clear all;close all;
format long g;
addpath(genpath('C:\Users\tjc\Desktop\论文\周跳'));
% load('G:\寒假资料\大论文程序\周跳\数据\3系统\CO01155a_19O','data');
% obs=data.body.data;
% clear data
load('C:\Users\tjc\Desktop\论文\周跳\程序\周跳\多普勒\base_rov_data.mat','ObsODat_rover');
obs=ObsODat_rover;
clear ObsODat_rover
len=length(obs);
prn=1;%1;%要画图的卫星号
prn_start=1;%各系统起始卫星号,保存数据的时候自己设的,看GPS就是1，北斗就是33,glonass就是68
if prn<=32
    lamda=299792458.0/1.57542E9;%L1波长,根据卫星系统改波长
    str_t=['G',num2str(prn,'%02d')];
else
    lamda=299792458.0/1.561098E9;
    str_t=['C',num2str(prn-32,'%02d')];
end
k=1;
s=2200;%开始历元
e=3199;%结束历元
for i=s:e
    for j=1:obs(i).SatSumAll
        if (obs(i).SatCode(j)-prn_start+1)==prn
%             P(1,k)=obs(i).Obs_RangeC(1,j);%这是L1伪距,   obs(i).Obs_RangeC(2,j)是L2
            L(1,k)=obs(i).Obs_FreL(1,j);%载波相位
            D(1,k)=obs(i).dopp(1,j);%多普勒
            time(k,:)=obs(i).obstime;
            k=k+1;
        end
    end
end
%% 采样间隔1s
csL=addcs(L,1,100,1);
csL=addcs(csL,3,300,1);
csL=addcs(csL,5,500,1);
data1=dopp_method(csL,D,1);
data1=[0,data1];
figure;
subplot(311);
plot_cs(data1,[-5 5],-5:2:5); hold on;%
x=1:length(data1);
plot(x(100),data1(100),'o','color','r');hold on;
plot(x(300),data1(300),'o','color','r');hold on;
plot(x(500),data1(500),'o','color','r');hold on;
% th1=3*std(data1)*ones(1,length(data1))+0.1;
% plot(th1);hold on;
% plot(-th1);
% legend('周跳探测量','阈值上限','阈值下限');
legend('周跳探测量');
title('采样间隔1s');
%% 采样间隔5s
samp_L2=samp(L,5);
samp_D2=samp(D,5);
cs_sampL2=addcs(samp_L2,1,20,1);
cs_sampL2=addcs(cs_sampL2,3,60,1);
cs_sampL2=addcs(cs_sampL2,5,100,1);
data3=dopp_method(cs_sampL2,samp_D2,5);
data3=[0,data3];
subplot(312);
plot_cs(data3,[-7 7],-5:2:5);hold on;
x=1:length(data3);
plot(x(20),data3(20),'o','color','r');hold on;
plot(x(60),data3(60),'o','color','r');hold on;
plot(x(100),data3(100),'o','color','r');hold on;
% th3=3*std(data3)*ones(1,length(data3))+0.1;
% plot(th3);hold on;
% plot(-th3);
% legend('周跳探测量','阈值上限','阈值下限');
legend('周跳探测量');
title('采样间隔5s');
%% 采样间隔10s
samp_L=samp(L,10);
samp_D=samp(D,10);
cs_sampL=addcs(samp_L,1,10,1);
cs_sampL=addcs(cs_sampL,3,30,1);
cs_sampL=addcs(cs_sampL,5,50,1);
data2=dopp_method(cs_sampL,samp_D,10);
data2=[0,data2];
subplot(313);
plot_cs(data2,[-15 15],-15:5:15);
x=1:length(data2);
plot(x(10),data2(10),'o','color','r');hold on;
plot(x(30),data2(30),'o','color','r');hold on;
plot(x(50),data2(50),'o','color','r');hold on;
% th2=3*std(data2)*ones(1,length(data2))+0.1;
% plot(th2);hold on;
% plot(-th2);
% legend('周跳探测量','阈值上限','阈值下限');
legend('周跳探测量');
title('采样间隔10s');