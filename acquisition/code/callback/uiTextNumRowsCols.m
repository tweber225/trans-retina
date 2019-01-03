function uiTextNumRowsCols(hObject,handles)

% Gather targeted numbers of rows and columns
targetNumRows = str2double(get(handles.uiTextNumRows,'String'));
targetNumCols = str2double(get(handles.uiTextNumCols,'String'));

% Try setting the number of cols/rows, return actual set number of cols/rows
[actualNumCols,actualNumRows] = set_AOI_for_num_cols_rows(handles,targetNumCols,targetNumRows);

% Note the actual number of set lines in settings structure
handles.settings.numCols = actualNumCols;
handles.settings.numRows = actualNumRows;

% Show the actual numbers in the edit box
set(handles.uiTextNumCols,'String',actualNumCols);
set(handles.uiTextNumRows,'String',actualNumRows);


% Redo framerate in case allowable range has changed
uiTextFrameRateSeparateCallback(handles.uiTextFrameRate,handles);
% get back gui data that might have been updated
handles = guidata(hObject); 

% And finally redo sequence allocation since new frame sizes are needed
handles = reallocate_series_buffer(handles);

% Update timing/memory display
handles = update_timing_memory(handles);

% Update area on image frame used to calculate histogram and display in
% preview (make sure we're not taking a range that exceeds frame indices,
% like what might happen if we drastically reduce frame number of lines)
handles.settings.histYRangeLow = round(handles.settings.initialNumRows*(1/2-1/(2*sqrt(2)))) - round((handles.settings.initialNumRows-actualNumRows)/2);
if handles.settings.histYRangeLow < 1
    handles.settings.histYRangeLow = 1;
end
handles.settings.histYRangeHigh = round(handles.settings.initialNumRows*(1/2+1/(2*sqrt(2)))) - round((handles.settings.initialNumRows-actualNumRows)/2);
if handles.settings.histYRangeHigh > handles.settings.numRows
    handles.settings.histYRangeHigh = handles.settings.numRows;
end
handles.settings.histXRangeLow = round(handles.settings.initialNumCols*(1/2-1/(2*sqrt(2)))) - round((handles.settings.initialNumCols-actualNumCols)/2);
if handles.settings.histXRangeLow < 1
    handles.settings.histXRangeLow = 1;
end
handles.settings.histXRangeHigh = round(handles.settings.initialNumCols*(1/2+1/(2*sqrt(2)))) - round((handles.settings.initialNumCols-actualNumCols)/2);
if handles.settings.histXRangeHigh > handles.settings.numCols
    handles.settings.histXRangeHigh = handles.settings.numCols;
end

% Update GUI data to pass data back to GUI
guidata(hObject,handles);