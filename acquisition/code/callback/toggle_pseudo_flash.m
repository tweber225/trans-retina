function toggle_pseudo_flash(hObject,handles)

% determine if enabling or disabling a pseudo flash
enableFlash = get(hObject,'Value');

% Update in settings struct
handles.settings.flash = enableFlash;

% And clear setting that records what frame flash started (this is set in
% capture mode actually, setting to -1 enables capture mode to note it)
handles.settings.flashStartFrame = int32(-1); %-1 means that it hasn't been set

% Determine whether we are currently in an acquistion
if get(handles.uiButtonCapture,'Value') || get(handles.uiButtonPreview,'Value')
    acqOnGoing = 1;
else
    acqOnGoing = 0;
end

% Output the new set of digital values
digitalOutputScan = [acqOnGoing, handles.settings.flash, handles.settings.channelsEnable(2:end)];
outputSingleScan(handles.daqHandle,digitalOutputScan);

% Pass data back to GUI
guidata(hObject,handles);

