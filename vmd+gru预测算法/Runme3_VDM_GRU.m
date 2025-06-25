%% VMD-GRU 周跳探测模型
% 思路:
% 1. 用干净数据训练模型，学习 "正常" 模式。
% 2. 用训练好的模型预测含有周跳的数据。
% 3. 预测残差大的地方，即为周跳。

% ----------------------------------------------------

clc;
clear;
close all;
warning off;
addpath(genpath(pwd));
rng('default');

%% 1. 数据加载与准备
% ===================================================
% 加载干净数据 (用于训练)
try
    load('dat.mat');
    data_clean = dat;
catch
    error('未找到 dat.mat 文件。请先运行 prepare_cycleslip_data.m。');
end

% 加载带周跳和标签的数据 (用于测试)
try
    load('dat_cycleslip_labeled.mat'); % 包含 data_with_slips 和 labels
catch
    error('未找到 dat_cycleslip_labeled.mat 文件。请先运行 inject_slips.m。');
end
% ===================================================

% 划分数据
split_point = floor(0.7 * size(data_clean, 1));

% 训练集 (来自干净数据)
train_data_clean = data_clean(1:split_point, :);

% 测试集 (来自带周跳的数据)
test_data_with_slips = data_with_slips(split_point+1:end, :);
test_labels = labels(split_point+1:end, :);

fprintf('数据准备完成: %d 个训练样本, %d 个测试样本。\n', ...
        size(train_data_clean, 1), size(test_data_with_slips, 1));

%% 2. VMD 分解 (只对训练集的目标信号进行分解)
% 假设我们探测最后一列卫星的周跳
target_sat_col = size(data_clean, 2);
signal_to_decompose = train_data_clean(:, target_sat_col);

% VMD 参数
alpha = 2000;  % 带宽约束
tau = 0;       % 噪声容限
K = 5;         % 分解的模态数
DC = 0;        % 是否包含直流分量
init = 1;      % 均匀初始化
tol = 1e-7;    % 收敛容差

[imfs_train, ~, ~] = VMD(signal_to_decompose, alpha, tau, K, DC, init, tol);

%% 3. 为每个IMF分量训练一个GRU预测模型
num_imfs = K;
trained_nets = cell(num_imfs, 1);

fprintf('开始为 %d 个IMF分量训练GRU模型...\n', num_imfs);

for i = 1:num_imfs
    fprintf('  训练IMF %d...\n', i);
    
    imf_series = imfs_train(:, i);
    
    % --- 创建单步预测的训练数据 ---
    XTrain = [];
    YTrain = [];
    for t = 1 : length(imf_series) - 1
        XTrain{t,1} = imf_series(t,1);
        YTrain{t,1} = imf_series(t+1,1);
    end
    
    % --- GRU网络定义 ---
    indim = 1; % 输入维度
    outdim = 1; % 输出维度
    layers = [ ...
        sequenceInputLayer(indim)
        gruLayer(30)
        reluLayer
        fullyConnectedLayer(outdim)
        regressionLayer];
    
    options = trainingOptions('adam', ...
        'MaxEpochs', 50, ... % 训练次数可以减少，因为任务变简单了
        'GradientThreshold', 1, ...
        'InitialLearnRate', 0.005, ...
        'LearnRateSchedule', 'piecewise', ...
        'LearnRateDropPeriod', 20, ...
        'LearnRateDropFactor', 0.2, ...
        'Verbose', 0, ...
        'Plots', 'none'); % 训练时不显示图形界面

    % --- 训练网络 ---
    net = trainNetwork(XTrain, YTrain, layers, options);
    trained_nets{i} = net;
end
fprintf('所有IMF的GRU模型训练完毕。\n');

%% 4. 在测试集上进行周跳探测
% 首先，我们也需要将测试集信号分解
% 注意：在实际应用中，VMD应该以流式方式进行，这里为简化，我们一次性分解
[imfs_test, ~, ~] = VMD(test_data_with_slips(:, target_sat_col), alpha, tau, K, DC, init, tol);

% 对每个IMF进行预测并计算残差
test_predictions_imfs = zeros(size(imfs_test));
for i = 1:num_imfs
    net = trained_nets{i};
    imf_series_test = imfs_test(:,i);
    
    % 准备测试输入
    XTest = [];
    for t = 1 : length(imf_series_test)-1
        XTest{t,1} = imf_series_test(t,1);
    end
    
    % 预测
    imf_preds = predict(net, XTest);
    test_predictions_imfs(2:end, i) = cell2mat(imf_preds);
end

% 将预测的IMF分量相加，得到最终的组合预测
predicted_signal_test = sum(test_predictions_imfs, 2);
actual_signal_test = test_data_with_slips(:, target_sat_col);

% 计算最终的预测残差
prediction_residuals = actual_signal_test - predicted_signal_test;
% 由于第一个点无法预测，我们将其残差设为0
prediction_residuals(1) = 0;

%% 5. 结果分析与评估
% --- 设定探测阈值 ---
% 阈值可以根据训练集残差的标准差来设定，例如3-sigma原则
% 这里为简单起见，我们先设定一个经验值
detection_threshold = 0.5; % <--- 这是一个非常重要的参数，需要调整

% --- 根据阈值进行判断 ---
detected_slips = abs(prediction_residuals) > detection_threshold;

% --- 性能评估 ---
actual_positives = test_labels(:, target_sat_col);
true_positives = sum(detected_slips & actual_positives);
false_positives = sum(detected_slips & ~actual_positives);
false_negatives = sum(~detected_slips & actual_positives);

detection_rate = true_positives / sum(actual_positives); % 探测率 (召回率)
precision = true_positives / (true_positives + false_positives); % 精确率

fprintf('\n===== 周跳探测性能评估 =====\n');
fprintf('探测阈值: %.4f\n', detection_threshold);
fprintf('真实周跳数: %d\n', sum(actual_positives));
fprintf('探测到的周跳数: %d\n', sum(detected_slips));
fprintf('正确探测数 (TP): %d\n', true_positives);
fprintf('误报数 (FP): %d\n', false_positives);
fprintf('漏报数 (FN): %d\n', false_negatives);
fprintf('---------------------------------\n');
fprintf('探测率 (Recall): %.2f%%\n', detection_rate * 100);
fprintf('精确率 (Precision): %.2f%%\n', precision * 100);
fprintf('===============================\n');


%% 6. 可视化结果
figure;
t = 1:length(actual_signal_test);

% 绘制原始信号和预测信号
subplot(3,1,1);
plot(t, actual_signal_test, 'b-', 'LineWidth', 1.5);
hold on;
plot(t, predicted_signal_test, 'r--', 'LineWidth', 1);
title(['目标卫星 ', num2str(target_sat_col), ' 的MW序列与预测']);
legend('真实值 (含周跳)', '模型预测值');
grid on;

% 绘制预测残差和探测阈值
subplot(3,1,2);
plot(t, prediction_residuals, 'k-');
hold on;
plot(t, ones(size(t)) * detection_threshold, 'r--');
plot(t, -ones(size(t)) * detection_threshold, 'r--');
title('预测残差与探测阈值');
legend('预测残差');
grid on;

% 绘制最终的探测结果和真实标签
subplot(3,1,3);
stem(t, actual_positives, 'b', 'Marker','o', 'BaseValue', -0.1);
hold on;
stem(t, detected_slips * 0.8, 'r', 'Marker','x', 'BaseValue', -0.1); % 错开一点显示
title('探测结果 vs 真实标签');
legend('真实周跳', '探测到的周跳');
ylim([-0.2 1.2]);
xlabel('测试集历元 (Epoch)');
grid on;