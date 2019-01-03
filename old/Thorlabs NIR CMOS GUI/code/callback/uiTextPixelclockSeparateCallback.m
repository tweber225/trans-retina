function uiTextPixelclockSeparateCallback(hObject,handles)

% Gather targeted pixel clock
targetPixelclock = str2double(get(hObject,'String'));

% Try setting target pixel clock, return actual pixel clock
actualPixelclock = set_pixelclock(handles.camHandle,targetPixelclock);

% Note actual pixel clock in settings structure
handles.settings.pixelclock = actualPixelclock;

% Show actual pixel clock in the edit box
set(handles.uiTextPixelclock,'String',actualPixelclock);

% Update framerate (in case allowable range has changed)
uiTextFramerateSeparateCallback(hObject,handles);

% displays updated by uiTextFramerate_Callback
% guidata already updated in above callback