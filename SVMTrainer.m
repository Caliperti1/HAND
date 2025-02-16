% ------------------------------------------------------------------------
% SVMTrainer.m
%
% SYNOPSIS: This script trains a Support Vector Machine (SVM) Classifier
% and tunes hyperparameters. Returns the trained model and evaluation metrics.
%
% NOTES: See ReadMe for necessary dependencies and start-up instructions.
% using MyoMex. Update configs.m prior to beginning the Model Training Session.
% Once the model is trained, it will be saved to the models folder along with
% the associated training data, configs, and notes on model parameters.
%
% ATTRIBUTION: - V1.1 8 FEB 25 
%              - CCA, USMA 
%              - Open Source
%
% CHANGE LOG: See GitHub
% ------------------------------------------------------------------------

%% Train Initial SVM Model
% Create a default SVM classifier
svm_baseline = fitcecoc(X_feat, Y);

%% Perform K-Fold Cross-Validation
cv_model = crossval(svm_baseline, 'KFold', K);

% Compute cross-validation accuracy
cv_accuracy = 1 - kfoldLoss(cv_model);
disp(['K-Fold Accuracy on baseline model: ', num2str(cv_accuracy * 100), '%']);

%% Hyperparameter Tuning

% Start Training Timer 
training_Timer = tic;

% Automatically optimize SVM hyperparameters
svm_optimized = fitcecoc(X_feat, Y, ...
    'OptimizeHyperparameters', 'auto', ...
    'HyperparameterOptimizationOptions', struct('AcquisitionFunctionName', 'expected-improvement-plus',...
    'MaxObjectiveEvaluations', 5));

% Display best-found hyperparameters
disp(svm_optimized.ModelParameters);

% Stop Training Timer 
training_time = toc(training_Timer);

%% Evaluate Model with Confusion Matrix
% Get cross-validated predictions
predicted_labels = kfoldPredict(cv_model);

% Compute and display confusion matrix
figure;
conf_matrix = confusionchart(Y, predicted_labels);
confMatrix.ClassLabels = gestures;
title('Confusion Matrix of SVM Model');

%% Compute Evaluation Metrics 
metrics_SVM = EvaluateModel(Y, predicted_labels);

fprintf('Final SVM Metrics: \nTraining Time: %.2f  \n', training_time)
fprintf('Accuracy: %.2f  \n', metrics_SVM(1) * 100)
fprintf('Precision: %.2f  \n', metrics_SVM(2) * 100)
fprintf('Recall: %.2f  \n', metrics_SVM(3) * 100)
fprintf('Specificity: %.2f  \n', metrics_SVM(4) * 100)

%% Save the trained model for future use

session_folder = fullfile(models_folder, ['Session_', sessionID]);
    
    if ~exist(session_folder, 'dir')
        mkdir(session_folder);
        disp(['Created new folder: ', session_folder]);
    end

% Save Model 
file_name = 'SVM_trained.mat';
file_path = fullfile(session_folder, file_name);

save(file_path, 'svm_optimized'); % Save Model

% Save Metrics 
file_name = 'Metrics_SVM.mat';
file_path = fullfile(session_folder, file_name);

save(file_path, 'metrics_SVM'); % Save Model

disp('Final SVM model trained and saved successfully.');
