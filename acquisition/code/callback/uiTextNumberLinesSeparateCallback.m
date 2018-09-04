function uiTextNumberLinesSeparateCallback(hObject,handles)

% Gather targeted number of lines
targetLines = str2double(get(hObject,'String'));

% Since changing the # of lines changes memory allocation, need to check
% first whether we'll exceed the max allowable allocation size
bytesPerPixel = ceil(handles.settings.bitdepth/8);
frameBytes = targetLines*handles.constants.sensorXPixels*bytesPerPixel;
numChannels = sum(handles.settings.channelsEnable);
estimatedAllocationSizeMB = frameBytes*handles.settings.framesetsToCapture*numChannels/2^20; % denominator to convert from bytes to MB

if estimatedAllocationSizeMB > handles.settings.maxAllocationSize % note maxAllocationSize is always MB
    % If exceeds max allocation size then revert to old number of lines
    set(hObject,'String',num2str(handles.settings.numberLines));
    
    % Print warning
    disp('Tried to allocate more memory than max allowable!'); 
    
    % update GUI and get out
    guidata(hObject,handles); return 
end

% Gather dimensions of the sensor
xPix = handles.constants.sensorXPixels; 
yPix = handles.constants.sensorYPixels;

% Try setting the number of lines, return actual set number of lines
actualNumberLines = set_AOI_for_num_lines(handles.camHandle,targetLines,xPix,yPix);

% Note the actual number of set lines in settings structure
handles.settings.numberLines = actualNumberLines;

% Show the actual number of lines in the edit box
set(handles.uiTextNumberLines,'String',actualNumberLines);

% Redo framerate in case allowable range has changed
uiTextFramerateSeparateCallback(hObject,handles);
% get back gui data that might have been updated
handles = guidata(hObject); 

% And finally redo sequence allocation since new frame sizes are needed
[handles.sequenceList,handles.memoryIDList] = reallocate_sequence(handles.camHandle,handles.settings,handles.constants,handles.memoryIDList);

% Update timing/memory display
handles = update_timing_memory(handles);

% Update area on image frame used to calculate histogram (make sure we're
% not taking a range that exceeds frame indices, like what might happen if
% we drastically reduce frame number of lines)
handles.settings.histYRangeLow = round(handles.settings.numberLines/2-handles.constants.sensorYPixels/6);
if handles.settings.histYRangeLow < 1
    handles.settings.histYRangeLow = 1;
end
handles.settings.histYRangeHigh = round(handles.settings.numberLines/2+handles.constants.sensorYPixels/6);
if handles.settings.histYRangeHigh > handles.settings.numberLines
    handles.settings.histYRangeHigh = handles.settings.numberLines;
end

% Update GUI data to pass data back to GUI
guidata(hObject,handles);