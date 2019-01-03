function start_up_GUI(hObject,handles,camName,numDigitalPins)

% INITIALIZE ANDOR SDK 3 LIBRARY, CAMERA HANDLE, COOLING, AND DAQ SYSTEM
[handles.camHandle,cameraInfoString] = initialize_SDK_and_camera;
start_sensor_cooling(handles.camHandle)
handles.daqHandle = initialize_DAQ(numDigitalPins);

% LOAD & SET DEFAULT SETTINGS
handles.jumpPreviewToCapture = 0; % flag to request jumping straight into a capture from preview mode
handles = set_default_settings(handles,camName);
% Add camera info to settings structure
handles.settings.cameraInfo = cameraInfoString;
% Next couple lines to scale image data into correct levels for display
handles.displayOffset = handles.settings.displayRangeLow*double(handles.settings.rollingAverageFrames);
handles.displayScale = 256/((handles.settings.displayRangeHigh-handles.settings.displayRangeLow)*double(handles.settings.rollingAverageFrames));

% ALLOCATE IMAGE BUFFER MEMORY
handles = allocate_series_buffer(handles);

% UPDATE TIMING & MEMORY DISPLAYS
handles = update_timing_memory(handles);

% RENDER BLANK FRAME
blankFrameHeight = handles.settings.histYRangeHigh - handles.settings.histYRangeLow + 1; % use the same crop range as for histogram calculation
blankFrameWidth = handles.settings.histXRangeHigh - handles.settings.histXRangeLow + 1;
handles.blankFrame = zeros([blankFrameHeight,blankFrameWidth],'uint8'); %always show 8-bit images on screen
imshow(handles.blankFrame, [0, 255], 'Parent', handles.retinaAxis)
handles.retinaImg = get(handles.retinaAxis,'Children');

% RENDER HISTOGRAM
handles.histogramBinEdges = linspace(0,2^handles.settings.bitDepth,handles.settings.histogramBins+1);
handles.retinaHist = histogram(uint16(handles.blankFrame),handles.histogramBinEdges,'Parent',handles.histAxis); %histogram is always 16-bit
handles.histAxis.XLim = [handles.histogramBinEdges(1) handles.histogramBinEdges(end)];
handles.histAxis.YScale = 'log';
handles.histAxis.YLim = [1 10^4];

% UPDATE GUI HANDLES STRUCT
% to pass all these updates along
guidata(hObject,handles)

