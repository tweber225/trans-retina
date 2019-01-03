function uiSelectPreAmpSeparateCallback(hObject,handles)

% Gather the selected target pre amp state from available options
preAmpOptions = cellstr(get(handles.uiSelectPreAmp,'String'));
targetPreAmp = preAmpOptions{get(handles.uiSelectPreAmp,'Value')};

% Try setting the pre amp and bit depth and encoding
[actualBitDepth,actualPixelEncoding] = set_preamp_bitdepth_encoding(handles.camHandle,targetPreAmp);

% Note the numerical bit depth and encoding in settings structure
handles.settings.bitDepth = actualBitDepth;
handles.settings.pixelEncoding = actualPixelEncoding;


% Gain state affects bit depth and encoding and therefore size of buffer,
% so reallocate buffer
handles = reallocate_series_buffer(handles);

% Also affects the transfer rate, so update the timing displays
handles = update_timing_memory(handles);

% Re-do histogram
handles.histogramBinEdges = linspace(0,2^handles.settings.bitDepth,handles.settings.histogramBins+1);
handles.retinaHist = histogram(uint16(handles.blankFrame),handles.histogramBinEdges,'Parent',handles.histAxis); %histogram is always 16-bit
handles.histAxis.XLim = [handles.histogramBinEdges(1) handles.histogramBinEdges(end)];
handles.histAxis.YScale = 'log';
handles.histAxis.YLim = [1 10^4];

% Pass data along to GUI
guidata(hObject,handles);