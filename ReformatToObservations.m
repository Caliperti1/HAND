function [observations] = ReformatToObservations(data,windowSize,...
    windowOverlap,sensorNum)
% ReformatToObservations to takes raw data collected from TrainDataCollect
% and reformats to observations array:
% [sensor 1 win 1][sensor 2 win 1]...[sensor n win 1][gesture index]
% [sensor 1 win 2][sensor 2 win 2]...[sensor n win 2][gesture index]
% [sensor 1 win n][sensor 2 win n]...[sensor n win n][gesture index]
%
% SYNOPSIS:  ReformatToObservations(data,windowSize,windowOverlap,sensorNum)
%            
% INPUT:     data = raw data from all trials in a single array 
%            windowSize = number of sampels to include in each window 
%            windowOverlap = samples that overlap between each window
%            sensorNum = Number of sensors (8 for Thalmic Labs myoband)
%
% OUTPUT:    Observations = array where each row is a single observation to
%            be passed forwardin pipeline.


% NOTES:     - v1.0 
%            - CCA
%            - Open Source

%% Set up 
% Find dimensions of observation array 
windowNum = floor(length(data{2,1}) / (windowSize*windowOverlap));
obsLength = windowSize*sensorNum +1;

% Instantiate placeholder 
observations = NaN(windowNum*length(data),obsLength);

obsIdx = 0;
% Iterate through each gesture (col of data cell array)
for gg = 1:length(data)
    
    label = data{1,gg}; % Not using this in current method 
    raw = data{2,gg};

    % Start window for each gesture 
    winStart = 1;
    winEnd = windowSize;

    % Slide window  
    for ww = 1:windowNum

        % Apply to each sensor 
        for ss = 1:sensorNum
            
            observations((obsIdx + ww),((ss-1)*windowSize)+1:(ss*windowSize)) = ...
                raw(winStart:winEnd,ss)';

            observations((obsIdx + ww),end) = gg;
        end 

        % Reset window indicies 
        winStart = winEnd - (windowSize * windowOverlap);
        winEnd = winStart + windowSize -1;

    end 
    obsIdx = obsIdx + windowNum; 
end 
 
%% Add back later if we decide we want to save individual obs matricies  
% % Construct the full file path
% file_name = ['Observation_', trialID, '.mat'];
% file_path = fullfile('training_data',subjectID, sessionID, file_name);
% 
% save(file_path, 'observations'); % Save observation matrix 
% disp(['Observation Data saved as: ', file_path]);

end