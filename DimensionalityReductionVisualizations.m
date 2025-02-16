function [] = DimensionalityReductionVisualizations(X,Y, gestures)
% DimensionalityReductionVisualiztion allows you to visualize your higher
% dimension data in lower dimension space. This is especially useful for
% classification tasks where it would important to see differentiation
% between your classes. Current version conducts T-Stoachastic Neighbor
% Embedding with 4 different distance algorithms and 2D Principle Component
% Analysis.
% 
% SYNOPSIS:  [] = DimensionalityReductionVisualizations(X,Y, gestures)

%
% INPUT:     X = Array of all indpedent variables. [#obs x #feats]
%            Y = Array of dependent variables (labels) [#obs x 1]
%            gestures = cell array of classes (defined in configs)
%
% OUTPUT:    []

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

    %% TSNE on Observations 
    
    % Subplots of various algorithms 
    figure('WindowState', 'maximized');
    rng('default') 
    tsne2d1 = tsne(X,'Algorithm','exact','Distance','cityblock');
    subplot(2,2,1)
    h1 = gscatter(tsne2d1(:,1),tsne2d1(:,2),Y);
    title('City Block')
    legend([h1], gestures, 'Location', 'southoutside', 'Orientation', 'horizontal');
    
    rng('default')
    tsne2d2 = tsne(X,'Algorithm','exact','Distance','cosine');
    subplot(2,2,2)
    h2 = gscatter(tsne2d2(:,1),tsne2d2(:,2),Y);
    title('Cosine')
    legend([h2], gestures, 'Location', 'southoutside', 'Orientation', 'horizontal');
    
    rng('default') 
    tsne2d3 = tsne(X,'Algorithm','exact','Distance','chebychev');
    subplot(2,2,3)
    h3 = gscatter(tsne2d3(:,1),tsne2d3(:,2),Y);
    title('Chebychev')
    legend([h3], gestures, 'Location', 'southoutside', 'Orientation', 'horizontal');
    
    rng('default') 
    tsne2d4 = tsne(X,'Algorithm','exact','Distance','euclidean');
    subplot(2,2,4)
    h4 = gscatter(tsne2d4(:,1),tsne2d4(:,2),Y);
    title('Euclidean')
    legend([h4], gestures, 'Location', 'southoutside', 'Orientation', 'horizontal');
    
    sgtitle('t-Stochastic Neighbor Embedding (tSNE) of observations ')
    
    
    %% PCA 

    [coeff,score,latent,tsquared,explained] = pca(X);
    figure()
    h5 = gscatter(score(:,1),score(:,2),Y);
    axis equal
    xlabel('1st Principal Component')
    ylabel('2nd Principal Component')
    legend([h5], gestures, 'Location', 'southoutside', 'Orientation', 'horizontal');
    title('Principal Component Analysis (PCA) of Observations')

end 