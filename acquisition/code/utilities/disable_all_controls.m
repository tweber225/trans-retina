function handles = disable_all_controls(handles)
% During acquistion no settings can change

% Framerate
set(handles.uiTextFrameRate,'Enable','off');

% AOI
set(handles.uiTextNumCols,'Enable','off');
set(handles.uiTextNumCols,'Enable','off');

% Pre amp gain control
set(handles.uiSelectPreAmp,'Enable','off')

% select channel
set(handles.uiSelectChannel,'Enable','off');

% channels to enable
%set(handles.uiCheckChannel1,'Enable','off');
set(handles.uiCheckChannel2,'Enable','off');
set(handles.uiCheckChannel3,'Enable','off');
set(handles.uiCheckChannel4,'Enable','off');
set(handles.uiCheckChannel5,'Enable','off');
set(handles.uiCheckChannel6,'Enable','off');

% Frame averaging
set(handles.uiSelectRollingAverageFrames,'Enable','off');

% Target Refresh Rate
set(handles.uiTextTargetRefresh,'Enable','off');

% Reset levels
set(handles.uiButtonResetLevels,'Enable','off');

% Autoscale levels
set(handles.uiButtonAutoscaleLevels,'Enable','off');

% Continuous auto scaling
set(handles.uiCheckContinuousAutoScale,'Enable','off');

% Number of framesets
set(handles.uiTextFramesetsToCapture,'Enable','off');

% filebasename
set(handles.uiTextFileBaseName,'Enable','off');

% Display Ranges
set(handles.uiTextDisplayLow,'Enable','off');
set(handles.uiTextDisplayHigh,'Enable','off');

% Preview button
set(handles.uiButtonPreview,'Enable','off');
