function handles = enable_all_controls(handles)

% clock
set(handles.uiTextPixelclock,'Enable','on');

% # lines
set(handles.uiTextNumberLines,'Enable','on');

% channels to enable
set(handles.uiCheckChannel1,'Enable','on');
set(handles.uiCheckChannel2,'Enable','on');
set(handles.uiCheckChannel3,'Enable','on');
set(handles.uiCheckChannel4,'Enable','on');
set(handles.uiCheckChannel5,'Enable','on');
set(handles.uiCheckChannel6,'Enable','on');

% bit depth
set(handles.uiSelectBitdepth,'Enable','on');

% # framesets
set(handles.uiTextFramesetsToCapture,'Enable','on');

%capture-specific disables
%framerate
set(handles.uiTextFramerate,'Enable','on');

% gainboost
set(handles.uiCheckGainBoost,'Enable','on');

% select channel
set(handles.uiSelectChannel,'Enable','on');

% hardware offset
set(handles.uiTextHardwareOffset,'Enable','on');

% filebasename
set(handles.uiTextFileBaseName,'Enable','on');

% Frame averaging
set(handles.uiSelectRollingAverageFrames,'Enable','on');

% Preview button
set(handles.uiButtonPreview,'Enable','on');