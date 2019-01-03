function handles = disable_controls(handles)

% clock
set(handles.uiTextPixelclock,'Enable','off');

% # lines
set(handles.uiTextNumberLines,'Enable','off');

% channels to enable
set(handles.uiCheckChannel1,'Enable','off');
set(handles.uiCheckChannel2,'Enable','off');
set(handles.uiCheckChannel3,'Enable','off');
set(handles.uiCheckChannel4,'Enable','off');
set(handles.uiCheckChannel5,'Enable','off');
set(handles.uiCheckChannel6,'Enable','off');

% bit depth
set(handles.uiSelectBitdepth,'Enable','off');

% # framesets
set(handles.uiTextFramesetsToCapture,'Enable','off');



