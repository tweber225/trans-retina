function uiCheckContinuousAutoScaleSeparateCallback(hObject,handles)

% Get the new value
continuousAutoScale = get(hObject,'Value');

% Note it in the settings structure
handles.settings.continuousAutoScale = continuousAutoScale;

% Pass data back to GUI
guidata(hObject,handles); 