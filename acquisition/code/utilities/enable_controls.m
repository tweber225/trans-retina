function handles = enable_controls(handles)
% Enable some of the controls after preview mode

% Framerate change
set(handles.uiTextFrameRate,'Enable','on');

% Width/Height can't be changed
set(handles.uiTextNumCols,'Enable','on');
set(handles.uiTextNumRows,'Enable','on');

% Pre amp control can't be changed
set(handles.uiSelectPreAmp,'Enable','on');

% Number of channels is fixed
%set(handles.uiCheckChannel1,'Enable','on'); -- always disabled
set(handles.uiCheckChannel2,'Enable','on');
set(handles.uiCheckChannel3,'Enable','on');
set(handles.uiCheckChannel4,'Enable','on');
set(handles.uiCheckChannel5,'Enable','on');
set(handles.uiCheckChannel6,'Enable','on');

% # framesets can't be changed
set(handles.uiTextFramesetsToCapture,'Enable','on');