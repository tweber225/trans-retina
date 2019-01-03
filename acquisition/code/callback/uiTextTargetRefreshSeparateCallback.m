function uiTextTargetRefreshSeparateCallback(hObject,handles)

% Make sure it's a valid number
targetRefresh = str2double(get(hObject,'String'));
if targetRefresh < 1
    targetRefresh = 1;
end
if targetRefresh > 25
    targetRefresh = 25;
end

% When Preview or Capture buttons are pressed, actual rate will be updated

% Put into settings structure
handles.settings.targetRefresh = targetRefresh;

% Put into UI textbox
set(handles.uiTextTargetRefresh,'String',num2str(targetRefresh));

% Pass information back to GUI for later use
guidata(hObject,handles);