% ------------------------------------------------------------------------
% EstablishHardwareConnection.m
%
% SYNOPSIS: Establishing connection to the Thalmic Armband through the
% MyoMex Package can cause issues, especially if conducting multiple trials
% in one session. This script will troubleshoot and estabish a connection,
% enabling the connection to only be opened once at the start of each
% session.
%
% NOTES: See ReadMe for necessary dependencies and start up instructions
% using MyoMex. Update configs.m prior to beginning Model Training Session.
% Once Model is trained it will be saved to the models folder along with
% the associated training data, configs, and notes on model parameters 
%
%
% ATTRIBUTION: - V2.1 8 FEB 25
%              - CCA, USMA
%              - Open Source
%
% CHANGE LOG: 
% ------------------------------------------------------------------------

%% Establish hardware conneciton 
    % Attempt to establish the connection
    connected = false;
    attempt = 0;
    
    while ~connected && attempt < 3
        attempt = attempt + 1;
        try
    
            % Check if MEX compiler is set up for C++
            [status, output] = system('mex -setup -v C++');
            if status ~= 0
                disp('MEX compiler not configured for C++. Attempting setup...');
                evalc('mex -setup C++'); % Configure MEX for C++
            end
    
            % Try to initialize without installing/building
            fprintf('Attempt %d: Trying to connect to Myo without rebuilding MEX...\n', attempt);
            countMyos = 1;
            mm = MyoMex(countMyos);
            m1 = mm.myoData;
            disp('Connection established successfully!');
            connected = true; % Success, exit the loop
    
        catch ME
            % Check for specific errors and attempt to resolve them
            disp(['Error encountered: ', ME.message]);
    
            if contains(ME.message, 'myo_mex failed to initialize with countMyos') || contains(ME.message, 'not be found')
                % If MEX is not built, install and build
                disp('MEX not built. Installing and building MEX...');
                install_myo_mex();
                build_myo_mex(myo_sdk_path);
            elseif contains(ME.message, 'locked')
                % If MEX API is locked, clear the locked state
                disp('MEX API locked. Clearing all...');
                clear mex;
            else
                % Unhandled errors
                disp('Unhandled error. Retrying...');
            end
        end
    end
    
    if ~connected
        error('Failed to establish a connection with the Myo armband after multiple attempts.');
    end