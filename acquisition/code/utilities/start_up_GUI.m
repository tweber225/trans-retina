function start_up_GUI(hObject,handles,camName,camNumber,numDigitalPins)

% INITIALIZE uEYE .NET ASSEMBLY AND DAQ SYSTEM
handles.camHandle = initialize_NET_camhandle_displaymode_shutter_trigger_GPIO(camNumber);
handles.daqHandle = initialize_DAQ(numDigitalPins);
disable_hotpixel_correction_auto_offset(handles.camHandle)

% LOAD & SET DEFAULT SETTINGS, CONSTANTS
handles.constants = set_constants(camName);
handles.jumpPreviewToCapture = 0; % flag to request jumping straight into a capture from preview mode
handles = set_default_settings(handles,camName);
handles.displayOffset = handles.settings.displayRangeLow*double(handles.settings.rollingAverageFrames);
handles.displayScale = 256/((handles.settings.displayRangeHigh-handles.settings.displayRangeLow)*double(handles.settings.rollingAverageFrames));
if handles.settings.bitdepth == 8
    handles.colorMode = uEye.Defines.ColorMode.Mono8; 
elseif handles.settings.bitdepth == 10
    handles.colorMode = uEye.Defines.ColorMode.Mono10; 
end

% ALLOCATE IMAGE SEQUENCE MEMORY
[handles.sequenceList,handles.memoryIDList] = allocate_sequence(handles.camHandle,handles.settings,handles.constants);

% UPDATE TIMING&MEMORY DISPLAYS
handles = update_timing_memory(handles);

% RENDER BLANK FRAME
handles.blankFrame = zeros([handles.settings.numberLines,handles.constants.sensorXPixels],'uint8'); %always show 8-bit images on screen
imshow(handles.blankFrame, [0, 256], 'Parent', handles.retinaAxis)
handles.retinaImg = get(handles.retinaAxis,'Children');

% RENDER HISTOGRAM
handles.histogramBinEdges = linspace(0,2^handles.settings.bitdepth,handles.constants.histogramBins);
handles.retinaHist = histogram(uint16(handles.blankFrame),handles.histogramBinEdges,'Parent',handles.histAxis); %histogram is always 16-bit
handles.histAxis.XLim = [handles.histogramBinEdges(1) handles.histogramBinEdges(end)];
handles.histAxis.YScale = 'log';
handles.histAxis.YLim = [1 10^4];

% UPDATE GUI HANDLES STRUCT
guidata(hObject,handles)

