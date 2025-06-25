clear all;close all;
format long g;
addpath(genpath('C:\Users\tjc\Desktop\����\����\����\����'));
load('C:\Users\tjc\Desktop\����\����\����\matlab����\data\ͼ���\1h_base_kine-gps_bds-302_O.mat');
obs=data.body.data;
len=length(obs);
prn=1;%Ҫ��ͼ�����Ǻ�
prn_start=1;%��ϵͳ��ʼ���Ǻ�,�������ݵ�ʱ���Լ����,��GPS����1����������33,glonass����68
lamda=299792458.0/1.57542E9;%L1����,��������ϵͳ�Ĳ���
k=1;
M=20;
for i=1500:3000
    for j=1:obs(i).SatSumAll
        if (obs(i).SatCode(j)-prn_start+1)==prn
            P(1,k)=obs(i).Obs_RangeC(1,j);%����L1α��,   obs(i).Obs_RangeC(2,j)��L2
            L(1,k)=obs(i).Obs_FreL(1,j);%�ز���λ
            D(1,k)=obs(i).dopp(1,j);%������
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

csL=addcs(L,1,100,1);%������������ز���λ,��������ĵڶ���������������С������������������ɶ�任���������׵��ܿ�������,�����������Ƿ�����������Ԫ,���ĸ������Ƿ���������Ƶ��
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
% legend('ԭʼ�ز���λ','����������');
figure;
% plot(x(1:99),data1(1:99),'b',);hold on;
plot_cs(data1);%�������α�����λ��̽������
plot(x(100),data1(100),'o','color','r');hold on;
plot(x(300),data1(300),'o','color','r');hold on;
plot(x(500),data1(500),'o','color','r');hold on;
plot(x(600),data1(600),'o','color','r');hold on;
plot(x(1000),data1(1000),'o','color','r');hold on;
title('G01');