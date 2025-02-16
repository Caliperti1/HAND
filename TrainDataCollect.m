% ------------------------------------------------------------------------
% TrainDataCollect.m
%
% SYNOPSIS: Faciliates a full data collection trial IAW the parameters
% established in configs. 

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
   

%% Provide Opening Instructions 
    
    fprintf("EMG Gesture Recognition Training Dataset Collection \n")
    
    fprintf("\n We will collect EMG data from your Myo arm band for %.f different gestures for 10 seconds each \n",length(gestures))

    start = input("\n When you are ready press any button: ","s");
        
    %% Determine Sampling Rate 
    % Sampling rate is typically about 200 Hz but drops signifigantly when
    % the batteries are low. This step allows us to check that the sampling
    % rate is still reasonable before progressing with data collection.
    fprintf("Recording a few seconds of data to determine current sampling rate \n")
    
    T = 5;
    m1.clearLogs()
    t_start_fs_test = tic;
    m1.startStreaming();
    while toc(t_start_fs_test) < T
    end 
    m1.stopStreaming();
    
    fs = floor(length(m1.timeEMG_log)/T);
    
    fprintf('Logged data for %d seconds,\n\t',T);
    fprintf('EMG samples: %10d\tApprox. EMG sample rate: %5.2f\n\t',...
      length(m1.timeEMG_log),fs);
    
    pause(1)
    
    %% Data Recording 

       data = cell(3,length(gestures));
    
    for tt = 1:length(gestures)

        disp(sprintf("\n Gesture %.f:",tt) + gestures{tt})
        fprintf("\n")
        pause(2)
        fprintf("\n \n Data collection starts in \n ")
        pause(1)
        fprintf("...3... \n")
        pause(1)
        fprintf("...2... \n")
        pause(1)
        fprintf("...1... \n")
        pause(1)
    
        
        disp("Recording: %s",gestures{tt})
    
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
    
    data{1,tt} = gestures{tt};
    data{2,tt} = m1.emg_log;
    data{3,tt} = m1.timeEMG_log;
    
    fprintf("\n\n Recording Complete:  ")
    disp(gestures{tt})
    fprintf("\n\n")

    
    end 
    
    %% Save Data 
    % base_folder = 'training_data';
    
    % Subject info
    fprintf("Data collection complete \n")
    subjectID = input("Input Subject number:  ", "s");
    fprintf("\n")

    subject_folder = fullfile(trainingdata_folder, ['Subject_', subjectID]);
    
    if ~exist(subject_folder, 'dir')
        mkdir(subject_folder);
        disp(['Created new folder: ', subject_folder]);
    end
    
    % Session info 
    sessionID = input("Input Session ID:   ", "s");
    fprintf("\n")
    
    session_folder = fullfile(subject_folder, ['Session_', sessionID]);
    
    if ~exist(session_folder, 'dir')
        mkdir(session_folder);
        disp(['Created new folder: ', session_folder]);
    end
    
    % Trial info (will auto increment) 
    existing_files = dir(fullfile(session_folder, '*.mat'));
    
    if isempty(existing_files)
        trialID = '01'; % Start with trial 01
    else
        % Extract trial numbers and find the next available
        % trial_nums = arrayfun(@(x) str2double(extractBetween(x.name, 'Trial_', '.mat')), existing_files);
        trial_nums = length(dir([session_folder,'\*.mat']));
        trialID = sprintf('%02d', trial_nums + 1);
    end
    disp(['Auto-assigned trial number: ', trialID]);
    
    % save 
    %   training_data\
    %       subject_folder\
    %           session_folder\
    %               trial_ID.mat
    
    % Construct the full file path
    file_name = ['Trial_', trialID, '.mat'];
    file_path = fullfile(session_folder, file_name);
    
    save(file_path, 'data'); % Save EMG data, timestamps, and sampling rate
    disp(['Trial Data saved as: ', file_path]);
    
       %% Visualize Data 
    
    VisualizeTrainingCollect(data,gestures,subjectID,sessionID,trialID,fs,recordTime);

    %% Option to add trial notes 
    % Prompt the user for notes
    notes = input('Enter any notes for this session (press Enter to skip):\n', 's');
    
    % Check if the user entered any notes
    if ~isempty(notes)
        % Create the notes file path
        [file_dir, file_name, ~] = fileparts(file_path); % Extract directory and base file name
        notes_file_path = fullfile(file_dir, [file_name, '_notes.txt']); % Append _notes.txt
        
        % Save the notes to the text file
        try
            fid = fopen(notes_file_path, 'w'); % Open the file for writing
            if fid == -1
                error('Could not create notes file.');
            end
            fprintf(fid, '%s', notes); % Write the notes to the file
            fclose(fid); % Close the file
            disp(['Notes saved as: ', notes_file_path]);
        catch ME
            disp(['Error saving notes: ', ME.message]);
        end
    else
        disp('No notes entered. Skipping notes file creation.');
    end
    

    
    %% Clean up 
    fprintf('\n Cleaning up resources... \n');
    
    clear mex
    
    fprintf(' \n Data collection trial complete! \n \n')

% end 