function uiButtonAutoscaleLevelsSeparateCallback(hObject,handles)

% note the old display offsets
oldOffset = handles.displayOffset;
oldScale = handles.displayScale;

% Get the max and min in the current histogram data
Y = quantile(single(handles.retinaHist.Data(:)),[handles.settings.autoScaleLowQuantile,handles.settings.autoScaleHighQuantile]);
maxLevel = Y(2);
minLevel = Y(1);

% Update the min display level to the min in the histogram data
set(handles.uiTextDisplayLow,'String',num2str(minLevel));
uiTextDisplayLowSeparateCallback(handles.uiTextDisplayLow, handles);

% get back gui data set in line above
handles = guidata(hObject); 

% Update the max display level to the max in the histogram data
set(handles.uiTextDisplayHigh,'String',num2str(maxLevel));
uiTextDisplayHighSeparateCallback(handles.uiTextDisplayHigh, handles);

% get back gui data set in line above
handles = guidata(hObject); 

% Special case: when we're not in preview mode
% There's a static frame left over from a preview or capture mode, take the
% axes data from that old frame and autoscale it and redisplay
if ~get(handles.uiButtonPreview,'Value')
    oldFrame = double(get(handles.retinaImg, 'CData'));
    oldFrameRaw = (oldFrame/oldScale)+oldOffset;
    oldFrameNewScale = uint8((oldFrameRaw - handles.displayOffset)*handles.displayScale);
    set(handles.retinaImg, 'CData', oldFrameNewScale);
    drawnow;
    
    % pass the data off to GUI
    guidata(hObject,handles);
end