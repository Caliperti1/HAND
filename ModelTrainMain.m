% ------------------------------------------------------------------------
% ModelTrainMain.m
%
% SYNOPSIS: Main loop to execute machine learning pipeline for EMG
% classificaiton projects using the Thalmic Labs Myo Arm band.

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

%% Model Training 
trainingSessionTimer = tic;
%% Configs 
% The only variables you will need to manipuate in this code are in the
% configs.m file. This will load them all to the workspace so they can be
% seen by each step in the pipeline 
configs

%% Check if new data will be collected 
fprintf('Welcome to Model Trainer! \n \n ')
collect = input('Would you like to collect new Data to train a model on? Y/N \n ','s');

if collect == 'Y' || collect == 'y'
    %% Establish Connection to Sensor
    % Ensure bluetooth connection has been established to Myo App and you have
    % installed the required dependencies. This script will troubleshoot the rest
    EstablishHardwareConnection
    
    %% Start a new session:
    % Initializes a data collection session
    for sesh = 1: sessionLength
        TrainDataCollect
    end 
end 

%% Confirm Session Folder 
existing_files = [];
fprintf('Using Data from Session: %s \n ', sessionID)
confirmation = input('Press enter to confirm or enter Session ID of folder that you want to use', 's');

while length(existing_files) < 1

    
    if ~isempty(confirmation)
        sessionID = confirmation; 
    end 
    
    dataFolder = fullfile(trainingdata_folder, ['Subject_',subjectID],['Session_', sessionID]);
    existing_files = dir(fullfile(session_folder, '*.mat'));

    if length(existing_files) < 1
        disp('Session Folder is empty \n')
        confirmation = input('Please enter Session ID of folder that you want to use');
    end 
 
end 


%% convert folder of trials (session) into observation array  
% Consoldiates enitre folder of data collected during session into one
% observation array 
Session2Obs

%% Pre proccess observations 
% Splits all data into dependent (gesture labels) and independent variable
% (raw sensor readings)arrays 

% Split into X and labels
X = NaN(length(sessionObs),width(sessionObs)-1);
Y = sessionObs(:,end);

% Pre Proccess
for obs = 1:length(sessionObs)
    X(obs,:) = PreProccess(sessionObs(obs,1:end-1), windowSize);
end 

%% Visualize Dimensionality Reduction 
% Peforms t-stochastic neighbor embedding (TSNE) on pre-proccessed data to
% allow user ot visualize higher dimensional relationships within data 
timer_DR_int = tic;
DimensionalityReductionVisualizations(X,Y, gestures)
timer_DR = toc(timer_DR_int)

%% Feature Engineer observation into features array 
% Creates feature array out of pre-proc data (records time)
timer_FE_int = tic;
X_feat = [];

for obs = 1:length(X)
    X_feat(obs,:)  = FeatureExtract(X(obs,:),fs);
end 
timer_FE = toc(timer_FE_int)

%% Visualize Dimensionality Reduciton 
DimensionalityReductionVisualizations(X_feat,Y, gestures)

%% Train Models

% Train a KNN Classifier 
KNNTrainer
mdl(1).name = 'K Nearest Neighbor';
mdl(1).model = final_knn_model;
mdl(1).metrics = metrics_KNN;

% Train a SVM 
SVMTrainer 
mdl(2).name = 'Support Vector Machine';
mdl(2).model = svm_optimized;
mdl(2).metrics = metrics_SVM;

% Train a Decision Tree 
DecisionTreeTrainer
mdl(3).name = 'Decision Tree';
mdl(3).model = final_tree_model;
mdl(3).metrics = metrics_DT;

% Find best model 
accuracies = cellfun(@(x) x(1), {mdl.metrics});

% Find the index of the best model (highest accuracy)
[~, bestIdx] = max(accuracies);

% Assign the best model to 'main_model'
main_model = mdl(bestIdx).model;

mdl(end).model = main_model;
mdl(end).metrics = mdl(bestIdx).metrics;
mdl(end).name = mdl(bestIdx).name;

fprintf('Selected Model: %s \n',mdl(bestIdx).name)
fprintf('\n Model Accuracy: %.2f \n ', mdl(bestIdx).metrics(1) * 100);

%% Save main model 
session_folder = fullfile(models_folder, ['Session_', sessionID]);
    
    if ~exist(session_folder, 'dir')
        mkdir(session_folder);
        disp(['Created new folder: ', session_folder]);
    end

% Save Model 
file_name = 'model_struct.mat';
file_path = fullfile(session_folder, file_name);

save(file_path, 'mdl'); % Save Model

%% Closeout 

fprintf('Model Training Complete! \n') 
fprintf('Main Model saved to: %s \n', file_path)
fprintf('Proceed to Deploying model using HandControlMain.m \n')
fprintf('Total Training Session Time: %.2f \n', toc(trainingSessionTimer)) 

