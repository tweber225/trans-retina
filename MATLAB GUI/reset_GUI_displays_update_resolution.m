function handles = reset_GUI_displays_update_resolution(handles,newResolution)
% Separate function that resets the GUI display windows with an all-black
% frame of the correct resolution. Also resets black level and white level
% scalings to default for camera's bit level.

% Reset all the white/black levels for the 4 LED channels
handles.settingsStruct.blackLevelLED1 = 0;
handles.settingsStruct.whiteLevelLED1 = 2^(handles.settingsStruct.constCameraBits) - 1;
handles.settingsStruct.blackLevelLED2 = handles.settingsStruct.blackLevelLED1;
handles.settingsStruct.whiteLevelLED2 = handles.settingsStruct.whiteLevelLED1;
handles.settingsStruct.blackLevelLED3 = handles.settingsStruct.blackLevelLED1;
handles.settingsStruct.whiteLevelLED3 = handles.settingsStruct.whiteLevelLED1;
handles.settingsStruct.blackLevelLED4 = handles.settingsStruct.blackLevelLED1;
handles.settingsStruct.whiteLevelLED4 = handles.settingsStruct.whiteLevelLED1;

% Make a black image of the correct size
blackFrame = uint16(zeros(newResolution));

% Display black images, and then save all the handles
% Make handles to all the images
imshow(blackFrame, [handles.settingsStruct.blackLevelLED1,handles.settingsStruct.whiteLevelLED1], 'Parent', handles.LED1Ax)
handles.imgHandLED1 = get(handles.LED1Ax,'Children');
imshow(blackFrame, [handles.settingsStruct.blackLevelLED2,handles.settingsStruct.whiteLevelLED2], 'Parent', handles.LED2Ax)
handles.imgHandLED2 = get(handles.LED2Ax,'Children');
imshow(blackFrame, [handles.settingsStruct.blackLevelLED1,handles.settingsStruct.whiteLevelLED1], 'Parent', handles.LEDQuad1Ax)
handles.imgHandLEDQuad1 = get(handles.LEDQuad1Ax,'Children');
imshow(blackFrame, [handles.settingsStruct.blackLevelLED2,handles.settingsStruct.whiteLevelLED2], 'Parent', handles.LEDQuad2Ax)
handles.imgHandLEDQuad2 = get(handles.LEDQuad2Ax,'Children');
imshow(blackFrame, [handles.settingsStruct.blackLevelLED3,handles.settingsStruct.whiteLevelLED3], 'Parent', handles.LEDQuad3Ax)
handles.imgHandLEDQuad3 = get(handles.LEDQuad3Ax,'Children');
imshow(blackFrame, [handles.settingsStruct.blackLevelLED4,handles.settingsStruct.whiteLevelLED4], 'Parent', handles.LEDQuad4Ax)
handles.imgHandLEDQuad4 = get(handles.LEDQuad4Ax,'Children');

% Hide the images that will not be used depending on what viewing mode
% we're in (i.e. quad-channel view enabled, or not)
if handles.settingsStruct.selectLEDsQuadViewOn == 1
    handles.imgHandLED2.Visible = 'off';
    if handles.settingsStruct.selectLEDsEnable1 == 0
        handles.imgHandLEDQuad1.Visible = 'off';
    end
    if handles.settingsStruct.selectLEDsEnable2 == 0
        handles.imgHandLEDQuad2.Visible = 'off';
    end
    if handles.settingsStruct.selectLEDsEnable3 == 0
        handles.imgHandLEDQuad3.Visible = 'off';
    end
    if handles.settingsStruct.selectLEDsEnable4 == 0
        handles.imgHandLEDQuad4.Visible = 'off';
    end
else
    handles.imgHandLEDQuad1.Visible = 'off';
    handles.imgHandLEDQuad2.Visible = 'off';
    handles.imgHandLEDQuad3.Visible = 'off';
    handles.imgHandLEDQuad4.Visible = 'off';
    if sum(handles.LEDsToEnable,2)==1
        handles.imgHandLED2.Visible = 'off';
    end
end

% Set the indicators of black vs white values correctly
set(handles.LED1BlackValueIndicator,'String',['Black: ' num2str(handles.settingsStruct.blackLevelLED1)]);
set(handles.LED1WhiteValueIndicator,'String',['White: ' num2str(handles.settingsStruct.whiteLevelLED1)]);
set(handles.LED2BlackValueIndicator,'String',['Black: ' num2str(handles.settingsStruct.blackLevelLED2)]);
set(handles.LED2WhiteValueIndicator,'String',['White: ' num2str(handles.settingsStruct.whiteLevelLED2)]);

% if enabled, update the histograms too
handles.histogramBinEdges = 0:(handles.settingsStruct.whiteLevelLED1/handles.settingsStruct.analysisHistogramBins):handles.settingsStruct.whiteLevelLED1;
if handles.settingsStruct.commRTHistogram == 1
    if handles.settingsStruct.selectLEDsQuadViewOn == 0
        handles.histHandLED1 = histogram(blackFrame,handles.histogramBinEdges,'Parent', handles.LED1Hist);
        handles.LED1Hist.XLim = [handles.histogramBinEdges(1) handles.histogramBinEdges(end)];
        handles.LED1Hist.YScale = 'log';
        if sum(handles.LEDsToEnable,2) > 1
            handles.histHandLED2 = histogram(blackFrame,handles.histogramBinEdges,'Parent', handles.LED2Hist);
            handles.LED2Hist.XLim = [handles.histogramBinEdges(1) handles.histogramBinEdges(end)];
            handles.LED2Hist.YScale = 'log';
        end
    else % quadview therefore is on
        if handles.settingsStruct.selectLEDsEnable1 == 1
            handles.histHandLEDQuad1 = histogram(blackFrame,handles.histogramBinEdges,'Parent', handles.LEDQuad1Hist);
            handles.histHandLEDQuad1.XLim = [handles.histogramBinEdges(1) handles.histogramBinEdges(end)];
            handles.histHandLEDQuad1.YScale = 'log';
        end
        if handles.settingsStruct.selectLEDsEnable2 == 1
            handles.histHandLEDQuad2 = histogram(blackFrame,handles.histogramBinEdges,'Parent', handles.LEDQuad2Hist);
            handles.histHandLEDQuad2.XLim = [handles.histogramBinEdges(1) handles.histogramBinEdges(end)];
            handles.histHandLEDQuad2.YScale = 'log';
        end
        if handles.settingsStruct.selectLEDsEnable3 == 1
            handles.histHandLEDQuad3 = histogram(blackFrame,handles.histogramBinEdges,'Parent', handles.LEDQuad3Hist);
            handles.histHandLEDQuad3.XLim = [handles.histogramBinEdges(1) handles.histogramBinEdges(end)];
            handles.histHandLEDQuad3.YScale = 'log';
        end
        if handles.settingsStruct.selectLEDsEnable4 == 1
            handles.histHandLEDQuad4 = histogram(blackFrame,handles.histogramBinEdges,'Parent', handles.LEDQuad4Hist);
            handles.histHandLEDQuad4.XLim = [handles.histogramBinEdges(1) handles.histogramBinEdges(end)];
            handles.histHandLEDQuad4.YScale = 'log';
        end
        
            
    end
end

% Update the current number of pixels per dim to the value just set
oldResolution = handles.settingsStruct.numPixPerDim;
handles.settingsStruct.numPixPerDim = newResolution;

% Update image mask
pixDim = handles.settingsStruct.numPixPerDim;
if handles.settingsStruct.analysisReduceNumPixels == 1
    imageMaskMask = mod(bsxfun(@plus,uint16(1:pixDim),uint16((1:pixDim)')),2);
else
    imageMaskMask = ones(pixDim,'uint16');
end
if handles.settingsStruct.commStatHistInCenter == 1
    selectRad = 0.5*pixDim*handles.settingsStruct.analysisSelectCenterRadPercent;
    [x, y] = meshgrid(1:pixDim, 1:pixDim);
    handles.imageMask = uint16((x-.5*pixDim-1).^2+(y-.5*pixDim-1).^2 <= selectRad^2).*imageMaskMask;
else
    handles.imageMask = ones(pixDim,'uint16').*imageMaskMask;
end

% Update the XShift parameter to scale with new resolution
newXShift = round(handles.settingsStruct.commXShift*newResolution/oldResolution);
handles.settingsStruct.commXShift = newXShift;
set(handles.commXShift,'String',num2str(newXShift))
