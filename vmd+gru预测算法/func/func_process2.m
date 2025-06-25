function [T_train,T_test,Pxtrain,Txtrain,Pxtest,Txtest,Norm_I,Norm_O,indim,outdim]=func_process2(X_imf,dims);

Nsamp = length(X_imf);  % 样本个数 

steps1 = 5;                       % 延时步长（kim个历史数据作为自变量）
steps2 = 1;  

%重构
for i = 1: Nsamp - steps1 - steps2 + 1
    Rec_dat(i, :) = [reshape(X_imf(i: i + steps1 - 1,:), 1, steps1*dims), X_imf(i + steps1 + steps2 - 1,:)];
end
%训练集和测试集划分
outdim  = 1;                                  
Rates   = 0.7;                             
Ntrains = round(Rates * Nsamp);  
indim   = size(Rec_dat, 2) - outdim;               


P_train = Rec_dat(1: Ntrains, 1: indim)';
T_train = Rec_dat(1: Ntrains, indim + 1: end)';
L_train = size(P_train, 2);

P_test = Rec_dat(Ntrains + 1: end, 1: indim)';
T_test = Rec_dat(Ntrains + 1: end, indim + 1: end)';
L_test  = size(P_test, 2);

%  数据归一化
[p_train, Norm_I] = mapminmax(P_train, 0, 1);
p_test = mapminmax('apply', P_test, Norm_I);

[t_train, Norm_O] = mapminmax(T_train, 0, 1);
t_test = mapminmax('apply', T_test, Norm_O);

%  格式转换
for i = 1 : L_train 
    Pxtrain{i, 1} = p_train(:, i);
    Txtrain{i, 1} = t_train(:, i);
end

for i = 1 : L_test 
    Pxtest{i, 1} = p_test(:, i);
    Txtest{i, 1} = t_test(:, i);
end