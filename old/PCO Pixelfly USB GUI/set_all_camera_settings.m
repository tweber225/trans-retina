function srcObj = set_all_camera_settings(srcObj,settingsStruct)
% Function sets all the relevant camera settings in the source object

% PREVIEW SETTINGS
% Assume that a preview will happen first, so configure for that
srcObj.E2ExposureTime = settingsStruct.prevExpTime;
if settingsStruct.prevBinSize == 1
    srcObj.B1BinningHorizontal = '1';
    srcObj.B2BinningVertical = '1';
elseif settingsStruct.prevBinSize == 2
    srcObj.B1BinningHorizontal = '2';
    srcObj.B2BinningVertical = '2';
elseif settingsStruct.prevBinSize == 3
    srcObj.B1BinningHorizontal = '4';
    srcObj.B2BinningVertical = '4';
end
if settingsStruct.prevPixClock == 1
    srcObj.PCPixelclock_Hz = '12000000';
elseif settingsStruct.prevPixClock == 2
    srcObj.PCPixelclock_Hz = '24000000';
end
if settingsStruct.prevGain == 1
    srcObj.CFConversionFactor_e_count = '1.00';
elseif settingsStruct.prevGain == 2
    srcObj.CFConversionFactor_e_count = '1.50';
end

% COMMON SETTTINGS
if settingsStruct.commIRMode == 1
    srcObj.IRMode = 'on';
elseif settingsStruct.commIRMode == 0
    srcObj.IRMode = 'off';
end

% NON-ADJUSTABLE CAMERA SETTINGS
srcObj.D1DelayTime_unit = settingsStruct.D1DelayTime_unit;
srcObj.D2DelayTime = settingsStruct.D2DelayTime;
srcObj.E1ExposureTime_unit = settingsStruct.E1ExposureTime_unit;
srcObj.RDIDoubleImageMode = settingsStruct.RDIDoubleImageMode;
srcObj.TMTimestampMode = settingsStruct.TMTimestampMode;

