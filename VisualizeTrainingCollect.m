function [] = VisualizeTrainingCollect(data,gestures,subjectID,sessionID,trialID,fs, recordTime)

%% Plot of raw traces for each gesture 
figure('WindowState', 'maximized');
% create a new subplot pane for each gesture
for gg = 1:length(gestures)
    subplot(length(gestures),1,gg)

    gestdata = data{2,gg};
    gesttime = [1:length(gestdata)] ;
    gesttime = gesttime .*recordTime ./ length(gesttime);

    % plot the trace of each of the 8 sensors for that gesture
    for ss = 1:width(gestdata)
        hold on
        plot(gesttime,gestdata(:,ss))
    end 
    hold off 
    title(gestures{gg})
    
    
end 
sgtitle(['Subject: ',subjectID,'   ','Session: ', sessionID, '   ',...
    'Trial: ', trialID, '   ','Sampling Frequency: ', num2str(fs),' Hz'])
% legendLabels = ['Sensor 1 (Radius)', 'Sensor 2',...
%     'Sensor 3', 'Sensor 4 (Ulna)', 'Sensor 5', 'Sensor 6', 'Sensor 7',...
%     'Sensor 8']
xlabel('Time [seconds]')
% legend(legendLabels, 'Orientation', 'vertical', 'FontSize', 10, 'Location','eastOutside');

%% Radar plot of averages 

% Create angles for radar plot 
theta = linspace(0, 2*pi, 9); 
theta(end) = []; 

colors = lines(length(gestures)); 

figure('WindowState', 'maximized');
polaraxes;
hold on 

plotmax = 0;

for gg = 1:length(gestures)

    gestdata = data{2,gg};
    gestdata = gestdata(all(~isnan(gestdata), 2), :);
    gestavgs = abs(mean(gestdata,1));

    polarplot([theta theta(1)], [gestavgs gestavgs(1)], '-o', ...
              'LineWidth', 1.5, 'Color', colors(gg, :), ...
              'DisplayName', gestures{gg});

    gestmax = max(gestavgs);

    if gestmax > plotmax
        plotmax = gestmax;
    end 
end 
ax = gca;
ax.ThetaTick = rad2deg(theta); 
ax.ThetaTickLabels = {'Sensor 1 (Radius)', 'Sensor 2',...
    'Sensor 3', 'Sensor 4 (Ulna)', 'Sensor 5', 'Sensor 6', 'Sensor 7',...
    'Sensor 8'};
ax.RLim = [0 plotmax * 1.2]; 
title(['Average EMG Magnitude by Sensor', 'Subject: ',subjectID,'   ','Session: ', sessionID, '   ',...
    'Trial: ', trialID, '   ','Sampling Frequency: ', num2str(fs),' Hz']);
legend('show', 'Location', 'bestoutside'); 
hold off;


%% Frequency Domain 
% 
% subplotrows = floor(sqrt(length(gestures)));
% subplotcols = length(gestures) - subplotrows;
% 
% figure()
% for ff = 1:length(gestures)
% 
%     gestdata = data{2,gg}; 
% 
%     subplot(subplotrows,subplotcols,ff)
%     hold on
%     for ss = 1:width(gestdata)
% 
%         % solve for fft of each sensor 
%         y = fft(gestdata(:,ss));
%         f = (0:length(y)-1)*fs/length(y);
% 
%         % plot fft on subplot per gesture 
%         plot(f,abs(y))
%     end 
%     xlabel('Frequency (Hz)')
%     ylabel('Magnitude')
%     title(gestures{gg})
%     xlim([0 100])
%     hold off 
% 
% end 










