function uiTextFramerateSeparateCallback(hObject,handles)

% Get the new requested frame rate from GUI
targetFramerate = str2double(get(hObject,'String'));

% Try to set the new framerate and return actual set framerate. Note: this
% also sets exposure time to some fraction of the frame period
[actualFramerate,~] = set_framerate(handles.camHandle,targetFramerate,handles.constants.fracFramePeriodForExposure);

% Put the actual framerate into our settings structure
handles.settings.framerate = actualFramerate;

% Show actual framerate in the edit box
set(handles.uiTextFramerate,'String',num2str(0.1*round(actualFramerate*10)));

% also adjust sequence allocation (mostly the last few buffer frames) 
if ~get(handles.uiButtonPreview,'Value') %... but don't if in the middle of live mode since we're using the allocation!
    [handles.sequenceList,handles.memoryIDList] = adjust_sequence_allocation(handles.camHandle,handles.settings,handles.constants,handles.memoryIDList);
end

% Update timing information display
handles = update_timing_memory(handles);

% Pass information back to GUI for later use
guidata(hObject,handles);