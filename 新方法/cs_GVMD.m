clear all;close all;
format long g;
addpath(genpath('C:\Users\tjc\Desktop\论文\周跳'));
load('C:\Users\tjc\Desktop\论文\周跳\程序\matlab界面\data\图书馆\1h_base_kine-gps_bds-302_O.mat');
% load('G:\寒假资料\大论文程序\周跳\数据\3系统\CO01155a_19O','data');
obs=data.body.data;
len=length(obs);
prn=33;%要画图的卫星号
prn_start=1;%各系统起始卫星号,保存数据的时候自己设的,看GPS就是1，北斗就是33,glonass就是68
if prn<=32
    lamda=299792458.0/1.57542E9;%L1波长,根据卫星系统改波长
    str_t=['G',num2str(prn,'%02d')];
else
    lamda=299792458.0/1.561098E9;
    str_t=['C',num2str(prn-32,'%02d')];
end
k=1;
M=20;
s=1500;
e=3000;
for i=s:e
    % for i=1:3000
    for j=1:obs(i).SatSumAll
        if (obs(i).SatCode(j)-prn_start+1)==prn
            P(1,k)=obs(i).Obs_RangeC(1,j);%这是L1伪距,   obs(i).Obs_RangeC(2,j)是L2
            L(1,k)=obs(i).Obs_FreL(1,j);%载波相位
            D(1,k)=obs(i).dopp(1,j);%多普勒
            time(k,:)=obs(i).obstime;
            if k>1
                P_smooth(1,k)=P(1,k)/M+(M-1)/M*(P_smooth(1,k-1)-lamda*((D(1,k)+D(1,k-1))/2));
            else
                P_smooth(1,k)=P(1,k);
            end
            k=k+1;
        end
    end
end

% csL=addcs(L,0,100,1);
csL=addcs(L,1,100,1);
csL=addcs(csL,3,300,1);
csL=addcs(csL,5,500,1);
csL=addcs(csL,7,800,1);
csL=addcs(csL,10,1000,1);
x0=1:e-s+1;
[x1,x2,s1]=P_L_method(P,csL,lamda);
x1=[0,x1];
s1=[0,s1];
figure;plot(x1);hold on;
xlabel('历元数');ylabel('T-mean(T) (cycle)');title(str_t);
plot(3.2*s1,'r');hold on;
plot(-3.2*s1,'k');hold on;
plot(x0(100),x1(100),'o','color','r');hold on;
plot(x0(300),x1(300),'o','color','r');hold on;
plot(x0(500),x1(500),'o','color','r');hold on;
plot(x0(800),x1(800),'o','color','r');hold on;
plot(x0(1000),x1(1000),'o','color','r');hold on;
% x3=dopp_method(csL,D,1);
% x3=[0,x3];
% figure;plot_cs(x3);hold on;title(str_t);
% plot(x0(100),x3(100),'o','color','r');hold on;
% plot(x0(300),x3(300),'o','color','r');hold on;
% plot(x0(500),x3(500),'o','color','r');hold on;
% plot(x0(800),x3(800),'o','color','r');hold on;
% plot(x0(1000),x3(1000),'o','color','r');hold on;
if 1
    k=1;
    start_num=1;
    slip_flag=0;
    L=10;
    csnum=0;
    cstime=0;
    data1(1)=0;
    P_s(1)=P(1);
    for i=1:e-s+1
        if i==1
            continue;
        end
        if slip_flag==1
            start_num=cstime;
        end
        %         if i>cstime
        %             csL(i)=csL(i)+csnum;
        %         end
        P_s(1,i)=P(1,i)/M+(M-1)/M*(P_s(1,i-1)-lamda*((D(1,i)+D(1,i-1))/2));
        data1(i)=((P_s(i)-csL(i)*lamda)-(P_s(i-1)-csL(i-1)*lamda))/lamda;
        if (i)<=L
            data0(i)=data1(i);
            continue;
        end
        ref=min(data0)-0.2;%保证序列为正
        T(i)=4*std(data0);
        data1_cul=data0-ref;
        [forecast,err]=Verhulst_dynamic(data1_cul,3);
        forecast_0=forecast+ref;
        res(i)=(forecast_0(end)-data1(i));
        if 1
            vervalue=forecast(1:end-1);
            RE=err(1:length(vervalue));
            verfore=forecast(end-6:end-1);
            [VD_mre,VD_c,VD_p,VD_y]=GreyMarkov3StepV2(data1_cul,vervalue,verfore,RE);
            if iscell(VD_y)
                VD_y=cell2mat(VD_y);
            end
            VD_y_0=VD_y+ref;
            res_2(i)=VD_y_0(L+1)-data1(i);
            if abs(res_2(i))>T(i)&&abs(res_2(i))>1
                slip_flag=1;
                csnum=round(data1(i)-VD_y_0(L+1));
                cstime=i;
                %             csL(i)=csL(i)+csnum;%修复周跳
                disp(['cycle slip: eph=',num2str(i)])
            else
                slip_flag=0;
            end
            for j=1:L-1
                data0(j)=data0(j+1);
            end
            if slip_flag==0
                data0(L)=data1(i);
            else
                data0(L)=VD_y_0(L+1);
            end
            if i==L+1
                VD_y_0_plot=VD_y_0(1:L);
                for r=1:L
                    res_2(r)=VD_y_0(r)-data1(r);
                    T(r)=4*std(data0(1:r));
                end
            else
                VD_y_0_plot=[VD_y_0_plot,VD_y_0(L+1)];
            end            
        end
    end
    figure;
    plot((res_2));hold on;
    xlabel('历元数');ylabel('|\Delta|(cycle)');title(str_t);
    plot(T,'r');hold on;
%     plot(-T,'k');hold on;
%     legend('预测值与实际值的差值','阈值上限','阈值下限');
    %     ylim([-3 3]);
    t0=1:e-s+1;
    plot(t0(100),res_2(100),'o','color','r');hold on;
    plot(t0(300),res_2(300),'o','color','r');hold on;
    plot(t0(500),res_2(500),'o','color','r');hold on;
    plot(t0(800),res_2(800),'o','color','r');hold on;
    plot(t0(1000),res_2(1000),'o','color','r');hold on;
end