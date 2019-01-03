function uiSelectRollingAverageFramesSeparateCallback(hObject,handles)

% Get the available options--powers of 2 
rollingAverageFramesOptions = cellstr(get(handles.uiSelectRollingAverageFrames,'String'));

% Gather the target value
actualRollingAverageFrames = int32(str2double(rollingAverageFramesOptions{get(hObject,'Value')}));

% Note the target/actual value in setting structure (target is valid since
% we've selected from a finite list of options)
handles.settings.rollingAverageFrames = actualRollingAverageFrames;

% Update the offset and scale settings (to convert from summed buffer to
% 8bit image to show on GUI)
handles.displayOffset = handles.settings.displayRangeLow*double(handles.settings.rollingAverageFrames); 
handles.displayScale = 256/((handles.settings.displayRangeHigh-handles.settings.displayRangeLow)*double(handles.settings.rollingAverageFrames));

% Pass data back to GUI
guidata(hObject,handles); 