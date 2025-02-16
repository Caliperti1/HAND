%% Configs 
% The only variables you will need to manipuate in this code are in the
% configs.m file. This will load them all to the workspace so they can be
% seen by each step in the pipeline 
configs
fprintf('\n Configs successfully loaded to workspace \n')

%% Establish classification model 
session_folder = fullfile(models_folder, ['Session_', sessionID]);
file_name = 'model_struct.mat';
model_path = fullfile(session_folder, file_name);

load(model_path);
fprintf('\n Model Loaded! \n')
fprintf('\n Loaded Model: %s \n',mdl(end).name)
fprintf('\n Loaed Model Accuracy: %.2f \n ', mdl(end).metrics(1) * 100);

%% Establish Connection to Armband 
EstablishHardwareConnection
fprintf('\n Connection Established to Armband \n')

fprintf("Recording a few seconds of data to determine current sampling rate \n")

% Determine Sampling rate of armband 
T = 5;
m1.clearLogs()
t_start_fs_test = tic;
m1.startStreaming();
while toc(t_start_fs_test) < T
end 
m1.stopStreaming();

fs = floor(length(m1.timeEMG_log)/T);

fprintf('Logged data for %d seconds,\n\t',T);
fprintf('EMG samples: %10d\tApprox. EMG sample rate: %5.2f\n',...
  length(m1.timeEMG_log),fs);
m1.clearLogs()
pause(1)

%% Establish Hand Connection
% Serial Connection to hand 
controllerSerialPort = "COM4";
baudRate = 9600;

s = serialport(controllerSerialPort, baudRate);
s.Timeout = 600; % Set timeout to 10 minutes
pause(2);

%% Send Initialization command to Hand 
fprintf("...Waking up Hand... \n")
write(s,"STRETCH","string")
pause(8)
write(s,"LETSROCK",'string')
fprintf("\n Let's Rock! Connection to Hand Established \n")

%% Instantiate Session
session = 1; 

while session > 0 
    if session == 1
        write(s,"Y",'string');
    end 

    % Read Armband Data
    if s.NumBytesAvailable > 0
        readysig = readline(s);
        disp(readysig)

        if contains(readysig, "Y", 'IgnoreCase', true)

            fprintf('Hand is ready for next gesture! /n')
            % Collect epoch of datatwice as long as window and select observation from
            % middle of window 
            recordTime = (3/fs)*windowSize ; 
            % m1.clearLogs()
            % t_start = tic;
            % 
            % m1.startStreaming();
            % while toc(t_start) < recordtime
            %     disp('recording')
            % end 
            % m1.stopStreaming();
            % 
            % 
            % raw = m1.emg_log;
            m1.clearLogs()
            t_start_fs_test = tic;
            
            m1.startStreaming();
            while toc(t_start_fs_test) < recordTime
                pause(recordTime / 50)
                
                progress = toc(t_start_fs_test) /recordTime;
                 
                clc
                fprintf('\rProgress: [%s%s] %3.0f%%', repmat('=', 1, floor(progress * 20)), ...
                    repmat(' ', 1, 20 - floor(progress * 20)), progress * 99);
                
    
             end 
            m1.stopStreaming();
            raw = m1.emg_log;
            data = raw(windowSize/2 + 1 : 3*windowSize/2, :);
            fprintf('\n Observation Collected \n')
            
            % Run observation through pipeline 
            
            % Reformat 
            for ss = 1:sensorNum
                observation(((ss-1)*windowSize)+1:(ss*windowSize)) = data(:,ss)';
            end 
            fprintf('Observation Reformatted \n')

            % Preprocess
            obs_PP = PreProccess(observation,windowSize);
             fprintf('Observation Pre-Processed \n')

            % Feature Extract 
            obs_feat = FeatureExtract(obs_PP, fs);
             fprintf('Observation Feature Extracted \n')

            % Predict gesture 
            
            gest = predict(mdl(end).model,obs_feat);
            
            fprintf('\n Predicted Gesture: %s \n', gestures{gest})
            
            
            % %% Simple test method - use built in pose algo 
            %    pose = m1.pose;
            % 
            % %% Pass to Model 
            % 
            % % Use built in classifier for Rock or Paper 
            %         % gesture = '';
            %         % 
            %         % if  pose == 1
            %         %     gesture = 'ROCK'
            %         % end 
            %         % if  pose == 4
            %         %     gesture = 'PAPER'
            %         % end 
            %         % 
            % switch pose 
            %     case 1
            %         gesture = 'ROCK'
            %     case 4
            %         gesture = 'PAPER'
            %     case 2
            %         session = 0; %terminate 
            %         gesture = "SCISSORS"
            %         fprintf("Session Termianted - Peace Out! \n")
            %     otherwise 
            %         gesture = 'OKAY';
            %         fprintf('No gesture detected - Standing By \n')
            % end 
            % pause(2)
            
            % Pass Gesture to Hand 
            write(s, gestures{gest}, "string")
            pause(3)
        end 
    end 
        session = session + 1;
end 

fprintf('\n Cleaning up resources... \n');
clear s 
clear mex

fprintf('Session Complete \n ')