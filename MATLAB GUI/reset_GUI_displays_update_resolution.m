function handles = reset_GUI_displays_update_resolution(handles,newResolution)
% Separate function that resets the GUI display windows with an all-black
% frame of the correct resolution. Also resets black level and white level
% scalings to default for camera's bit level.

handles.settingsStruct.blackLevelLED1 = 0;
handles.settingsStruct.whiteLevelLED1 = 2^(handles.settingsStruct.constCameraBits) - 1;
handles.settingsStruct.blackLevelLED2 = handles.settingsStruct.blackLevelLED1;
handles.settingsStruct.whiteLevelLED2 = handles.settingsStruct.whiteLevelLED1;
blackFrame = uint16(zeros(newResolution));
imshow(blackFrame, [handles.settingsStruct.blackLevelLED1,handles.settingsStruct.whiteLevelLED1], 'Parent', handles.LED1Ax)
handles.imgHandLED1 = get(handles.LED1Ax,'Children');
imshow(blackFrame, [handles.settingsStruct.blackLevelLED2,handles.settingsStruct.whiteLevelLED2], 'Parent', handles.LED2Ax)
handles.imgHandLED2 = get(handles.LED2Ax,'Children');

% Set the indicators of black vs white values correctly
set(handles.LED1BlackValueIndicator,'String',['Black: ' num2str(handles.settingsStruct.blackLevelLED1)]);
set(handles.LED1WhiteValueIndicator,'String',['White: ' num2str(handles.settingsStruct.whiteLevelLED1)]);
set(handles.LED2BlackValueIndicator,'String',['Black: ' num2str(handles.settingsStruct.blackLevelLED2)]);
set(handles.LED2WhiteValueIndicator,'String',['White: ' num2str(handles.settingsStruct.whiteLevelLED2)]);

% if enabled, update the histograms too
handles.histogramBinEdges = 0:(handles.settingsStruct.whiteLevelLED1/handles.settingsStruct.analysisHistogramBins):handles.settingsStruct.whiteLevelLED1;
if handles.settingsStruct.commRTHistogram == 1
    handles.histHandLED1 = histogram(blackFrame,handles.histogramBinEdges,'Parent', handles.LED1Hist);
    handles.LED1Hist.XLim = [handles.histogramBinEdges(1) handles.histogramBinEdges(end)];
    handles.LED1Hist.YScale = 'log';
    handles.histHandLED2 = histogram(blackFrame,handles.histogramBinEdges,'Parent', handles.LED2Hist);
    handles.LED2Hist.XLim = [handles.histogramBinEdges(1) handles.histogramBinEdges(end)];
    handles.LED2Hist.YScale = 'log';
end

% Update the current number of pixels per dim to the value just set
oldResolution = handles.settingsStruct.numPixPerDim;
handles.settingsStruct.numPixPerDim = newResolution;

% Update image mask
if handles.settingsStruct.commStatHistInCenter == 1
    pixDim = handles.settingsStruct.numPixPerDim;
    selectRad = 0.5*pixDim*handles.settingsStruct.analysisSelectCenterRadPercent;
    [x, y] = meshgrid(1:pixDim, 1:pixDim);
    handles.imageMask = uint16((x-.5*pixDim-1).^2+(y-.5*pixDim-1).^2 <= selectRad^2);
else
    handles.imageMask = ones(handles.settingsStruct.numPixPerDim,'uint16');
end

% Update the XShift parameter to scale with new resolution
newXShift = round(handles.settingsStruct.commXShift*newResolution/oldResolution);
handles.settingsStruct.commXShift = newXShift;
set(handles.commXShift,'String',num2str(newXShift))