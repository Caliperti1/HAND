function metrics = EvaluateModel(Y, Yhat)
    % Create Confusion Matrix
    confMat = confusionmat(Y, Yhat);

    % Compute Overall Accuracy
    accuracy = sum(Y == Yhat) / numel(Y);

    % Extract True Positives, False Positives, False Negatives, True Negatives
    TP = diag(confMat);  % True Positives (diagonal elements)
    FP = sum(confMat, 1)' - TP;  % Column sum minus TP
    FN = sum(confMat, 2) - TP;  % Row sum minus TP
    TN = sum(confMat(:)) - (TP + FP + FN);  % Total samples minus others

    % Compute Metrics with Safeguards Against Division by Zero
    precision = mean(TP ./ (TP + FP), 'omitnan');  % Mean across classes
    recall = mean(TP ./ (TP + FN), 'omitnan');  % Mean across classes
    specificity = mean(TN ./ (TN + FP), 'omitnan');  % Mean across classes

    % Matthew's Correlation Coefficient 
    MCC = (TP .* TN - FP .* FN) ./ sqrt((TP+FP) .* (TP+FN) .* (TN+FP) .* (TN+FN));
    % Output a single vector
    metrics = [accuracy, precision, recall, specificity];
end
