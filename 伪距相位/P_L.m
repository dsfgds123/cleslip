clear all;close all;
format long g;
addpath(genpath('C:\Users\tjc\Desktop\论文\周跳\程序\周跳'));
load('C:\Users\tjc\Desktop\论文\周跳\程序\matlab界面\data\图书馆\1h_base_kine-gps_bds-302_O.mat');
obs=data.body.data;
len=length(obs);
prn=1;%要画图的卫星号
prn_start=1;%各系统起始卫星号,保存数据的时候自己设的,看GPS就是1，北斗就是33,glonass就是68
lamda=299792458.0/1.57542E9;%L1波长,根据卫星系统改波长
k=1;
M=20;
for i=1500:3000
    for j=1:obs(i).SatSumAll
        if (obs(i).SatCode(j)-prn_start+1)==prn
            P(1,k)=obs(i).Obs_RangeC(1,j);%这是L1伪距,   obs(i).Obs_RangeC(2,j)是L2
            L(1,k)=obs(i).Obs_FreL(1,j);%载波相位
            D(1,k)=obs(i).dopp(1,j);%多普勒
            time(k,:)=obs(i).obstime;
            if k>1
                P_smooth(1,k)=P(1,k)/M+(M-1)/M*(P(1,k-1)-lamda*((D(1,k)+D(1,k-1))/2));
            else
                P_smooth(1,k)=P(1,k);
            end
            k=k+1;
        end
    end
end

csL=addcs(L,1,100,1);%加完周跳后的载波相位,这个函数的第二个参数是周跳大小（正常的周跳看不出啥变换，夸张离谱的能看出来）,第三个参数是发生周跳的历元,第四个参数是发生周跳的频点
csL=addcs(csL,3,300,1);
csL=addcs(csL,5,500,1);
csL=addcs(csL,8,600,1);
csL=addcs(csL,10,1000,1);
x=1:1501;
[data1,data2,s1]=P_L_method(P,csL,lamda);
data1=[0,data1];
% data1=STPIR_PL_method(P,csL,lamda);
% data1=[0,0,data1];
% figure;
% plot(L);hold on
% plot(csL);
% legend('原始载波相位','加入周跳后');
figure;
% plot(x(1:99),data1(1:99),'b',);hold on;
plot_cs(data1);%最基础的伪距减相位法探测周跳
plot(x(100),data1(100),'o','color','r');hold on;
plot(x(300),data1(300),'o','color','r');hold on;
plot(x(500),data1(500),'o','color','r');hold on;
plot(x(600),data1(600),'o','color','r');hold on;
plot(x(1000),data1(1000),'o','color','r');hold on;
title('G01');