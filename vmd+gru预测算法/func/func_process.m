function [T_train,T_test,Pxtrain,Txtrain,Pxtest,Txtest,Norm_I,Norm_O,indim,outdim]=func_process(dat);

Nsamp  = length(dat);       % 样本个数 
steps1 = 5;                       % 延时步长（kim个历史数据作为自变量）
steps2 = 1;                      % 跨zim个时间点进行预测
dims   = size(dat,2);

%  重构数据集
for i = 1: Nsamp - steps1 - steps2 + 1
    Rec_dat(i, :) = [reshape(dat(i: i + steps1 - 1,:), 1, steps1*dims), dat(i + steps1 + steps2 - 1,:)];
end


% 训练集和测试集划分
outdim   = 1;                                  % 最后一列为输出
Rates    = 0.7;                              % 训练集占数据集比例
Ntrains  = round(Rates * Nsamp); % 训练集样本个数
indim    = size(Rec_dat, 2) - outdim;                  % 输入特征维度


P_train = Rec_dat(1: Ntrains, 1: indim)';
T_train = Rec_dat(1: Ntrains, indim + 1: end)';
L_train = size(P_train, 2);

P_test  = Rec_dat(Ntrains + 1: end, 1: indim)';
T_test  = Rec_dat(Ntrains + 1: end, indim + 1: end)';
L_test  = size(P_test, 2);

%归一化
[p_train, Norm_I] = mapminmax(P_train, 0, 1);
p_test            = mapminmax('apply', P_test, Norm_I);

[t_train, Norm_O] = mapminmax(T_train, 0, 1);
t_test            = mapminmax('apply', T_test, Norm_O);

for i = 1 : L_train 
    Pxtrain{i,1} = p_train(:,i);%1个cell内24个数是24*1
    Txtrain{i,1} = t_train(:,i);
end

for i = 1 : L_test 
    Pxtest{i,1} = p_test(:,i);
    Txtest{i,1} = t_test(:,i);
end