function constants = set_constants(camName)

switch camName
    case 'DCC3240N'
        constants.sensorXPixels = 1280;
        constants.sensorYPixels = 1024;
        
        constants.histXRangeLow = round(constants.sensorXPixels/3); % Follows from above
        constants.histXRangeHigh = round(constants.sensorXPixels*2/3);
                
        constants.secondsOfExtraFramesAtEndOfSequence = 0.5;
        
        constants.fracFramePeriodForExposure =.05;
        
        constants.histogramBins = 128;
end