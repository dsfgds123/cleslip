%% 观测文件o文件读取程序(Rinex3.04 V1.0) 
%% 郭武正 20250605 编写
% 本程序适用于提取RTKLIB b34h分解出的.o观测文件中的伪距、载波相位、信噪比等信息
% 因为GPS/BD/GALILEO/GLONASS系统常用频点的不同，程序中依据个人需要，只选择提取了GPS：L1、L2频点
% BD：B1（2）、B2/B2b（7）频点；GALILEO：E1、E5b（7）频点；GLONASS：G1、G2频点数据。若有其他需要，可自行更改程序

%% 打开o文件
clc;
clear all;
[filename,pathname] = uigetfile('C:\Users\tjc\Desktop\论文\周跳\周跳数据\采集20250620\rover.obs','打开O文件');
%uigetfile：打开文件选择对话框，返回文件名和文件路径。

%fope：打开文件或获得有关打开文件的信息，返回等于或大于3的整数文件标识符
%strcat：水平串联字符串，将两个字符串合并在一起
fid = fopen(strcat(pathname,filename),'rt');%rt为定义的文件访问类型，表示按照文本模式打开文件。
if fid == -1 %==：比较fid与-1是否相等
    msgbox('文件选取出错，读取程序无法运行','warning','warn');
    return;
end
fid2 = fopen('观测文件头.txt','wt');%wt为定义的文件访问类型，表示打开或创建要写入的新文件。
fid3 = fopen('观测文件数据.txt','wt');
fprintf(fid2,'观测文件头\n');%fprintf：将数据写入文本文件
fprintf(fid3,'星座号  卫星号     伪距1         载波相位1            多普勒1    信噪比1            伪距2         载波相位2        多普勒2     信噪比2     时间 \n');

%% 人性化进度条

f = waitbar(0,'Please wait...');
pause(.5)

waitbar(.33,f,'Loading your data');
pause(1)

waitbar(.67,f,'Processing your data');
pause(1)

waitbar(1,f,'Finishing');
pause(1)

close(f)

%% 读取文件头
while (1)
    line = fgets(fid);%fgets：读取文件中的行，并保留换行符
    if (line == -1)   %读取一行数据
        break;
    end

    %strfind：在字符串中查找需要的字符串，直接返回字符串每位字母序号
    %~=：确定不相等性，返回逻辑值0,1
    if (strfind(line,'APPROX POSITION XYZ')~= 0)        %读取测站近似坐标
        appro_x = str2double(line(1:14));
        appro_y = str2double(line(15:28));
        approx_z = str2double(line(29:42));
     end
    if (strfind(line,'DELTA H/E/N')~= 0)                %读取天线参数:高，东向、北向的偏心
        ant_h = str2double(line(1:14));
        ant_e = str2double(line(15:28));
        ant_n = str2double(line(29:42));
    end
    if (strfind(line,'OBS TYPES')~= 0)                  %读取观测值种类
        if (strfind(line,'G')~= 0)
            obs_GC1C = line(8:10);%首字母表示数据类型：C:伪距,L:载波相位，D:多普勒，S:信噪比
            obs_GL1C = line(12:14);%中间数字表示频点：1表示第一频点，2表示第二频点
            obs_GD1C = line(16:18);%末尾字母表示属性（跟踪模式/通道）:由接收机类型决定
            obs_GS1C = line(20:22);

            obs_GC2L = line(40:42);
            obs_GL2L = line(44:46);
            obs_GD2L = line(48:50);
            obs_GS2L = line(52:54);
        end
        if (strfind(line,'R')~= 0)
            obs_RC1C = line(8:10);
            obs_RL1C = line(12:14);
            obs_RD1C = line(16:18);
            obs_RS1C = line(20:22);
            
            obs_RC2C = line(40:42);
            obs_RL2C = line(44:46);
            obs_RD2C = line(48:50);
            obs_RS2C = line(52:54);
        end
        if (strfind(line,'C')~= 0)
            obs_CC2I = line(8:10);    %北斗系统中2代表B1频点
            obs_CL2I = line(12:14);
            obs_CD2I = line(16:18);
            obs_CS2I = line(20:22);

            obs_CC7I = line(40:42);   %北斗系统中7代表B2/B2b频点
            obs_CL7I = line(44:46);
            obs_CD7I = line(48:50);
            obs_CS7I = line(52:54);
        end
        if (strfind(line,'E')~= 0)
            obs_EC1C = line(8:10);
            obs_EL1C = line(12:14);
            obs_ED1C = line(16:18);
            obs_ES1C = line(20:22);

            obs_EC7Q = line(40:42);   %GALILEO系统中7代表E5b频点
            obs_EL7Q = line(44:46);
            obs_ED7Q = line(48:50);
            obs_ES7Q = line(52:54);
        end
    end
    %RTKLIB b34h分解出来的o文件无历元间隔项，故注释掉
    % if (strfind(line,'INTERVAL')~= 0)                  %读取观测历元的间隔
        interval = 30.000;
    % end
    if (strfind(line,'TIME OF FIRST OBS')~= 0)         %读取数据文件中第一个记录的时刻
        year(1,1) = str2double(line(1:6));
        month(1,1) = str2double(line(7:12));
        day(1,1) = str2double(line(13:18));
        hour(1,1) = str2double(line(19:24));
        minute(1,1) = str2double(line(25:30));
        second(1,1) = str2double(line(31:43));
    end
    if (strfind(line,'END OF HEADER')~= 0)
        break;
    end
end
 % %d表示整型，%f控制小数输出。 %4.2f表示输出总长度最小为4，小数点后保留2位
 fprintf(fid2,'测站近似坐标 X0=%14.4f',appro_x);%fprintf：将数据写入文本文件。fid2定义为头文件
 fprintf(fid2,'  Y0=%14.4f',appro_y);
 fprintf(fid2,'  Z0=%14.4f\n',approx_z);
 fprintf(fid2,'测站观测间隔  interval=%10.3f\n',interval);%RTKLIB b34h分解出来的o文件无历元间隔项，故注释掉
 fprintf(fid2,'测站观测开始时间：Begin= ');
 fprintf(fid2,'%15s',strcat(num2str(year(1,1)),'年',num2str(month(1,1)),'月',num2str(day(1,1)),'日',num2str(hour(1,1)),':',num2str(minute(1,1)),':',num2str(second(1,1))));
 
 %% 人性化进度条

f = waitbar(0,'Please wait...');
pause(.5)

waitbar(.33,f,'Start reading file header');
pause(1)

waitbar(.67,f,'Processing your data');
pause(1)

waitbar(1,f,'Finishing');
pause(1)

close(f)
 
 %% 读取观测数据  
 line_num = 0;                                          %行数
 while feof(fid)~= 1 %feof：检测文件末尾，如果由末尾指示符返回1，否则0
        line_num = line_num+1;                          % 历元计数
        tline = fgetl(fid);  %fgetl：读取文件中的行，并删除换行符
        chartline = char(tline) ;
 %------------------数据观测时间----------------
        time = chartline(3:21);                         %存储时间
        %sscanf：从字符串读取格式化数据  % %d表示整型，%f控制小数输出。 %4.2f表示输出总长度最小为4，小数点后保留2位
        UTC  = sscanf( time , '%d%d%d%d%d%d' , [1,6] ); %转换为双精度时间信息，UTC时间
        GPS_second = UTC_GPSsecond( UTC );              %转换为GPS秒
        Obs.time=GPS_second;                            %将GPS周秒存入结构数组中
        search_SatNum = str2double(chartline(34:35));   %搜索到的卫星总数
        
 % Beidou(C)-5，Galileo(E)-6，GLONASS(R)-3，Gps(G)-1，Qzss-4，Sbas-2,Unknown-0
        NumPRN1 = 0 ;   %定义初值，类似i,j，便于循环使用
        NumPRN2 = 0 ;
        NumPRN3 = 0 ;
        NumPRN4 = 0 ;
        for Nr = 1:search_SatNum
            chartline = char(fgetl(fid));              %逐行读取
            if (strfind(chartline,'G')~= 0)            %找到GPS卫星星座
                NumPRN1 = NumPRN1 + 1 ;
                GPS_Constellation = 1;                 %将G定义为1
                satNr = str2double(chartline(2:3)) ;   %读取卫星号
                Obs.GPS(line_num) .Constellation = GPS_Constellation;      %将星座存入结构数组
                Obs.GPS(line_num) .PRN(NumPRN1) = satNr;                   %将卫星号存入结构数组

                Obs.GPS1(line_num) .PseudoRange(NumPRN1) = str2double(chartline(6:17)); %将GPS C1C存入结构数组
                Obs.GPS1(line_num) .phase(NumPRN1) = str2double(chartline(21:33)); %将GPS L1C存入结构数组
                Obs.GPS1(line_num) .doppler(NumPRN1) = str2double(chartline(42:49)); %将GPS D1C存入结构数组
                Obs.GPS1(line_num) .snr(NumPRN1) = str2double(chartline(60:65)); %将GPS S1C存入结构数组

                % Obs.GPS2(line_num) .PseudoRange(NumPRN1) = str2double(chartline(134:145)); %将GPS C2L存入结构数组
                % Obs.GPS2(line_num) .phase(NumPRN1) = str2double(chartline(149:161)); %将GPS L2L存入结构数组
                % Obs.GPS2(line_num) .doppler(NumPRN1) = str2double(chartline(169:177)); %将GPS D2L存入结构数组
                % Obs.GPS2(line_num) .snr(NumPRN1) = str2double(chartline(188:193)); %将GPS S2L存入结构数组
                % %d表示整型，%f控制小数输出。 %4.2f表示输出总长度最小为4，小数点后保留2位
                % fprintf(fid3,'  %d     %d   %14.3f   %16.3f   %12.3f   %6.3f      %14.3f   %16.3f   %12.3f   %6.3f   %6d \n',[Obs.GPS(line_num) .Constellation', Obs.GPS(line_num).PRN(NumPRN1)', Obs.GPS1(line_num).PseudoRange(NumPRN1)', Obs.GPS1(line_num).phase(NumPRN1)', Obs.GPS1(line_num) .doppler(NumPRN1)', Obs.GPS1(line_num).snr(NumPRN1)', Obs.GPS2(line_num).PseudoRange(NumPRN1)', Obs.GPS2(line_num).phase(NumPRN1)', Obs.GPS2(line_num) .doppler(NumPRN1)', Obs.GPS2(line_num).snr(NumPRN1)', Obs.time']');  %将结构数组输入到txt文本中
                fprintf(fid3,' %d   %d   %12.3f   %13.3f   %12.3f   %6.3f   %6d \n',[Obs.GPS(line_num) .Constellation', Obs.GPS(line_num).PRN(NumPRN1)', Obs.GPS1(line_num).PseudoRange(NumPRN1)', Obs.GPS1(line_num).phase(NumPRN1)', Obs.GPS1(line_num) .doppler(NumPRN1)', Obs.GPS1(line_num).snr(NumPRN1)', Obs.time']');  %将结构数组输入到txt文本中
            end
            if (strfind(chartline,'R')~= 0)     %以下分别读取北斗、伽利略、格洛纳斯等，同上
                NumPRN2 = NumPRN2 + 1 ;
                GLONASS_Constellation = 3;
                satNr = str2double(chartline(2:3)) ; 
                Obs.GLONASS(line_num). Constellation = GLONASS_Constellation;
                Obs.GLONASS(line_num). PRN(NumPRN2) = satNr;

                Obs.GLONASS1(line_num) .PseudoRange(NumPRN2) = str2double(chartline(6:17)); %将GLONASS C1C存入结构数组
                Obs.GLONASS1(line_num) .phase(NumPRN2) = str2double(chartline(21:33)); %将GLONASS L1C存入结构数组
                Obs.GLONASS1(line_num) .doppler(NumPRN2) = str2double(chartline(41:49)); %将GLONASS D1C存入结构数组
                Obs.GLONASS1(line_num) .snr(NumPRN2) = str2double(chartline(60:65)); %将GLONASS S1C存入结构数组

                Obs.GLONASS2(line_num) .PseudoRange(NumPRN2) = str2double(chartline(134:145)); %将GLONASS C2C存入结构数组
                Obs.GLONASS2(line_num) .phase(NumPRN2) = str2double(chartline(149:161)); %将GLONASS L2C存入结构数组
                Obs.GLONASS2(line_num) .doppler(NumPRN2) = str2double(chartline(169:177)); %将GLONASS D2C存入结构数组
                Obs.GLONASS2(line_num) .snr(NumPRN2) = str2double(chartline(188:193)); %将GLONASS S2C存入结构数组
                fprintf(fid3,'  %d     %d   %14.3f   %16.3f   %12.3f   %6.3f      %14.3f   %16.3f   %12.3f   %6.3f   %6d \n',[Obs.GLONASS(line_num) .Constellation', Obs.GLONASS(line_num).PRN(NumPRN2)', Obs.GLONASS1(line_num).PseudoRange(NumPRN2)', Obs.GLONASS1(line_num).phase(NumPRN2)', Obs.GLONASS1(line_num) .doppler(NumPRN2)', Obs.GLONASS1(line_num).snr(NumPRN2)', Obs.GLONASS2(line_num).PseudoRange(NumPRN2)', Obs.GLONASS2(line_num).phase(NumPRN2)', Obs.GLONASS2(line_num) .doppler(NumPRN2)', Obs.GLONASS2(line_num).snr(NumPRN2)', Obs.time']');  %将结构数组输入到txt文本中
                % fprintf(fid3,' %d   %d   %12.3f   %13.3f   %6.3f   %6d \n',[Obs.GLONASS(line_num).Constellation', Obs.GLONASS(line_num).PRN(NumPRN2)', Obs.GLONASS(line_num).PseudoRange(NumPRN2)', Obs.GLONASS(line_num).phase(NumPRN2)', Obs.GLONASS(line_num) .doppler(NumPRN1),Obs.GLONASS(line_num).snr(NumPRN2)', Obs.time']');
            end
             if (strfind(chartline,'C')~= 0)
                NumPRN3 = NumPRN3 + 1 ;
                Beidou_Constellation = 5;
                satNr = str2double(chartline(2:3)) ; 
                Obs.Beidou(line_num). Constellation = Beidou_Constellation;
                Obs.Beidou(line_num). PRN(NumPRN3) = satNr;

                Obs.Beidou1(line_num) .PseudoRange(NumPRN3) = str2double(chartline(6:17)); %Beidou C2I 存入结构数组
                Obs.Beidou1(line_num) .phase(NumPRN3) = str2double(chartline(21:33)); %Beidou L2I 存入结构数组
                Obs.Beidou1(line_num) .doppler(NumPRN3) = str2double(chartline(41:49)); %Beidou D2I 存入结构数组
                Obs.Beidou1(line_num) .snr(NumPRN3) = str2double(chartline(60:65)); %Beidou S2I 存入结构数组

                % Obs.Beidou2(line_num) .PseudoRange(NumPRN3) = str2double(chartline(134:145)); %Beidou C7I 存入结构数组
                % Obs.Beidou2(line_num) .phase(NumPRN3) = str2double(chartline(149:161)); %Beidou L7I 存入结构数组
                % Obs.Beidou2(line_num) .doppler(NumPRN3) = str2double(chartline(169:177)); %Beidou D7I 存入结构数组
                % Obs.Beidou2(line_num) .snr(NumPRN3) = str2double(chartline(188:193)); %Beidou S7I 存入结构数组
                % fprintf(fid3,'  %d     %d   %14.3f   %16.3f   %12.3f   %6.3f      %14.3f   %16.3f   %12.3f   %6.3f   %6d \n',[Obs.Beidou(line_num) .Constellation', Obs.Beidou(line_num).PRN(NumPRN3)', Obs.Beidou1(line_num).PseudoRange(NumPRN3)', Obs.Beidou1(line_num).phase(NumPRN3)', Obs.Beidou1(line_num) .doppler(NumPRN3)', Obs.Beidou1(line_num).snr(NumPRN3)', Obs.Beidou2(line_num).PseudoRange(NumPRN3)', Obs.Beidou2(line_num).phase(NumPRN3)', Obs.Beidou2(line_num) .doppler(NumPRN3)', Obs.Beidou2(line_num).snr(NumPRN3)', Obs.time']');  %将结构数组输入到txt文本中
                % fprintf(fid3,' %d   %d   %12.3f   %13.3f   %6.3f   %6d \n',[Obs.Beidou(line_num).Constellation', Obs.Beidou(line_num).PRN(NumPRN3)', Obs.Beidou(line_num).PseudoRange(NumPRN3)', Obs.Beidou(line_num).phase(NumPRN3)', Obs.Beidou(line_num).snr(NumPRN3)', Obs.time']');
             end
             if (strfind(chartline,'E')~= 0)
                NumPRN4 = NumPRN4 + 1 ;
                Galileo_Constellation = 6;
                satNr = str2double(chartline(2:3)) ; 
                Obs.Galileo(line_num). Constellation = Galileo_Constellation;
                Obs.Galileo(line_num). PRN(NumPRN4) = satNr;

                Obs.Galileo1(line_num) .PseudoRange(NumPRN4) = str2double(chartline(6:17)); %Beidou C1C 存入结构数组
                Obs.Galileo1(line_num) .phase(NumPRN4) = str2double(chartline(21:33)); %Beidou L1C 存入结构数组
                Obs.Galileo1(line_num) .doppler(NumPRN4) = str2double(chartline(41:49)); %Beidou D1C 存入结构数组
                Obs.Galileo1(line_num) .snr(NumPRN4) = str2double(chartline(60:65)); %Beidou S1C 存入结构数组

                Obs.Galileo2(line_num) .PseudoRange(NumPRN4) = str2double(chartline(70:81)); %Beidou C7Q 存入结构数组
                Obs.Galileo2(line_num) .phase(NumPRN4) = str2double(chartline(85:97)); %Beidou L7Q 存入结构数组
                Obs.Galileo2(line_num) .doppler(NumPRN4) = str2double(chartline(105:113)); %Beidou D7Q 存入结构数组
                Obs.Galileo2(line_num) .snr(NumPRN4) = str2double(chartline(124:129)); %Beidou S7Q 存入结构数组
                fprintf(fid3,'  %d     %d   %14.3f   %16.3f   %12.3f   %6.3f      %14.3f   %16.3f   %12.3f   %6.3f   %6d \n',[Obs.Galileo(line_num) .Constellation', Obs.Galileo(line_num).PRN(NumPRN4)', Obs.Galileo1(line_num).PseudoRange(NumPRN4)', Obs.Galileo1(line_num).phase(NumPRN4)', Obs.Galileo1(line_num) .doppler(NumPRN4)', Obs.Galileo1(line_num).snr(NumPRN4)', Obs.Galileo2(line_num).PseudoRange(NumPRN4)', Obs.Galileo2(line_num).phase(NumPRN4)', Obs.Galileo2(line_num) .doppler(NumPRN4)', Obs.Galileo2(line_num).snr(NumPRN4)', Obs.time']');  %将结构数组输入到txt文本中
                % fprintf(fid3,' %d   %d   %12.3f   %13.3f   %6.3f   %6d \n',[Obs.Galileo(line_num).Constellation', Obs.Galileo(line_num).PRN(NumPRN4)', Obs.Galileo(line_num).PseudoRange(NumPRN4)', Obs.Galileo(line_num).phase(NumPRN4)', Obs.Galileo(line_num).snr(NumPRN4)', Obs.time']');
            end
        end
 end
 
  %% 人性化进度条
    f = waitbar(0,'Data processed');
    pause(.5)

    waitbar(.67,f,'Please wait...');
    pause(.5)

    waitbar(1,f,'Finishing');
    pause(.5)

    close(f)
   
 %% 关闭文件
fclose('all'); 