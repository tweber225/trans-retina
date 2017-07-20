function handles = estimate_capture_time_data(handles)

% Default settings
bytesPerPix = 2;
numPixPerDim = handles.settingsStruct.deriveCapNumPixPerDim;

% Get number of capture frames enabled
numChannels = sum(handles.LEDsToEnable,2);

% Calculate pixels per frame
numPixPerFrame = numPixPerDim^2;

% Get number of frame sets
numFrameSets = handles.settingsStruct.capNumFrames;

% Total data for capture
totDataInBytes = numFrameSets*numPixPerFrame*numChannels*bytesPerPix;
if totDataInBytes < 1e3
    dispData = [num2str(totDataInBytes) ' B'];
elseif (totDataInBytes >= 1e3) && (totDataInBytes < 1e6)
    dispData = [num2str(totDataInBytes/(1e3),3) ' KB'];
elseif (totDataInBytes >= 1e6) && (totDataInBytes < 1e9)
    dispData = [num2str(totDataInBytes/(1e6),3) ' MB'];
else
    dispData = [num2str(totDataInBytes/(1e9),3) ' GB'];
end

% Calc. the total number of frames
numFrameTot = numFrameSets*numChannels;

% Predict frame rate
if handles.settingsStruct.capBinSize == 1 % 1x1 binning
    if handles.settingsStruct.capPixClock == 1 % 12MHz
        expTimeCorrected = handles.settingsStruct.capExpTime*(1 - 2.4e-2);
        readTime = 137;
        framePeriod = max([expTimeCorrected,readTime]);
    elseif handles.settingsStruct.capPixClock == 2 % 24MHz
        expTimeCorrected = handles.settingsStruct.capExpTime*(1 - 2.4e-2);
        readTime = 87;
        framePeriod = max([expTimeCorrected,readTime]);
    end
elseif handles.settingsStruct.capBinSize == 2 % 2x2 binning
    if handles.settingsStruct.capPixClock == 1 % 12MHz
        expTimeCorrected = handles.settingsStruct.capExpTime*(1 - 2.4e-2);
        readTime = 69;
        framePeriod = max([expTimeCorrected,readTime]);
    elseif handles.settingsStruct.capPixClock == 2 % 24MHz
        expTimeCorrected = handles.settingsStruct.capExpTime*(1 - 2.4e-2);
        readTime = 37;
        framePeriod = max([expTimeCorrected,readTime]);
    end
elseif handles.settingsStruct.capBinSize == 3 % 4x4 binning
    if handles.settingsStruct.capPixClock == 1 % 12MHz
        expTimeCorrected = handles.settingsStruct.capExpTime*(1 - 2.3e-2);
        readTime = 37;
        framePeriod = max([expTimeCorrected,readTime]);
    elseif handles.settingsStruct.capPixClock == 2 % 24MHz
        expTimeCorrected = handles.settingsStruct.capExpTime*(1 - 3.5e-2);
        readTime = 21;
        framePeriod = max([expTimeCorrected,readTime]);
    end
end

% Total time in sec
totTimeInSec = numFrameTot*framePeriod/1000;

% Convert this to MM:SS.SS
MM = num2str(floor(totTimeInSec/60));
SSdotSS = sprintf('%05.2f',rem(totTimeInSec,60));

% Add these to the estimate text box
estimateStr = ['Estimate:' 10 MM ':' SSdotSS 10 dispData];
set(handles.capTimeDataEstimates,'String',estimateStr);


