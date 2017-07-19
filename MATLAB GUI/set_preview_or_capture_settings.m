function handles = set_preview_or_capture_settings(handles,settingType)
% Function sets all the relevant camera settings in the source object

if strcmp(settingType,'preview')
    
    % PREVIEW SETTINGS
    handles.srcObj.E2ExposureTime = handles.settingsStruct.prevExpTime;
    if handles.settingsStruct.prevBinSize == 1
        handles.srcObj.B1BinningHorizontal = '1';
        handles.srcObj.B2BinningVertical = '1';
    elseif handles.settingsStruct.prevBinSize == 2
        handles.srcObj.B1BinningHorizontal = '2';
        handles.srcObj.B2BinningVertical = '2';
    elseif handles.settingsStruct.prevBinSize == 3
        handles.srcObj.B1BinningHorizontal = '4';
        handles.srcObj.B2BinningVertical = '4';
    end
    if handles.settingsStruct.prevPixClock == 1
        handles.srcObj.PCPixelclock_Hz = '12000000';
    elseif handles.settingsStruct.prevPixClock == 2
        handles.srcObj.PCPixelclock_Hz = '24000000';
    end
    if handles.settingsStruct.prevGain == 1
        handles.srcObj.CFConversionFactor_e_count = '1.00';
    elseif handles.settingsStruct.prevGain == 2
        handles.srcObj.CFConversionFactor_e_count = '1.50';
    end
    if handles.settingsStruct.commIRMode == 0
        handles.srcObj.IRMode = 'off';
    elseif handles.settingsStruct.commIRMode == 1
        handles.srcObj.IRMode = 'on';
    end
    
    % Don't limit number of frames for continuous imaging in preview mode
    handles.vidObj.FramesPerTrigger = inf;
    
    % Disable settings that should not be changed during active preview
    % (everything except exposure time, basically)
    set(handles.prevBinSize,'Enable','off');
    set(handles.prevPixClock,'Enable','off');
    set(handles.prevGain,'Enable','off');
    set(handles.commIRMode,'Enable','off');
    set(handles.prevStartButton,'String','Stop');
    set(handles.selectLEDsEnable1,'Enable','off');
    set(handles.selectLEDsEnable2,'Enable','off');
    set(handles.selectLEDsEnable3,'Enable','off');
    set(handles.selectLEDsEnable4,'Enable','off');
    
elseif strcmp(settingType,'capture')
    
    % CAPTURE SETTINGS
    handles.srcObj.E2ExposureTime = handles.settingsStruct.capExpTime;
    if handles.settingsStruct.capBinSize == 1
        handles.srcObj.B1BinningHorizontal = '1';
        handles.srcObj.B2BinningVertical = '1';
    elseif handles.settingsStruct.capBinSize == 2
        handles.srcObj.B1BinningHorizontal = '2';
        handles.srcObj.B2BinningVertical = '2';
    elseif handles.settingsStruct.capBinSize == 3
        handles.srcObj.B1BinningHorizontal = '4';
        handles.srcObj.B2BinningVertical = '4';
    end
    if handles.settingsStruct.capPixClock == 1
        handles.srcObj.PCPixelclock_Hz = '12000000';
    elseif handles.settingsStruct.capPixClock == 2
        handles.srcObj.PCPixelclock_Hz = '24000000';
    end
    if handles.settingsStruct.capGain == 1
        handles.srcObj.CFConversionFactor_e_count = '1.00';
    elseif handles.settingsStruct.capGain == 2
        handles.srcObj.CFConversionFactor_e_count = '1.50';
    end
    if handles.settingsStruct.commIRMode == 0
        handles.srcObj.IRMode = 'off';
    elseif handles.settingsStruct.commIRMode == 1
        handles.srcObj.IRMode = 'on';
    end
    
    % Limit the capture acquistion's total number of frame (for two LED's
    % this is 2X the number of frames on the GUI)
    handles.vidObj.FramesPerTrigger = sum(handles.LEDsToEnable,2)*handles.settingsStruct.capNumFrames;
    
    % Disable settings that should not be changed during active preview
    set(handles.capExpTime,'Enable','off');
    set(handles.capBinSize,'Enable','off');
    set(handles.capPixClock,'Enable','off');
    set(handles.capGain,'Enable','off');
    set(handles.capNumFrames,'Enable','off');
    set(handles.capLockSettings,'Enable','off');
    set(handles.commIRMode,'Enable','off');
    set(handles.commAutoScale,'Enable','off');
    set(handles.commXShift,'Enable','off');
    set(handles.commRTStats,'Enable','off');
    set(handles.commRTHistogram,'Enable','off');
    set(handles.commStatHistInCenter,'Enable','off');
    set(handles.saveBaseName,'Enable','off');
    set(handles.saveSettings,'Enable','off');
    set(handles.saveFrameTimes,'Enable','off');
    set(handles.selectLEDsEnable1,'Enable','off');
    set(handles.selectLEDsEnable2,'Enable','off');
    set(handles.selectLEDsEnable3,'Enable','off');
    set(handles.selectLEDsEnable4,'Enable','off');
    set(handles.selectLEDsShow,'Enable','off');


    % Change the start button's string
    set(handles.capStartButton,'String','Abort');
end