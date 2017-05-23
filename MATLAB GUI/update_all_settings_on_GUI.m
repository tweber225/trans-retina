function handles = update_all_settings_on_GUI(handles)
% Function sets all the GUI settings to those listed in handles.settingStruct

% PREVIEW SETTINGS
set(handles.prevExpTime,'String',handles.settingsStruct.prevExpTime);
set(handles.prevBinSize,'Value',handles.settingsStruct.prevBinSize);
set(handles.prevPixClock,'Value',handles.settingsStruct.prevPixClock);
set(handles.prevGain,'Value',handles.settingsStruct.prevGain);

% CAPTURE SETTINGS
set(handles.capExpTime,'String',handles.settingsStruct.capExpTime);
set(handles.capBinSize,'Value',handles.settingsStruct.capBinSize);
set(handles.capPixClock,'Value',handles.settingsStruct.capPixClock);
set(handles.capGain,'Value',handles.settingsStruct.capGain);
set(handles.capNumFrames,'String',handles.settingsStruct.capNumFrames);

% COMMON SETTINGS
set(handles.commIRMode,'Value',handles.settingsStruct.commIRMode);
set(handles.commAutoScale,'Value',handles.settingsStruct.commAutoScale);
set(handles.commXShift,'String',handles.settingsStruct.commXShift);
set(handles.commRTStats,'Value',handles.settingsStruct.commRTStats);
set(handles.commRTHistogram,'Value',handles.settingsStruct.commRTHistogram);

% SAVE SETTINGS
set(handles.saveBaseName,'String',handles.settingsStruct.saveBaseName);
set(handles.saveSettings,'Value',handles.settingsStruct.saveSettings);