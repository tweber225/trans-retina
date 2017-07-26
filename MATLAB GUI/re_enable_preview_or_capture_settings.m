function handles = re_enable_preview_or_capture_settings(handles,settingType)
% Function sets all the relevant camera settings in the source object

% PREVIEW SETTINGS
if strcmp(settingType,'preview')
    
    % Enable settings that were disabled during preview
    set(handles.prevBinSize,'Enable','on');
    set(handles.prevPixClock,'Enable','on');
    set(handles.prevGain,'Enable','on');
    set(handles.commIRMode,'Enable','on');
    set(handles.prevStartButton,'String','Start Preview');
    set(handles.selectLEDsEnable1,'Enable','on');
    set(handles.selectLEDsEnable2,'Enable','on');
    set(handles.selectLEDsEnable3,'Enable','on');
    set(handles.selectLEDsEnable4,'Enable','on');
    
elseif strcmp(settingType,'capture')
    
    % Enable settings that were disabled during preview
    if handles.settingsStruct.capLockSettings == 0
        set(handles.capExpTime,'Enable','on');
        set(handles.capBinSize,'Enable','on');
        set(handles.capPixClock,'Enable','on');
        set(handles.capGain,'Enable','on');
    end
    set(handles.capNumFrames,'Enable','on');
    set(handles.capLockSettings,'Enable','on');
    set(handles.commIRMode,'Enable','on');
    set(handles.commAutoScale,'Enable','on');
    set(handles.commXShift,'Enable','on');
    set(handles.commRTStats,'Enable','on');
    set(handles.commRTHistogram,'Enable','on');
    set(handles.commStatHistInCenter,'Enable','on');
    set(handles.saveBaseName,'Enable','on');
    set(handles.saveSettings,'Enable','on');
    set(handles.saveFrameTimes,'Enable','on');
    set(handles.selectLEDsEnable1,'Enable','on');
    set(handles.selectLEDsEnable2,'Enable','on');
    set(handles.selectLEDsEnable3,'Enable','on');
    set(handles.selectLEDsEnable4,'Enable','on');
    if handles.settingsStruct.selectLEDsLockCap == 0
        set(handles.capLEDsEnable1,'Enable','on');
        set(handles.capLEDsEnable2,'Enable','on');
        set(handles.capLEDsEnable3,'Enable','on');
        set(handles.capLEDsEnable4,'Enable','on');
        set(handles.selectLEDsShow,'Enable','on');
    end
    
    set(handles.capStartButton,'Value',0);
    set(handles.capStartButton,'String','Start Capture');
    
end