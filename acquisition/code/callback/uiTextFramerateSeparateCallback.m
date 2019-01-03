function uiTextFrameRateSeparateCallback(hObject,handles)

% Get the new requested frame rate from GUI
targetFrameRate = str2double(get(hObject,'String'));

% Try to set the new framerate and return actual set framerate. Note: this
% also sets exposure time to some fraction of the frame period
actualFrameRate = set_framerate(handles.camHandle,targetFrameRate,handles.settings.numRows);

% Put the actual framerate into our settings structure
handles.settings.frameRate = actualFrameRate;

% Show actual frame rate in the edit box
set(handles.uiTextFrameRate,'String',num2str(0.1*round(actualFrameRate*10)));

% Update timing information display
handles = update_timing_memory(handles);

% Pass information back to GUI for later use
guidata(hObject,handles);