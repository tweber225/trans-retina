function handles = disable_controls(handles)
% Disable some of the controls during preview mode

% Framerate change can't be changed
set(handles.uiTextFrameRate,'Enable','off');

% Width/Height can't be changed
set(handles.uiTextNumCols,'Enable','off');
set(handles.uiTextNumRows,'Enable','off');

% Pre amp control can't be changed
set(handles.uiSelectPreAmp,'Enable','off');

% Number of channels is fixed
%set(handles.uiCheckChannel1,'Enable','off'); -- always disabled
set(handles.uiCheckChannel2,'Enable','off');
set(handles.uiCheckChannel3,'Enable','off');
set(handles.uiCheckChannel4,'Enable','off');
set(handles.uiCheckChannel5,'Enable','off');
set(handles.uiCheckChannel6,'Enable','off');

% # framesets can't be changed
set(handles.uiTextFramesetsToCapture,'Enable','off');



