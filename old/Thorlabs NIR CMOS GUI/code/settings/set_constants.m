function constants = set_constants(camName)

switch camName
    case 'DCC3240N'
        constants.sensorXPixels = 1280;
        constants.sensorYPixels = 1024;
        
        constants.histXRangeLow = round(constants.sensorXPixels*(1/2-3.75/10)); % Follows from above
        constants.histXRangeHigh = round(constants.sensorXPixels*(1/2+3.75/10));
                
        constants.secondsOfExtraFramesAtEndOfSequence = 0.5;
        
        constants.fracFramePeriodForExposure =1;
        
        constants.histogramBins = 128;
end