function [obs_feat] = FeatureExtract(obs,fs)
% FeatureExtract takes a single row of pre-proccessed observations and
% extracts the following features (X denotes it is not active in this
% current version) (Future Version will allow user to select features in 
% configs):
%  ----- Time Domain Features -----
%       Root Mean Square - RMS 
%       Mean Absolute Value -  MAV 
%       Variance - VAR
%       Integrated EMG - IEMG
%       Zero Crossings - ZC
%       Waveform Length - WL 
%       Slope Sign Change - SSC
%
% ---- Frequency Domain Features ----
% ---- (Computed using Pwelch) -----
%  (X)     Mean Frequency - MF
%  (X)     centroid of power spectrum
%  (X)     Median Domain Frequency - MDF
%  (X)     Total Power - TP
%  (X)     Frequnecy Band Ratio - low band (10-25HZ)
%  (X)     Frequnecy Band Ratio - mid band (25-50HZ)
%  (X)     Frequnecy Band Ratio - low band (50-100HZ)
%
% ----- NonLinear Features -----
%  (X)     Sample Entropy 
%  (X)     Fractal Dimension 

%
% INPUT:     obs = single row of observations excluding the label
%            fs = Sampling frequency 
%
% OUTPUT:    obs_featc = single row of extracted features

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

%% Feature Extraction
    
    % This script will take a row of X and extract features to create
    % individual feature variables and a feature space row vector
    % For training data iterate through entire X to create feature matrix 
    
    % since each obs is window x sensor num we need to complete each of these
    % features for each sensor's signal window
    
    
    %% Populate configs in case they get dropped 
    configs 

    %% Iterate through sensors and extract features 

    % Slide window for each sensor 
    sensorNum = 8;
    windowSize = length(obs)/sensorNum;
    sensorStart = 1;
    sensorEnd = sensorStart + windowSize - 1;
        
    % Instantiate placeholders 
     obs_RMS = NaN(1,sensorNum);
     obs_MAV = NaN(1,sensorNum);
     obs_VAR = NaN(1,sensorNum);
     obs_IEMG = NaN(1,sensorNum);
     obs_ZC = NaN(1,sensorNum);
     obs_WL = NaN(1,sensorNum);
     obs_SSC = NaN(1,sensorNum);
     % obs_MF = NaN(1,sensorNum);
     % obs_MDF = NaN(1,sensorNum);
     % obs_TP = NaN(1,sensorNum);
     % obs_LowRat = NaN(1,sensorNum);
     % obs_MidRat = NaN(1,sensorNum);
     % obs_HiRat = NaN(1,sensorNum);


    for ss = 1:sensorNum

        %% Time Domain Features 
        
        % Root Mean Square - RMS 
            % RMS captures the energy of the signal 
        obs_RMS(ss) = sqrt( 1 / windowSize * sum(obs(sensorStart:sensorEnd).^2));
        
        % Mean Absolute Value -  MAV 
            % Represents signal's average activity level 
        obs_MAV(ss) = (1 / windowSize) * sum(abs(obs(sensorStart:sensorEnd)));
        
        % Variance - VAR
            % Provides insight into signal stability 
        obs_VAR(ss) = (1 / (windowSize -1)) * sum(obs(sensorStart:sensorEnd)...
            - mean(obs(sensorStart:sensorEnd)))^2;
        
        % Integrated EMG - IEMG
            % Total signal amplitude, useful measure of muscle contraction
            % intensity 
        obs_IEMG(ss) = sum(abs(obs(sensorStart:sensorEnd)));
        
        % Zero Crossings - ZC
            % Indicates frequency activity 
        obs_ZC = sum(diff(sign(obs(sensorStart:sensorEnd))) ~= 0);
        
        % Waveform Length - WL 
        obs_WL = sum(abs(diff(obs(sensorStart:sensorEnd))));
        
        % Slope Sign Change - SSC
        obs_SSC = sum(diff(sign(diff(obs(sensorStart:sensorEnd)))) ~=0);
        
        %% Frequency Domain Features 
        % [Pxx, f] = pwelch(obs(sensorStart:sensorEnd), hamming(windowSize), [], [], fs);
        % 
        % % Mean Frequency - MF
        %     % centroid of power spectrum
        % obs_MF(ss) = sum(f .* Pxx) / sum(Pxx); 
        % 
        % % Median Domain Frequency - MDF
        %     % frequency at which power spectrum is divided into two equal halves
        % obs_MDF(ss) = f(find(cumsum(Pxx) >= 0.5 * sum(Pxx), 1)); 
        % 
        % % Total Power - TP
        %     % Energy in signal
        % obs_TP(ss) = sum(Pxx);
        % 
        % % Frequency Band Ratios
        % low_band = (f >= 10 & f <= 25);   
        % mid_band = (f > 25 & f <= 50);   
        % high_band = (f > 50 & f <= 100); 
        % 
        % % Compute power in each band
        % low_power = sum(Pxx(low_band));   
        % mid_power = sum(Pxx(mid_band));   
        % high_power = sum(Pxx(high_band));           
        % 
        % % Calculate frequency ratios
        % obs_LowRat(ss) = low_power / obs_TP(ss);
        % obs_MidRat(ss) = mid_power / obs_TP(ss);
        % obs_HiRat(ss) = high_power / obs_TP(ss);
        
        %% Nonlinear Features 
        
        % Sample Entropy 
            % Meaures complexity or regularity of signal
            % Requires Signal Proccessing Toolbox so ignoring for now 
        
        % Fractal Dimension 
            % Describes complexity of signal 
            % Using Higuchi's method 
        % kmax = 10;
        % LK = zeros(1,kmax);
        % 
        % for k = 1:kmax
        %     lm = zeros(1,k);
        %     for m = 1:k
        %         idx = m:k:length(obs)
        % 

        %% Slide window 
        sensorStart = sensorEnd;
        sensorEnd = sensorStart + length(obs)/8;
    end 
    
        %% Feature Vectors
            % Indicates frequency content of signal 
        obs_feat_TD = [obs_RMS obs_MAV obs_VAR obs_IEMG obs_ZC obs_WL obs_SSC];
        % obs_feat_FD = [obs_MF obs_MDF obs_TP obs_LowRat obs_MidRat obs_HiRat];
        
        obs_feat = [obs_feat_TD];


end 