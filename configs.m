% ------------------------------------------------------------------------
% configs.m
%
% SYNOPSIS: Contaions all configuration variables for the HANDs program.

% NOTES: See ReadMe for necessary dependencies and start up instructions
% using MyoMex.This is the only script that you need to manipulate to run
% this program. Both saves configs as .mat to main folder and populates
% variables to workspace.

% ATTRIBUTION: - V1.1 8 FEB 25 
%              - CCA, USMA 
%              - Open Source
%
% CHANGE LOG: See github
% ------------------------------------------------------------------------

%% Configs 
% Update this data before collecting data and building models. These
% parameters should be the only thing you need to manipulate in this
% program

% [cell array of strings] What gestures do you want to classify
gestures = {'ROCK','PAPER','SCISSORS','OKAY','LETSROCK'};

% Data is saved in the following structure. trial_ID automatically
% increments within the chosen folder
%   base_folder\
%       subject_subjectID\
%           session_sessionID\
%               trial_ID.mat
% root folder for storing training data. 
trainingdata_folder = 'C:\Users\christopher.aliperti\OneDrive - West Point\Desktop\Myo\training_data';
models_folder = 'C:\Users\christopher.aliperti\OneDrive - West Point\Desktop\Myo\Models';

% [string] subject ID (will create a new folder called 'Subject_subjectID'
% if one does not already exist)
subjectID = '01';

% [string] subject ID (will create a new folder called 'Session_sessionID'
% if one does not already exist)
sessionID = '11FEB25';

% [int] number of iterations of trials for each gesture
sessionLength = 5;

% [int] Length of each gesture trial
recordTime = 10;

% [int] Size of window for each observation
windowSize = 40;

% [0->1] Percent overlap between windows  
windowOverlap = .5;

% Number of sensors (Thalmic labs myoband has 8)
sensorNum = 8;

% File path to SDK if using Thalmic Labs myoband
myo_sdk_path = 'C:\Users\christopher.aliperti\OneDrive - West Point\Desktop\Myo\myo-sdk-win-0.9.0\myo-sdk-win-0.9.0\';

% Folds for K-fold Cross Validation
K = 10; 

% Saves configs to be loaded, main loop will also call this script which
% will populate the workspace 
save('configs.mat');