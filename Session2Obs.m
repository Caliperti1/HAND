% ------------------------------------------------------------------------
% Session2Obs.m
%
% SYNOPSIS: Finds all data files collected for a given session and
% reformats them into a single observations matrix. Uses
% ReformatToObservations function.
%
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

%% Combine Session Datasets into large observations array 
% User inputs
subjectID = subjectID; 
sessionID = sessionID; 
windowSize = 40;
windowOverlap = .5;
sensorNum = 8;

% Construct the full folder path
dataFolder = fullfile(trainingdata_folder, ['Subject_',subjectID],['Session_', sessionID]);

filePattern = fullfile(dataFolder, 'Trial_*.mat'); 
fileList = dir(filePattern); 

% Initialize an empty array to store concatenated results
sessionObs = [];

% Loop through each file
for ff = 1:length(fileList)
    % Get the full path to the .mat file
    filePath = fullfile(dataFolder, fileList(ff).name);
    
    % Load the .mat file
    fileData = load(filePath); 
    
    % Assume the data you want is stored in a variable named 'data'
    % Replace 'data' with the appropriate variable name
    if isfield(fileData, 'data')
        currentData = fileData.data;
        
        % Reformat each data structure to obs matrix 
        obs = ReformatToObservations(currentData,windowSize,...
    windowOverlap,sensorNum); 
        
        % Concatenate the processed data
        sessionObs = [sessionObs; obs]; % Vertically concatenate
    else
        warning('Variable "data" not found in %s. Skipping file.', fileList(ff).name);
    end
end

% save observation matrix 

% % Construct the full file path
file_name = ['Session_',sessionID, '_Observations.mat'];
file_path = fullfile('training_data',['Subject_',subjectID],['Session_',sessionID], file_name);

save(file_path, 'sessionObs'); % Save observation matrix 
disp(['Observation Data saved as: ', file_path]);

% Display the concatenated data
fprintf(' %2.f trials combined to %.2f  Observations \n', ...
    num2str(height(fileList)),length(sessionObs));