function uiTextHardwareOffsetSeparateCallback(hObject,handles)

% Gather target offset
targetValue = str2double(get(hObject,'String'));

% check if valid value, and correct if not
if targetValue < 0
    actualValue = 0;
elseif targetValue > 255
    actualValue = 255;
elseif targetValue-round(targetValue) ~= 0
    actualValue = round(targetValue);
else
    actualValue = targetValue;
end

% Note the valid offset value in the settings structure
handles.setting.hardwareOffset = actualValue;

% Show the valid offset in the UI edit box
set(hObject,'String',num2str(actualValue));

% Set valid hardware offset level on camera
handles.camHandle.BlackLevel.Offset.Set(int32(actualValue));

% Pass data back to the GUI
guidata(hObject,handles);