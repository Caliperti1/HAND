% ------------------------------------------------------------------------
% DecisionTreeTrainer.m
%
% SYNOPSIS: This script trains a Decision Tree Classifier and tunes
% hyperparameters. Returns the trained model and a confusion matrix.
%
% NOTES: See ReadMe for necessary dependencies and start-up instructions.
% using MyoMex. Update configs.m prior to beginning Model Training Session.
% Once the model is trained, it will be saved to the models folder along with
% the associated training data, configs, and notes on model parameters.
%
% ATTRIBUTION: - V1.1 8 FEB 25 
%              - CCA, USMA 
%              - Open Source
%
% CHANGE LOG: See GitHub
% ------------------------------------------------------------------------

%% Train Initial Decision Tree Model
% Create a default decision tree classifier
tree_baseline = fitctree(X_feat, Y);

%% Perform K-Fold Cross-Validation
cv_model = crossval(tree_baseline, 'KFold', K);

% Compute cross-validation accuracy
cv_accuracy = 1 - kfoldLoss(cv_model);
disp(['K-Fold Accuracy on baseline model: ', num2str(cv_accuracy * 100), '%']);


%% Hyperparameter Tuning

% Start Training Timer 
training_Timer = tic;

% Automatically optimize Decision Tree hyperparameters
tree_optimized = fitctree(X_feat, Y, ...
    'OptimizeHyperparameters', 'auto', ...
    'HyperparameterOptimizationOptions', struct('AcquisitionFunctionName', 'expected-improvement-plus'));

% Display best-found hyperparameters
disp(tree_optimized.ModelParameters);

% Stop Training Timer 
training_time = toc(training_Timer);

%% Evaluate Model with Confusion Matrix
% Get cross-validated predictions
predicted_labels = kfoldPredict(cv_model);

% Compute and display confusion matrix
figure;
conf_matrix = confusionchart(Y, predicted_labels);
confMatrix.ClassLabels = gestures;
title('Confusion Matrix of Decision Tree Model');

%% Train Final Model Using Best Hyperparameters
final_tree_model = fitctree(X_feat, Y, ...
    'PruneCriterion', tree_optimized.ModelParameters.PruneCriterion, ...
    'MinLeaf', tree_optimized.ModelParameters.MinLeaf);

%% Compute Evaluation Metrics 
metrics_DT = EvaluateModel(Y, predicted_labels);

fprintf('Final Decision Tree Metrics: \nTraining Time: %.2f  \n', training_time)
fprintf('Accuracy: %.2f  \n', metrics_DT(1) * 100)
fprintf('Precision: %.2f  \n', metrics_DT(2) * 100)
fprintf('Recall: %.2f  \n', metrics_DT(3) * 100)
fprintf('Specificity: %.2f  \n', metrics_DT(4) * 100)

%% Save the trained model for future use

session_folder = fullfile(models_folder, ['Session_', sessionID]);
    
    if ~exist(session_folder, 'dir')
        mkdir(session_folder);
        disp(['Created new folder: ', session_folder]);
    end

% Save Model 
file_name = 'DT_trained.mat';
file_path = fullfile(session_folder, file_name);

save(file_path, 'final_tree_model'); % Save Model

% Save Metrics 
file_name = 'Metrics_DT.mat';
file_path = fullfile(session_folder, file_name);

save(file_path, 'metrics_DT'); % Save Model

disp('Final Decision Tree model trained and saved successfully.');