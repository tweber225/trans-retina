function uiCheckDigitalZoomSeparateCallback(hObject,handles)

% Get the new value
digitalZoom = get(hObject,'Value');

% Note it in the settings structure
handles.settings.digitalZoom = digitalZoom;

% Pass data back to GUI
guidata(hObject,handles); 