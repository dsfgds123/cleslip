clear all;close all;
format long g;
addpath(genpath('C:\Users\tjc\Desktop\����\����'));
load('C:\Users\tjc\Desktop\����\����\����\����\�·���\base_rov_data.mat','ObsODat_base','ObsODat_rover');
len=length(ObsODat_rover);
prn=1;%Ҫ��ͼ�����Ǻ�
prn_start=1;%��ϵͳ��ʼ���Ǻ�,�������ݵ�ʱ���Լ����,��GPS����1����������33,glonass����68
lamda=299792458.0/1.57542E9;%L1����,��������ϵͳ�Ĳ���
k=1;
for i=1500:3000
    for j=1:ObsODat_base(i).SatSumAll
        if (ObsODat_base(i).SatCode(j)-prn_start+1)==prn
            P_B(1,k)=ObsODat_base(i).Obs_RangeC(1,j);%����L1α��,   obs(i).Obs_RangeC(2,j)��L2
            L_B(1,k)=ObsODat_base(i).Obs_FreL(1,j);%�ز���λ
            D_B(1,k)=ObsODat_base(i).dopp(1,j);%������          
            k=k+1;
        end
    end
end
k=1;
for i=1500:3000
    for j=1:ObsODat_rover(i).SatSumAll
        if (ObsODat_rover(i).SatCode(j)-prn_start+1)==prn
            P_R(1,k)=ObsODat_rover(i).Obs_RangeC(1,j);%����L1α��,   obs(i).Obs_RangeC(2,j)��L2
            L_R(1,k)=ObsODat_rover(i).Obs_FreL(1,j);%�ز���λ
            D_R(1,k)=ObsODat_rover(i).dopp(1,j);%������          
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
plot_cs(data1);%�������α�����λ��̽������
plot(x(100),data1(100),'o','color','r');hold on;
title('G01');