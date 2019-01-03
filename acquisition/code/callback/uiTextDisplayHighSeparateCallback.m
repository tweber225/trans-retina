function uiTextDisplayHighSeparateCallback(hObject,handles)

% get new target value
targetValue = str2double(get(hObject,'String'));

% Check if in valid range
if targetValue > 2^handles.settings.bitDepth 
    targetValue = 2^handles.settings.bitDepth; 
elseif targetValue <= handles.settings.displayRangeLow
    targetValue = handles.settings.displayRangeLow+1;
end

% Round to integer
actualValue = round(targetValue); 

% Show the new value in edit box
set(hObject,'String',num2str(actualValue)); 

% Note the new value in settings structure
handles.settings.displayRangeHigh = actualValue;

% Update scale factor (used to convert summed&averaged 16 bit
% frame data to 8 bit used to display on GUI)
handles.displayScale = 256/((handles.settings.displayRangeHigh-handles.settings.displayRangeLow)*double(handles.settings.rollingAverageFrames)); % update display scale

% pass the data off to GUI
guidata(hObject,handles);
