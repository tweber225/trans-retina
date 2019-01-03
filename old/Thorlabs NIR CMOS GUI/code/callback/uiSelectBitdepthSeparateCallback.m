function uiSelectBitdepthSeparateCallback(hObject,handles)

% Get all the options for bit depth
bitdepthOptions = cellstr(get(handles.uiSelectBitdepth,'String'));
bitdepthIndex = 1:numel(bitdepthOptions);

% Gather the target bitdepth
targetBitdepth = str2double(bitdepthOptions{get(hObject,'Value')});

% Since changing the bit depth changes memory allocation, need to check
% first whether we'll exceed the max allowable allocation size
bytesPerPixel = ceil(targetBitdepth/8);
frameBytes = handles.settings.numberLines*handles.constants.sensorXPixels*bytesPerPixel;
numChannels = sum(handles.settings.channelsEnable);
estimatedAllocationSizeMB = frameBytes*handles.settings.framesetsToCapture*numChannels/2^20; % denominator to convert from bytes to MB

if estimatedAllocationSizeMB > handles.settings.maxAllocationSize
    % If the estimated allocation size exceeds limits, revert back to old
    % bit depth
    set(hObject,'Value',abs(get(hObject,'Value')-3)); % set to old bitdepth, this only works for 2 bit depths options
    
    % Print warning
    disp('Tried to allocate more memory than max allowable!'); 
    
    % update GUI and get out
    guidata(hObject,handles); return 
end

% Try setting bitdepth and return actual set bitdepth
actualBitdepth = set_bitdepth(handles.camHandle,targetBitdepth);

% Note actual set bitdepth in settings structure
handles.settings.bitdepth = actualBitdepth;

% Show actual bit depth in edit box
set(handles.uiSelectBitdepth,'Value',bitdepthIndex(strcmp(bitdepthOptions,num2str(actualBitdepth))));

% Update "colormode" used in copying data out of the camera API
if handles.settings.bitdepth == 8
    handles.colorMode = uEye.Defines.ColorMode.Mono8; 
elseif handles.settings.bitdepth == 10
    handles.colorMode = uEye.Defines.ColorMode.Mono10; 
end

% New bitdepth set, now need to reallocate sequence
[handles.sequenceList,handles.memoryIDList] = reallocate_sequence(handles.camHandle,handles.settings,handles.constants,handles.memoryIDList);

% Update timing and memory display
handles = update_timing_memory(handles);

% Update histogram parameters and data
handles.histogramBinEdges = linspace(0,2^handles.settings.bitdepth,handles.constants.histogramBins);
handles.retinaHist = histogram(uint16(handles.blankFrame),handles.histogramBinEdges,'Parent',handles.histAxis); %histogram is always 16-bit
handles.histAxis.XLim = [handles.histogramBinEdges(1) handles.histogramBinEdges(end)];
handles.histAxis.YScale = 'log';

% redraw the histogram
drawnow;

% Update the display white/black levels
if actualBitdepth == 8 % must do these in different orders
    set(handles.uiTextDisplayLow,'String',num2str(handles.settings.displayRangeLow*(1/4)));
    uiTextDisplayLowSeparateCallback(handles.uiTextDisplayLow, handles);
    handles = guidata(hObject); % get back gui data set in line above
    set(handles.uiTextDisplayHigh,'String',num2str(handles.settings.displayRangeHigh*(1/4)));
    uiTextDisplayHighSeparateCallback(handles.uiTextDisplayHigh, handles);
elseif actualBitdepth == 10
    set(handles.uiTextDisplayHigh,'String',num2str(handles.settings.displayRangeHigh*(4)));
    uiTextDisplayHighSeparateCallback(handles.uiTextDisplayHigh, handles);
    handles = guidata(hObject); % get back gui data set in line above
    set(handles.uiTextDisplayLow,'String',num2str(handles.settings.displayRangeLow*(4)));
    uiTextDisplayLowSeparateCallback(handles.uiTextDisplayLow, handles);
end
