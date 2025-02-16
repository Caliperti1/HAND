function [observation_Preproc] = PreProccess(observation,window_size)
% PreProccess takes a single observation (one row of training array or each
% window for online use) and applies preProccessing functions. Current
% version does nothing.
% 
% SYNOPSIS:  [observation_Preproc] = PreProccess(observation)

%
% INPUT:     observation = single row of observations excluding the label
%
% OUTPUT:    observation_Preproc = single row of pre=proccessed data

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

%% PreProccess 

%% Rectify 
EMG_rect = abs(observation);

%% RMS 
EMG_env = sqrt(movmean(EMG_rect.^2, window_size));

%% Final PreProcessed Signal 
observation_Preproc = EMG_env;

end 