function handles = reset_GUI_displays_update_resolution(handles,newResolution)
% Separate function that resets the GUI display windows with an all-black
% frame of the correct resolution. Also resets black level and white level
% scalings to default for camera's bit level.

% Reset all the white/black levels for the 4 LED channels
handles.settingsStruct.blackLevelLED1 = 0;
handles.settingsStruct.whiteLevelLED1 = 2^(handles.settingsStruct.constCameraBits) - 1;
handles.settingsStruct.blackLevelLED2 = handles.settingsStruct.blackLevelLED1;
handles.settingsStruct.whiteLevelLED2 = handles.settingsStruct.whiteLevelLED1;

handles.settingsStruct.blackLevelLEDQuad1 = handles.settingsStruct.blackLevelLED1;
handles.settingsStruct.whiteLevelLEDQuad1 = handles.settingsStruct.whiteLevelLED1;
handles.settingsStruct.blackLevelLEDQuad2 = handles.settingsStruct.blackLevelLED1;
handles.settingsStruct.whiteLevelLEDQuad2 = handles.settingsStruct.whiteLevelLED1;
handles.settingsStruct.blackLevelLEDQuad3 = handles.settingsStruct.blackLevelLED1;
handles.settingsStruct.whiteLevelLEDQuad3 = handles.settingsStruct.whiteLevelLED1;
handles.settingsStruct.blackLevelLEDQuad4 = handles.settingsStruct.blackLevelLED1;
handles.settingsStruct.whiteLevelLEDQuad4 = handles.settingsStruct.whiteLevelLED1;

% Make a square black image of the correct size
blackFrame = uint16(ones(newResolution));

% Display black images, and then store all the imagehandles
% Make handles to all the images
imshow(blackFrame, [handles.settingsStruct.blackLevelLED1,handles.settingsStruct.whiteLevelLED1], 'Parent', handles.LED1Ax)
handles.imgHandLED1 = get(handles.LED1Ax,'Children');
imshow(blackFrame, [handles.settingsStruct.blackLevelLED2,handles.settingsStruct.whiteLevelLED2], 'Parent', handles.LED2Ax)
handles.imgHandLED2 = get(handles.LED2Ax,'Children');

imshow(blackFrame, [handles.settingsStruct.blackLevelLEDQuad1,handles.settingsStruct.whiteLevelLEDQuad1], 'Parent', handles.LEDQuad1Ax)
handles.imgHandLEDQuad1 = get(handles.LEDQuad1Ax,'Children');
imshow(blackFrame, [handles.settingsStruct.blackLevelLEDQuad2,handles.settingsStruct.whiteLevelLEDQuad2], 'Parent', handles.LEDQuad2Ax)
handles.imgHandLEDQuad2 = get(handles.LEDQuad2Ax,'Children');
imshow(blackFrame, [handles.settingsStruct.blackLevelLEDQuad3,handles.settingsStruct.whiteLevelLEDQuad3], 'Parent', handles.LEDQuad3Ax)
handles.imgHandLEDQuad3 = get(handles.LEDQuad3Ax,'Children');
imshow(blackFrame, [handles.settingsStruct.blackLevelLEDQuad4,handles.settingsStruct.whiteLevelLEDQuad4], 'Parent', handles.LEDQuad4Ax)
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

% Set numerical indicators of black vs white, depending on viewing mode
% (hide the rest)
if handles.settingsStruct.selectLEDsQuadViewOn == 0 % Not in quad-channel mode
    set(handles.LED1BlackValueIndicator,'String',['Black: ' num2str(handles.settingsStruct.blackLevelLED1)]);
    set(handles.LED1WhiteValueIndicator,'String',['White: ' num2str(handles.settingsStruct.whiteLevelLED1)]);
    set(handles.LED2BlackValueIndicator,'String',['Black: ' num2str(handles.settingsStruct.blackLevelLED2)]);
    set(handles.LED2WhiteValueIndicator,'String',['White: ' num2str(handles.settingsStruct.whiteLevelLED2)]);
    handles.LEDQuad1BlackValueIndicator.Visible = 'off';
    handles.LEDQuad1WhiteValueIndicator.Visible = 'off';
    handles.LEDQuad1DisplayedValues.Visible = 'off';
    handles.LEDQuad2BlackValueIndicator.Visible = 'off';
    handles.LEDQuad2WhiteValueIndicator.Visible = 'off';
    handles.LEDQuad2DisplayedValues.Visible = 'off';
    handles.LEDQuad3BlackValueIndicator.Visible = 'off';
    handles.LEDQuad3WhiteValueIndicator.Visible = 'off';
    handles.LEDQuad3DisplayedValues.Visible = 'off';
    handles.LEDQuad4BlackValueIndicator.Visible = 'off';
    handles.LEDQuad4WhiteValueIndicator.Visible = 'off';
    handles.LEDQuad4DisplayedValues.Visible = 'off';
else % in quad-channel view
    if handles.settingsStruct.selectLEDsEnable1 == 1
        set(handles.LEDQuad1BlackValueIndicator,'String',['Black: ' num2str(handles.settingsStruct.blackLevelLED1)]);
        set(handles.LEDQuad1WhiteValueIndicator,'String',['White: ' num2str(handles.settingsStruct.whiteLevelLED1)]);
    else
        handles.LEDQuad1BlackValueIndicator.Visible = 'off';
        handles.LEDQuad1WhiteValueIndicator.Visible = 'off';
        handles.LEDQuad1DisplayedValues.Visible = 'off';
    end
    if handles.settingsStruct.selectLEDsEnable2 == 1
        set(handles.LEDQuad2BlackValueIndicator,'String',['Black: ' num2str(handles.settingsStruct.blackLevelLED2)]);
        set(handles.LEDQuad2WhiteValueIndicator,'String',['White: ' num2str(handles.settingsStruct.whiteLevelLED2)]);
    else
        handles.LEDQuad2BlackValueIndicator.Visible = 'off';
        handles.LEDQuad2WhiteValueIndicator.Visible = 'off';
        handles.LEDQuad2DisplayedValues.Visible = 'off';
    end
    if handles.settingsStruct.selectLEDsEnable3 == 1
        set(handles.LEDQuad3BlackValueIndicator,'String',['Black: ' num2str(handles.settingsStruct.blackLevelLED3)]);
        set(handles.LEDQuad3WhiteValueIndicator,'String',['White: ' num2str(handles.settingsStruct.whiteLevelLED3)]);
    else
        handles.LEDQuad3BlackValueIndicator.Visible = 'off';
        handles.LEDQuad3WhiteValueIndicator.Visible = 'off';
        handles.LEDQuad3DisplayedValues.Visible = 'off';
    end
    if handles.settingsStruct.selectLEDsEnable4 == 1
        set(handles.LEDQuad4BlackValueIndicator,'String',['Black: ' num2str(handles.settingsStruct.blackLevelLED4)]);
        set(handles.LEDQuad4WhiteValueIndicator,'String',['White: ' num2str(handles.settingsStruct.whiteLevelLED4)]);
    else
        handles.LEDQuad4BlackValueIndicator.Visible = 'off';
        handles.LEDQuad4WhiteValueIndicator.Visible = 'off';
        handles.LEDQuad4DisplayedValues.Visible = 'off';
    end
  
    handles.LED1BlackValueIndicator.Visible = 'off';
    handles.LED1WhiteValueIndicator.Visible = 'off';
    handles.LED1DisplayedValues.Visible = 'off';
    handles.LED2BlackValueIndicator.Visible = 'off';
    handles.LED2WhiteValueIndicator.Visible = 'off';
    handles.LED2DisplayedValues.Visible = 'off';
end

% HISTOGRAMS
handles.histogramBinEdges = 0:(handles.settingsStruct.whiteLevelLED1/handles.settingsStruct.analysisHistogramBins):handles.settingsStruct.whiteLevelLED1;
% Display ALL histograms
% - 2 Images Histograms
handles.histHandLED1 = histogram(blackFrame,handles.histogramBinEdges,'Parent', handles.LED1Hist);
handles.LED1Hist.XLim = [handles.histogramBinEdges(1) handles.histogramBinEdges(end)];
handles.LED1Hist.YScale = 'log';
handles.histHandLED2 = histogram(blackFrame,handles.histogramBinEdges,'Parent', handles.LED2Hist);
handles.LED2Hist.XLim = [handles.histogramBinEdges(1) handles.histogramBinEdges(end)];
handles.LED2Hist.YScale = 'log';
% - Quad-view Histograms
handles.histHandLEDQuad1 = histogram(blackFrame,handles.histogramBinEdges,'Parent', handles.LEDQuad1Hist);
handles.LEDQuad1Hist.XLim = [handles.histogramBinEdges(1) handles.histogramBinEdges(end)];
handles.LEDQuad1Hist.YScale = 'log';
handles.histHandLEDQuad2 = histogram(blackFrame,handles.histogramBinEdges,'Parent', handles.LEDQuad2Hist);
handles.LEDQuad2Hist.XLim = [handles.histogramBinEdges(1) handles.histogramBinEdges(end)];
handles.LEDQuad2Hist.YScale = 'log';
handles.histHandLEDQuad3 = histogram(blackFrame,handles.histogramBinEdges,'Parent', handles.LEDQuad3Hist);
handles.LEDQuad3Hist.XLim = [handles.histogramBinEdges(1) handles.histogramBinEdges(end)];
handles.LEDQuad3Hist.YScale = 'log';
handles.histHandLEDQuad4 = histogram(blackFrame,handles.histogramBinEdges,'Parent', handles.LEDQuad4Hist);
handles.LEDQuad4Hist.XLim = [handles.histogramBinEdges(1) handles.histogramBinEdges(end)];
handles.LEDQuad4Hist.YScale = 'log';
% Hide all histograms if they are not requested
if handles.settingsStruct.commRTHistogram == 0
    handles.LED1Hist.Visible = 'off';
    handles.histHandLED1.Visible = 'off';
    handles.LED2Hist.Visible = 'off';
    handles.histHandLED2.Visible = 'off';
    handles.LEDQuad1Hist.Visible = 'off';    
    handles.histHandLEDQuad1.Visible = 'off';
    handles.LEDQuad2Hist.Visible = 'off';
    handles.histHandLEDQuad2.Visible = 'off';
    handles.LEDQuad3Hist.Visible = 'off';
    handles.histHandLEDQuad3.Visible = 'off';
    handles.LEDQuad4Hist.Visible = 'off';
    handles.histHandLEDQuad4.Visible = 'off';
elseif handles.settingsStruct.selectLEDsQuadViewOn == 0
    handles.LEDQuad1Hist.Visible = 'off';
    handles.histHandLEDQuad1.Visible = 'off';
    handles.LEDQuad2Hist.Visible = 'off';
    handles.histHandLEDQuad2.Visible = 'off';
    handles.LEDQuad3Hist.Visible = 'off';
    handles.histHandLEDQuad3.Visible = 'off';
    handles.LEDQuad4Hist.Visible = 'off';
    handles.histHandLEDQuad4.Visible = 'off';
    if sum(handles.LEDsToEnable,2) == 1
        handles.LED2Hist.Visible = 'off';
        handles.histHandLED2.Visible = 'off';
    end
else
    handles.LED1Hist.Visible = 'off';
    handles.histHandLED1.Visible = 'off';
    handles.LED2Hist.Visible = 'off';
    handles.histHandLED2.Visible = 'off';
    if handles.LEDsToEnable(1) == 0
        handles.LEDQuad1Hist.Visible = 'off';
        handles.histHandLEDQuad1.Visible = 'off';
    end
    if handles.LEDsToEnable(2) == 0
        handles.LEDQuad2Hist.Visible = 'off';
        handles.histHandLEDQuad2.Visible = 'off';
    end
    if handles.LEDsToEnable(3) == 0
        handles.LEDQuad3Hist.Visible = 'off';
        handles.histHandLEDQuad3.Visible = 'off';
    end
    if handles.LEDsToEnable(4) == 0
        handles.LEDQuad4Hist.Visible = 'off';
        handles.histHandLEDQuad4.Visible = 'off';
    end
end

% IMAGE STATS
% Depending on the viewing mode, hide image stat labels
if handles.settingsStruct.commRTStats == 0
    handles.LEDQuad1StatsIndicator.Visible = 'off';
    handles.LEDQuad2StatsIndicator.Visible = 'off';
    handles.LEDQuad3StatsIndicator.Visible = 'off';
    handles.LEDQuad4StatsIndicator.Visible = 'off';
    handles.LED1ColorIndicator.Visible = 'off';
    handles.LED1MinIndicator.Visible = 'off';
    handles.LED1MaxIndicator.Visible = 'off';
    handles.LED1MeanIndicator.Visible = 'off';
    handles.LED1MedianIndicator.Visible = 'off';
    handles.LED1PercentSaturatedIndicator.Visible = 'off';
    handles.LED2ColorIndicator.Visible = 'off';
    handles.LED2MinIndicator.Visible = 'off';
    handles.LED2MaxIndicator.Visible = 'off';
    handles.LED2MeanIndicator.Visible = 'off';
    handles.LED2MedianIndicator.Visible = 'off';
    handles.LED2PercentSaturatedIndicator.Visible = 'off';
elseif handles.settingsStruct.selectLEDsQuadViewOn == 0
    handles.LEDQuad1StatsIndicator.Visible = 'off';
    handles.LEDQuad2StatsIndicator.Visible = 'off';
    handles.LEDQuad3StatsIndicator.Visible = 'off';
    handles.LEDQuad4StatsIndicator.Visible = 'off';
    if sum(handles.LEDsToEnable,2) == 1
        handles.LED2ColorIndicator.Visible = 'off';
        handles.LED2MinIndicator.Visible = 'off';
        handles.LED2MaxIndicator.Visible = 'off';
        handles.LED2MeanIndicator.Visible = 'off';
        handles.LED2MedianIndicator.Visible = 'off';
        handles.LED2PercentSaturatedIndicator.Visible = 'off';
    end
else
    handles.LED1ColorIndicator.Visible = 'off';
    handles.LED1MinIndicator.Visible = 'off';
    handles.LED1MaxIndicator.Visible = 'off';
    handles.LED1MeanIndicator.Visible = 'off';
    handles.LED1MedianIndicator.Visible = 'off';
    handles.LED1PercentSaturatedIndicator.Visible = 'off';
    handles.LED2ColorIndicator.Visible = 'off';
    handles.LED2MinIndicator.Visible = 'off';
    handles.LED2MaxIndicator.Visible = 'off';
    handles.LED2MeanIndicator.Visible = 'off';
    handles.LED2MedianIndicator.Visible = 'off';
    handles.LED2PercentSaturatedIndicator.Visible = 'off';
    if handles.LEDsToEnable(1) == 0
        handles.LEDQuad1StatsIndicator.Visible = 'off';
    end
    if handles.LEDsToEnable(2) == 0
        handles.LEDQuad2StatsIndicator.Visible = 'off';
    end
    if handles.LEDsToEnable(3) == 0
        handles.LEDQuad3StatsIndicator.Visible = 'off';
    end
    if handles.LEDsToEnable(4) == 0
        handles.LEDQuad4StatsIndicator.Visible = 'off';
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
