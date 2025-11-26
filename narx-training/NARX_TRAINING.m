

clc; clear; close all;

%% Load Simscape-generated input-output data
% Ensure this .mat file contains two variables:
%   Va     -> input voltage (column vector)
%   omega  -> motor angular speed (column vector)
load('simscape_data.mat');    % Example: Va and omega

% Convert to time series format required for NARX
inputSeries  = tonndata(Va,false,false);
targetSeries = tonndata(omega,false,false);

%% Define configurations to train
narxConfigs = [1 1; 2 2; 3 3; 4 4; 5 5];
numConfigs  = size(narxConfigs,1);

fitPercent  = zeros(numConfigs,1);
trainedNets = cell(numConfigs,1);

fprintf('\n=============================\n');
fprintf('Starting NARX Training Phase\n');
fprintf('=============================\n');

for i = 1:numConfigs
    inDel = 1:narxConfigs(i,1);
    fbDel = 1:narxConfigs(i,2);
    hiddenNeurons = 10;   % As in Jameelu's paper

    fprintf('\nTraining NARX(%d,%d)...\n', narxConfigs(i,1), narxConfigs(i,2));

    % Create and configure the NARX network
    net = narxnet(inDel, fbDel, hiddenNeurons);
    net.trainFcn = 'trainlm';            % Levenberg–Marquardt
    net.performFcn = 'mse';
    net.divideFcn = 'dividerand';        % Random data division
    net.trainParam.lr = 0.001;
    net.trainParam.goal = 1e-5;
    net.trainParam.epochs = 1000;
    net.layers{1}.transferFcn = 'tansig';
    net.layers{2}.transferFcn = 'purelin';

    % Prepare data and train the network
    [ins, ist, lst, tgs] = preparets(net, inputSeries, {}, targetSeries);
    [net,tr] = train(net, ins, tgs, ist, lst);

    % Simulate trained network (open-loop)
    y_hat = net(ins, ist, lst);

    % Evaluate fit performance
    [~, fit, ~] = postreg(cell2mat(y_hat), cell2mat(tgs));
    fitPercent(i) = fit;

    % Plot results
    figure;
    plot(cell2mat(tgs),'k','LineWidth',1.2); hold on;
    plot(cell2mat(y_hat),'r--','LineWidth',1.2);
    xlabel('Samples');
    ylabel('Angular Speed (rad/s)');
    legend('Simscape Data','NARX Output','Location','best');
    title(sprintf('NARX(%d,%d) Output vs Simscape Data (Fit = %.2f%%)', ...
        narxConfigs(i,1), narxConfigs(i,2), fit));
    grid on;

    % Save the trained network to a .mat file for Simulink
    filename = sprintf('NARX_%d_%d.mat', narxConfigs(i,1), narxConfigs(i,2));
    save(filename,'net');
    fprintf('Saved trained network: %s\n', filename);

    trainedNets{i} = net;
end

%% Display performance summary
fprintf('\n=============================\n');
fprintf('      TRAINING SUMMARY\n');
fprintf('=============================\n');
for i = 1:numConfigs
    fprintf('NARX(%d,%d): Fit = %.2f%% | Saved as NARX_%d_%d.mat\n', ...
        narxConfigs(i,1), narxConfigs(i,2), fitPercent(i), narxConfigs(i,1), narxConfigs(i,2));
end

[~, bestIdx] = max(fitPercent);
fprintf('\nBest performing configuration: NARX(%d,%d) with Fit = %.2f%%\n', ...
        narxConfigs(bestIdx,1), narxConfigs(bestIdx,2), fitPercent(bestIdx));

fprintf('\nAll trained networks are saved and ready for import into Simulink.\n');
