%% LiveVisualizer.m
% -------------------------------------------------------------------------
% LiveVisualizer.m
%
% SYNOPSIS:
%   Streams EMG data from the Myo armband and visualizes it live using:
%     1) a combined raw multi-channel trace plot
%     2) a radar / polar plot of short-window average EMG magnitude
%     3) individual trace subplots for each of the 8 sensors
%
% -------------------------------------------------------------------------

%% Load configs
configs
fprintf('\n Configs successfully loaded to workspace \n')

%% User-adjustable live visualization parameters
liveLabel           = 'LIVE STREAM';
displaySeconds      = 60;        % total live display duration
refreshHz           = 10;                % figure refresh rate

traceWindowSeconds  = min(5, recordTime); % rolling trace window
radarWindowSeconds  = 0.25;               % short window for near-instant radar
showFullHistory     = false;              % false = rolling trace window

sensorLabels = {'Sensor 1 (Radius)', 'Sensor 2', ...
                'Sensor 3', 'Sensor 4 (Ulna)', ...
                'Sensor 5', 'Sensor 6', 'Sensor 7', 'Sensor 8'};

%% Establish hardware connection
EstablishHardwareConnection
fprintf('\n Connection Established to Armband \n')

%% Determine sampling rate using existing repo pattern
fprintf('Recording a few seconds of data to determine current sampling rate \n')

T = 5;
m1.clearLogs()
t_start_fs_test = tic;
m1.startStreaming();
while toc(t_start_fs_test) < T
end
m1.stopStreaming();

fs = floor(length(m1.timeEMG_log)/T);

fprintf('Logged data for %d seconds,\n\t', T);
fprintf('EMG samples: %10d\tApprox. EMG sample rate: %5.2f\n\t', ...
    length(m1.timeEMG_log), fs);

pause(1)

%% Initialize live figures
viz = initializeLiveFigures(sensorNum, sensorLabels, liveLabel, fs);

%% Start live stream
fprintf('\nStarting live visualization for %.1f seconds...\n', displaySeconds);

m1.clearLogs()
m1.startStreaming();

t_live = tic;
refreshPeriod = 1 / refreshHz;

try
    while toc(t_live) < displaySeconds

        pause(refreshPeriod);

        raw = m1.emg_log;
        timestamps = m1.timeEMG_log;

        if isempty(raw) || size(raw,1) < 2
            drawnow;
            continue;
        end

        % -------- Trace data window --------
        if showFullHistory
            traceData = raw;
            traceTime = timestamps;
        else
            traceSamplesToKeep = max(2, round(traceWindowSeconds * fs));
            traceStartIdx = max(1, size(raw,1) - traceSamplesToKeep + 1);
            traceData = raw(traceStartIdx:end, :);
            traceTime = timestamps(traceStartIdx:end);
        end

        % -------- Radar data window --------
        radarSamplesToKeep = max(2, round(radarWindowSeconds * fs));
        radarStartIdx = max(1, size(raw,1) - radarSamplesToKeep + 1);
        radarData = raw(radarStartIdx:end, :);

        updateLiveFigures(viz, traceData, traceTime, radarData, sensorNum, liveLabel, fs);
    end

catch ME
    m1.stopStreaming();
    rethrow(ME);
end

%% Stop stream and clean up
m1.stopStreaming();

fprintf('\n Live visualization complete. Cleaning up resources... \n');
clear mex
fprintf('Done.\n');

%% ---------------- Local functions ----------------

function viz = initializeLiveFigures(sensorNum, sensorLabels, liveLabel, fs)

    colors = lines(sensorNum);

    % ---------------- Figure 1: Combined trace figure ----------------
    viz.traceFig = figure('Name', 'Live EMG Trace', 'WindowState', 'maximized');
    viz.traceAx = axes(viz.traceFig);
    hold(viz.traceAx, 'on');

    viz.traceLines = gobjects(sensorNum,1);
    for ss = 1:sensorNum
        viz.traceLines(ss) = plot(viz.traceAx, nan, nan, ...
            'LineWidth', 1.2, ...
            'Color', colors(ss,:));
    end

    hold(viz.traceAx, 'off');
    grid(viz.traceAx, 'on');
    xlabel(viz.traceAx, 'Time [seconds]');
    ylabel(viz.traceAx, 'EMG');
    title(viz.traceAx, sprintf('%s Raw EMG Traces | Sampling Frequency: %.0f Hz', ...
        liveLabel, fs));
    legend(viz.traceAx, sensorLabels, 'Orientation', 'vertical', ...
        'FontSize', 10, 'Location', 'eastoutside');

    % ---------------- Figure 2: Radar figure ----------------
    theta = linspace(0, 2*pi, sensorNum + 1);
    theta(end) = [];

    viz.radarFig = figure('Name', 'Live EMG Radar Plot', 'WindowState', 'maximized');
    viz.radarAx = polaraxes(viz.radarFig);
    hold(viz.radarAx, 'on');

    viz.theta = theta;
    viz.radarLine = polarplot(viz.radarAx, [theta theta(1)], zeros(1, sensorNum + 1), ...
        '-o', 'LineWidth', 1.5, 'DisplayName', liveLabel);

    viz.radarAx.ThetaTick = rad2deg(theta);
    viz.radarAx.ThetaTickLabels = sensorLabels;
    viz.radarAx.RLim = [0 .1];
    title(viz.radarAx, sprintf('Short-Window Average EMG by Sensor | %s | Sampling Frequency: %.0f Hz', ...
        liveLabel, fs));
    legend(viz.radarAx, 'show', 'Location', 'bestoutside');
    hold(viz.radarAx, 'off');

    % ---------------- Figure 3: Per-sensor subplots ----------------
    viz.sensorFig = figure('Name', 'Live EMG Sensor Subplots', 'WindowState', 'maximized');
    viz.sensorAxes = gobjects(sensorNum,1);
    viz.sensorLines = gobjects(sensorNum,1);

    for ss = 1:sensorNum
        viz.sensorAxes(ss) = subplot(sensorNum,1,ss, 'Parent', viz.sensorFig);
        viz.sensorLines(ss) = plot(viz.sensorAxes(ss), nan, nan, ...
            'LineWidth', 1.2, 'Color', colors(ss,:));
        grid(viz.sensorAxes(ss), 'on');
        ylabel(viz.sensorAxes(ss), sprintf('S%d', ss));
        title(viz.sensorAxes(ss), sensorLabels{ss});

        if ss == sensorNum
            xlabel(viz.sensorAxes(ss), 'Time [seconds]');
        end
    end
end

function updateLiveFigures(viz, traceData, traceTime, radarData, sensorNum, liveLabel, fs)

    % Make trace time start at zero for readability
    if ~isempty(traceTime)
        t0 = traceTime(1);
        traceTime = traceTime - t0;
    else
        traceTime = (0:size(traceData,1)-1)';
    end

    % ---------------- Update Figure 1: Combined trace plot ----------------
    for ss = 1:sensorNum
        set(viz.traceLines(ss), 'XData', traceTime, 'YData', traceData(:,ss));
    end

    if ~isempty(traceTime)
        xlim(viz.traceAx, [traceTime(1), traceTime(end)]);
    end

    dataMin = min(traceData(:));
    dataMax = max(traceData(:));
    if dataMin == dataMax
        pad = 1;
    else
        pad = 0.1 * (dataMax - dataMin);
    end
    ylim(viz.traceAx, [dataMin - pad, dataMax + pad]);

    title(viz.traceAx, sprintf('%s Raw EMG Traces | Sampling Frequency: %.0f Hz | Samples: %d', ...
        liveLabel, fs, size(traceData,1)));

    % ---------------- Update Figure 2: Radar plot ----------------
    cleanRadarData = radarData(all(~isnan(radarData), 2), :);

    if isempty(cleanRadarData)
        sensorAvg = zeros(1, sensorNum);
    else
        sensorAvg = abs(mean(cleanRadarData, 1));
    end

    set(viz.radarLine, ...
        'ThetaData', [viz.theta viz.theta(1)], ...
        'RData', [sensorAvg sensorAvg(1)]);

    % plotmax = max(sensorAvg);
    % if plotmax <= 0
    %     plotmax = 1;
    % end
    % viz.radarAx.RLim = [0 plotmax * 1.2];

    title(viz.radarAx, sprintf('Short-Window Average EMG by Sensor | %s | Sampling Frequency: %.0f Hz', ...
        liveLabel, fs));

    % ---------------- Update Figure 3: Per-sensor subplots ----------------
    for ss = 1:sensorNum
        set(viz.sensorLines(ss), 'XData', traceTime, 'YData', traceData(:,ss));

        if ~isempty(traceTime)
            xlim(viz.sensorAxes(ss), [traceTime(1), traceTime(end)]);
        end

        chanMin = min(traceData(:,ss));
        chanMax = max(traceData(:,ss));
        if chanMin == chanMax
            pad = 1;
        else
            pad = 0.1 * (chanMax - chanMin);
        end
        ylim(viz.sensorAxes(ss), [chanMin - pad, chanMax + pad]);
    end

    drawnow limitrate;
end