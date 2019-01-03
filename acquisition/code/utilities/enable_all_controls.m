function handles = enable_all_controls(handles)
% During acquistion no settings can change, enable them again here

% Framerate
set(handles.uiTextFrameRate,'Enable','on');

% AOI
set(handles.uiTextNumCols,'Enable','on');
set(handles.uiTextNumCols,'Enable','on');

% Pre amp gain control
set(handles.uiSelectPreAmp,'Enable','on')

% select channel
set(handles.uiSelectChannel,'Enable','on');

% channels to enable
%set(handles.uiCheckChannel1,'Enable','on');
set(handles.uiCheckChannel2,'Enable','on');
set(handles.uiCheckChannel3,'Enable','on');
set(handles.uiCheckChannel4,'Enable','on');
set(handles.uiCheckChannel5,'Enable','on');
set(handles.uiCheckChannel6,'Enable','on');

% Frame averaging
set(handles.uiSelectRollingAverageFrames,'Enable','on');

% Target Refresh Rate
set(handles.uiTextTargetRefresh,'Enable','on');

% Reset levels
set(handles.uiButtonResetLevels,'Enable','on');

% Autoscale levels
set(handles.uiButtonAutoscaleLevels,'Enable','on');

% Continuous auto scaling
set(handles.uiCheckContinuousAutoScale,'Enable','on');

% Number of framesets
set(handles.uiTextFramesetsToCapture,'Enable','on');

% filebasename
set(handles.uiTextFileBaseName,'Enable','on');

% Display Ranges
set(handles.uiTextDisplayLow,'Enable','on');
set(handles.uiTextDisplayHigh,'Enable','on');

% Preview button
set(handles.uiButtonPreview,'Enable','on');
