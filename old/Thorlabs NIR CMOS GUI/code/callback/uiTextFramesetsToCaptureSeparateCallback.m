function uiTextFramesetsToCaptureSeparateCallback(hObject,handles)

% Gather target framesets to capture
targetFramesetsToCapture = round(str2double(get(hObject,'String')));

% Check that we're not exceeding max allocation size
bytesPerPixel = ceil(handles.settings.bitdepth/8);
bytesPerFrame = double(handles.settings.numberLines)*handles.constants.sensorXPixels*bytesPerPixel;
numChannels = sum(handles.settings.channelsEnable);
estimatedAllocationSizeMB = bytesPerFrame*targetFramesetsToCapture*numChannels/2^20;
if estimatedAllocationSizeMB > handles.settings.maxAllocationSize
    % if new frames to capture exceeds max allowable allocation, then
    % revert back to old framesets to capture
    set(hObject,'String',handles.settings.framesetsToCapture);
    
    % print a warning
    disp('Tried to allocate more memory than max allowable!'); 
    
    % update GUI and get out
    guidata(hObject,handles); return 
end

% Note the actual set number of framesets to capture in setting structure
handles.settings.framesetsToCapture = targetFramesetsToCapture;

% Show the actual set number of UI textbox
set(hObject,'String',targetFramesetsToCapture);

% Adjust the allocation
[handles.sequenceList,handles.memoryIDList] = adjust_sequence_allocation(handles.camHandle,handles.settings,handles.constants,handles.memoryIDList);

% Update the timing and memory display
handles = update_timing_memory(handles);

% Pass data back to the GUI
guidata(hObject,handles);