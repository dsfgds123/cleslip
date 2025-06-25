clear all;close all;
format long g;
addpath(genpath('C:\Users\tjc\Desktop\论文\周跳'));
load('C:\Users\tjc\Desktop\论文\周跳\程序\周跳\新方法\base_rov_data.mat','ObsODat_base','ObsODat_rover');
len=length(ObsODat_rover);
prn=1;%要画图的卫星号
prn_start=1;%各系统起始卫星号,保存数据的时候自己设的,看GPS就是1，北斗就是33,glonass就是68
lamda=299792458.0/1.57542E9;%L1波长,根据卫星系统改波长
k=1;
for i=1500:3000
    for j=1:ObsODat_base(i).SatSumAll
        if (ObsODat_base(i).SatCode(j)-prn_start+1)==prn
            P_B(1,k)=ObsODat_base(i).Obs_RangeC(1,j);%这是L1伪距,   obs(i).Obs_RangeC(2,j)是L2
            L_B(1,k)=ObsODat_base(i).Obs_FreL(1,j);%载波相位
            D_B(1,k)=ObsODat_base(i).dopp(1,j);%多普勒          
            k=k+1;
        end
    end
end
k=1;
for i=1500:3000
    for j=1:ObsODat_rover(i).SatSumAll
        if (ObsODat_rover(i).SatCode(j)-prn_start+1)==prn
            P_R(1,k)=ObsODat_rover(i).Obs_RangeC(1,j);%这是L1伪距,   obs(i).Obs_RangeC(2,j)是L2
            L_R(1,k)=ObsODat_rover(i).Obs_FreL(1,j);%载波相位
            D_R(1,k)=ObsODat_rover(i).dopp(1,j);%多普勒          
            k=k+1;
        end
    end
end
csL_R=addcs(L_R,1,100,1);
csL_B=addcs(L_B,0,100,1);
x=1:1501;
SD_P=P_R-P_B;
SD_L=csL_R-csL_B;
data1=P_L_method(SD_P,SD_L,lamda);
data1=[0,data1];
figure;
plot_cs(data1);%最基础的伪距减相位法探测周跳
plot(x(100),data1(100),'o','color','r');hold on;
title('G01');