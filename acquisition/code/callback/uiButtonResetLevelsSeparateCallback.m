function uiButtonResetLevelsSeparateCallback(hObject,handles)

% First turn off continuous auto scale if on
if handles.settings.continuousAutoScale == 1
    set(handles.uiCheckContinuousAutoScale,'Value',0');
    uiCheckContinuousAutoScaleSeparateCallback(handles.uiCheckContinuousAutoScale,handles);
    % Get the updated GUI data
    handles = guidata(hObject); 
end

% note the old display offsets
oldOffset = handles.displayOffset;
oldScale = handles.displayScale;

% Update the min display level to 0
set(handles.uiTextDisplayLow,'String',num2str(0));
uiTextDisplayLowSeparateCallback(handles.uiTextDisplayLow, handles);

% get back gui data set in line above
handles = guidata(hObject);

% Update the max display level to the max for given bitdepth
set(handles.uiTextDisplayHigh,'String',num2str(2^handles.settings.bitDepth));
uiTextDisplayHighSeparateCallback(handles.uiTextDisplayHigh, handles);

% get back gui data set in line above
handles = guidata(hObject); 

% If we're not in preview mode, re-scale data and display it on GUI, if in
% preview mode, soon enough a new frame will be available and will
% displayed with approriate rescaling
if ~get(handles.uiButtonPreview,'Value')
    oldFrame = double(get(handles.retinaImg, 'CData'));
    oldFrameRaw = (oldFrame/oldScale)+oldOffset;
    oldFrameNewScale = uint8((oldFrameRaw - handles.displayOffset)*handles.displayScale);
    set(handles.retinaImg, 'CData', oldFrameNewScale);
    drawnow;
    
    % pass the data off to GUI
    guidata(hObject,handles);
end