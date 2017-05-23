function settingsStruct = load_default_program_settings()
% Separate function that returns the default settings in a structure

% PREVIEW SETTINGS
settingsStruct.prevExpTime = 10; % in ms
settingsStruct.prevBinSize = 2; % Note: 1=1x1, 2=2x2, 3=4x4pixels
settingsStruct.prevPixClock = 2; % Note: 1=12, 2=24MS/s
settingsStruct.prevGain = 2; % Note: 1=1.00, 2=0.67ADU/e-

% CAPTURE SETTINGS
settingsStruct.capExpTime = 5; % in ms
settingsStruct.capBinSize = 2; % Note: 1=1x1, 2=2x2, 3=4x4pixels
settingsStruct.capPixClock = 2; % Note: 1=12, 2=24MS/s
settingsStruct.capGain = 1; % Note: 1=1.00, 2=0.67ADU/e-
settingsStruct.capNumFrames = 20; % actually it's the NUMBER of frame PAIRS

% COMMON SETTINGS
settingsStruct.commIRMode = 1;
settingsStruct.commAutoScale = 0;
settingsStruct.commXShift = 0;
settingsStruct.commRTStats = 1;
settingsStruct.commRTHistogram = 0;

% SAVE SETTINGS
settingsStruct.saveBaseName = 'subject001';
settingsStruct.saveSettings = 0; % Save a text file with current settings

% NON-ADJUSTABLE CAMERA SETTINGS
% (parameters that won't need to be adjusted in GUI)
settingsStruct.D1DelayTime_unit = 'us';
settingsStruct.D2DelayTime = 0;
settingsStruct.E1ExposureTime_unit = 'ms';
settingsStruct.RDIDoubleImageMode = 'off';
settingsStruct.TMTimestampMode = 'BinaryAndAscii'; % also options: 'No Stamp', 'Binary'

% CONSTANTS
settingsStruct.constCameraBits = 14;
settingsStruct.constNumPixWidth = 1392;
settingsStruct.constNumPixHeight = 1040;