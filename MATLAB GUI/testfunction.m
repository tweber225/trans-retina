
handles.settingsStruct.blackLevelLED1= newLims(1);
handles.settingsStruct.whiteLevelLED1 = newLims(2);
set(handles.LED1BlackValueIndicator,'String',['Black: ' num2str(round(handles.settingsStruct.blackLevelLED1))]);
set(handles.LED1WhiteValueIndicator,'String',['White: ' num2str(round(handles.settingsStruct.whiteLevelLED1))]);

blankLims = [0, (2^(handles.settingsStruct.constCameraBits)-1)];