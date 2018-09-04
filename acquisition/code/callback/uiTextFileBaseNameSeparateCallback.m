function uiTextFileBaseNameSeparateCallback(hObject,handles)

% get the new file base name and note it in the settings structure
handles.settings.fileBaseName = get(hObject,'String');

% reset the capture number
handles.settings.captureNumber = 1; % reset capture number

% check whether the base name + capture number folder exists, advance the
% capture number until finding a folder that does not exist
handles = advance_capture_number(handles);

% Pass data back to the GUI
guidata(hObject,handles);
