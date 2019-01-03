function uiTextFramesetsToCaptureSeparateCallback(hObject,handles)

% Gather target framesets to capture
targetFramesetsToCapture = round(str2double(get(hObject,'String')));
handles.settings.framesetsToCapture = targetFramesetsToCapture;

% Try reallocation of framesets - should catch any over-allocation
% automatically
handles = reallocate_series_buffer(handles);

% Updating the timing displays
handles = update_timing_memory(handles);


% Show the actual set number in UI textbox
set(hObject,'String',handles.settings.framesetsToCapture);


% Pass data back to the GUI
guidata(hObject,handles);