function settingsStruct = load_default_program_settings()
% Separate function that returns the default settings in a structure

% PREVIEW SETTINGS
settingsStruct.prevExpTime = 1; % in ms
settingsStruct.prevBinSize = 2; % Note: 1=1x1, 2=2x2, 3=4x4pixels
settingsStruct.prevPixClock = 2; % Note: 1=12, 2=24MS/s
settingsStruct.prevGain = 2; % Note: 1=1.00, 2=0.67ADU/e-

% CAPTURE SETTINGS
settingsStruct.capExpTime = 10; % in ms
settingsStruct.capBinSize = 1; % Note: 1=1x1, 2=2x2, 3=4x4pixels
settingsStruct.capPixClock = 2; % Note: 1=12, 2=24MS/s
settingsStruct.capGain = 1; % Note: 1=1.00, 2=0.67ADU/e-
settingsStruct.capNumFrames = 20; % actually it's the NUMBER of frame PAIRS

% COMMON SETTINGS
settingsStruct.commIRMode = 0;
settingsStruct.commAutoScale = 0;
settingsStruct.commXShift = 0;
settingsStruct.commRTStats = 1;
settingsStruct.commRTHistogram = 0;
settingsStruct.commStatHistInCenter = 1;

% SAVE SETTINGS
settingsStruct.saveBaseName = 'subject001';
settingsStruct.saveSettings = 1; % Save a text file with current settings
settingsStruct.saveFrameTimes = 1; % Save the time of the frames
settingsStruct.saveCapNum = 1;
settingsStruct.saveCapStartTime = -1;


% NON-ADJUSTABLE CAMERA SETTINGS
% (parameters that won't need to be adjusted in GUI)
settingsStruct.D1DelayTime_unit = 'us';
settingsStruct.D2DelayTime = 0;
settingsStruct.E1ExposureTime_unit = 'ms';
settingsStruct.RDIDoubleImageMode = 'off';
settingsStruct.TMTimestampMode = 'No Stamp'; %'BinaryAndAscii'; %  options: 'No Stamp', 'Binary', 'BinaryAndAscii'

% CONSTANTS
settingsStruct.constCameraBits = 14;
settingsStruct.constNumPixWidth = 1392;
settingsStruct.constNumPixHeight = 1040;
settingsStruct.constLED1CenterWavelength = '780 nm';
settingsStruct.constLED2CenterWavelength = '850 nm';

% DERIVED SETTINGS/PARAMETERS
switch settingsStruct.capBinSize
    case 1
        settingsStruct.deriveCapNumPixPerDim = settingsStruct.constNumPixHeight;
    case 2
        settingsStruct.deriveCapNumPixPerDim = settingsStruct.constNumPixHeight/2;
    case 3
        settingsStruct.deriveCapNumPixPerDim = settingsStruct.constNumPixHeight/4;
end
switch settingsStruct.prevBinSize
    case 1
        settingsStruct.derivePrevNumPixPerDim = settingsStruct.constNumPixHeight;
    case 2
        settingsStruct.derivePrevNumPixPerDim = settingsStruct.constNumPixHeight/2;
    case 3
        settingsStruct.derivePrevNumPixPerDim = settingsStruct.constNumPixHeight/4;
end
settingsStruct.numPixPerDim = settingsStruct.derivePrevNumPixPerDim;

% ANALYSIS SETTINGS
settingsStruct.analysisSelectCenterRadPercent = 0.9;
settingsStruct.analysisAutoScaleHighQuantile = 0.995;
settingsStruct.analysisAutoScaleLowQuantile = 0.005;
settingsStruct.analysisHistogramBins = 128;
settingsStruct.analysisReduceNumPixels = 0;