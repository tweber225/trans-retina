function handles = set_default_settings(handles,camName)

% Load default settings for this camera
handles.settings = default_settings(camName);

% With the settings values, now set the settings that need to be set and
% updated on GUI (roughly in order of default settings file)

% Set electronic shutter mode - Don't need to for Zyla 4.2
%rc = AT_SetEnumString(handles.camHandle,'ElectronicShutterMode',handles.settings.electronicShutterMode);
%AT_CheckWarning(rc);

% Set Readout Rate (ie Pixel Clock)
rc = AT_SetEnumString(handles.camHandle,'PixelReadoutRate',handles.settings.pixelReadoutRate);
AT_CheckWarning(rc);

% Set readout mode and overlap mode
rc = AT_SetEnumString(handles.camHandle,'SensorReadoutMode',handles.settings.sensorReadoutMode);
AT_CheckWarning(rc);
rc = AT_SetBool(handles.camHandle,'Overlap',handles.settings.overlap);
AT_CheckWarning(rc);

% Set triggering and cycle modes
rc = AT_SetEnumString(handles.camHandle,'TriggerMode',handles.settings.triggerMode);
AT_CheckWarning(rc);
rc = AT_SetEnumString(handles.camHandle,'CycleMode',handles.settings.cycleMode);
AT_CheckWarning(rc);

% Get sensor dimensions 
[rc,sensorWidth] = AT_GetInt(handles.camHandle,'SensorWidth');
AT_CheckWarning(rc);
[rc,sensorHeight] = AT_GetInt(handles.camHandle,'SensorHeight');
AT_CheckWarning(rc);
handles.settings.sensorWidth = sensorWidth;
handles.settings.sensorHeight = sensorHeight;

% Set initial histogram and display ranges
handles.settings.histYRangeLow = round(handles.settings.initialNumRows*(1/2-1/(2*sqrt(2)))); % follows from above
handles.settings.histYRangeHigh = round(handles.settings.initialNumRows*(1/2+1/(2*sqrt(2)))); % follows from above
handles.settings.histXRangeLow = round(handles.settings.initialNumCols*(1/2-1/(2*sqrt(2)))); % Follows from above
handles.settings.histXRangeHigh = round(handles.settings.initialNumCols*(1/2+1/(2*sqrt(2))));
       
% Get minimum AOI sizes
[rc,minHeight] = AT_GetIntMin(handles.camHandle,'AOIHeight');
AT_CheckWarning(rc);
[rc,minWidth] = AT_GetIntMin(handles.camHandle,'AOIWidth');
AT_CheckWarning(rc);
handles.settings.minWidth = minWidth;
handles.settings.minHeight = minHeight;

% Set AOI
targetCols = handles.settings.numCols;
targetRows = handles.settings.numRows;
[actualNumCols,actualNumRows] = set_AOI_for_num_cols_rows(handles,targetCols,targetRows);
handles.settings.numCols = actualNumCols;
handles.settings.numRows = actualNumRows;
set(handles.uiTextNumCols,'String',actualNumCols);
set(handles.uiTextNumRows,'String',actualNumRows);

% Set frame rate (by setting equivalent exposure and thus max max frame rate)
targetFrameRate = handles.settings.frameRate;
actualFrameRate = set_framerate(handles.camHandle,targetFrameRate,handles.settings.numRows);
handles.settings.frameRate = actualFrameRate;
set(handles.uiTextFrameRate,'String',num2str(0.1*round(actualFrameRate*10)));

% Set pre-amp gain control
preAmpOptions = cellstr(get(handles.uiSelectPreAmp,'String'));
preAmpIndex = 1:numel(preAmpOptions);
targetPreAmp = handles.settings.simplePreAmpGainControl;
[actualBitDepth,actualPixelEncoding] = set_preamp_bitdepth_encoding(handles.camHandle,targetPreAmp);
handles.settings.bitDepth = actualBitDepth;
handles.settings.pixelEncoding = actualPixelEncoding;
set(handles.uiSelectPreAmp,'Value',preAmpIndex(strcmp(preAmpOptions,targetPreAmp)));

% Set framesets to capture
targetFramesetsToCapture = round(handles.settings.framesetsToCapture);
set(handles.uiTextFramesetsToCapture,'String',targetFramesetsToCapture);

% Set flash toggle button
set(handles.uiButtonFlash,'Value',handles.settings.flash);

% Set number of frames to average on the fly
rollingAverageFramesOptions = cellstr(get(handles.uiSelectRollingAverageFrames,'String'));
rollingAverageFramesIdx = 1:numel(rollingAverageFramesOptions);
rollingAverageFramesValue = rollingAverageFramesIdx(strcmp(rollingAverageFramesOptions,num2str(handles.settings.rollingAverageFrames)));
set(handles.uiSelectRollingAverageFrames,'Value',rollingAverageFramesValue);

% Set continuous autoscaling
set(handles.uiCheckContinuousAutoScale,'Value',handles.settings.continuousAutoScale);

% Set target refresh rate
set(handles.uiTextTargetRefresh,'String',handles.settings.targetRefresh);

% Set display levels
handles.settings.displayRangeLow = 0;
handles.settings.displayRangeHigh = 2^handles.settings.bitDepth; % let this auto-calculate
set(handles.uiTextDisplayLow,'String',num2str(handles.settings.displayRangeLow));
set(handles.uiTextDisplayHigh,'String',num2str(handles.settings.displayRangeHigh));

% Set enabled channels on GUI
set(handles.uiCheckChannel1,'Value',handles.settings.channelsEnable(1));
set(handles.uiCheckChannel2,'Value',handles.settings.channelsEnable(2));
set(handles.uiCheckChannel3,'Value',handles.settings.channelsEnable(3));
set(handles.uiCheckChannel4,'Value',handles.settings.channelsEnable(4));
set(handles.uiCheckChannel5,'Value',handles.settings.channelsEnable(5));
set(handles.uiCheckChannel6,'Value',handles.settings.channelsEnable(6));

% Show enabled channels to Arduino via digital out pins
digitalOutputScan = [0, handles.settings.flash, handles.settings.channelsEnable(2:end)];
outputSingleScan(handles.daqHandle,digitalOutputScan);

% Set channel to show
set(handles.uiSelectChannel,'Value',handles.settings.selectChannel);

% Set base filename
set(handles.uiTextFileBaseName,'String',handles.settings.fileBaseName);

% Set capture number, then advance number until file folder doesn't exist
handles = advance_capture_number(handles);

