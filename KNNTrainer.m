% ------------------------------------------------------------------------
% KNNTrainer.m
%
% SYNOPSIS: This sript trains a K-Nearest Neighbor Classifier and tunes
% hyperparamers. Returns the trained model and a confusion matrix.

% NOTES: See ReadMe for necessary dependencies and start up instructions
% using MyoMex. Update configs.m prior to beginning Model Training Session.
% Once Model is trained it will be saved to the models folder along with
% the associated training data, configs, and notes on model parameters 
%
% ATTRIBUTION: - V1.1 8 FEB 25 
%              - CCA, USMA 
%              - Open Source
%
% CHANGE LOG: See github
% ------------------------------------------------------------------------


%% Train Initial KNN Model
% Create a default KNN classifier
knn_baseline = fitcknn(X_feat, Y);

%% Perform K-Fold Cross-Validation
cv_model = crossval(knn_baseline, 'KFold', K);

% Compute cross-validation accuracy
cv_accuracy = 1 - kfoldLoss(cv_model);
disp(['K-Fold Accuracy on baseline model: ', num2str(cv_accuracy * 100), '%']);


%% Hyperparameter Tuning

% Start Training Timer 
training_Timer = tic;

% Automatically optimize KNN hyperparameters
knn_optimized = fitcknn(X_feat, Y, ...
    'OptimizeHyperparameters', 'auto', ...
    'HyperparameterOptimizationOptions', struct('AcquisitionFunctionName', 'expected-improvement-plus'));

% Display best found hyperparameters
disp(knn_optimized.ModelParameters);

% Stop Training Timer 
training_time = toc(training_Timer);

%% Evaluate Model with Confusion Matrix
% Get cross-validated predictions
predicted_labels = kfoldPredict(cv_model);

% Compute and display confusion matrix
figure;
conf_matrix = confusionchart(Y, predicted_labels);
confMatrix.ClassLabels = gestures;
title('Confusion Matrix of KNN Model');

%% Train Final Model Using Best Hyperparameters
final_knn_model = fitcknn(X_feat, Y, ...
    'NumNeighbors', knn_optimized.NumNeighbors, ...
    'Distance', knn_optimized.Distance);

%% Compute Evaluations Metrics 
metrics_KNN = EvaluateModel(Y, predicted_labels);

fprintf('Final KNN Metrics: \nTraining Time: %.2f  \n',training_time)
fprintf('Accuracy: %.2f  \n',metrics_KNN(1) * 100)
fprintf('Percision: %.2f  \n',metrics_KNN(2) * 100)
fprintf('Recall: %.2f  \n',metrics_KNN(3) * 100)
fprintf('Specificity: %.2f  \n',metrics_KNN(4) * 100)

%% Save the trained model for future use

session_folder = fullfile(models_folder, ['Session_', sessionID]);
    
    if ~exist(session_folder, 'dir')
        mkdir(session_folder);
        disp(['Created new folder: ', session_folder]);
    end

% Save Model 
file_name = 'KNN_trained.mat';
file_path = fullfile(session_folder, file_name);

save(file_path, 'final_knn_model'); % Save Model

% Save Metrics 
file_name = 'Metrics_KNN.mat';
file_path = fullfile(session_folder, file_name);

save(file_path, 'metrics_KNN'); % Save Model

disp('Final KNN model trained and saved successfully.');


