function uiTextDisplayLowSeparateCallback(hObject,handles)

% get new target value
targetValue = str2double(get(hObject,'String'));

% Check if in valid range
if targetValue < 0 
    targetValue = 0; 
elseif targetValue >= handles.settings.displayRangeHigh
    targetValue = handles.settings.displayRangeHigh-1;
end
% Round to integer value
actualValue = round(targetValue); 

% Show the new value in edit box
set(hObject,'String',num2str(actualValue)); % set new

% Note the new value in settings structure
handles.settings.displayRangeLow = actualValue;

% Update offset and scale factors (used to convert summed&averaged 16 bit
% frame data to 8 bit used to display on GUI)
handles.displayOffset = handles.settings.displayRangeLow*double(handles.settings.rollingAverageFrames); % update display offset and scale
handles.displayScale = 256/((handles.settings.displayRangeHigh-handles.settings.displayRangeLow)*double(handles.settings.rollingAverageFrames));

% pass the data off to GUI
guidata(hObject,handles);