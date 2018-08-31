function handles = set_default_settings(handles,eventdata,camName)

% Load default settings for this camera
handles.settings = default_settings(camName);

% Set AOI
targetLines = handles.settings.numberLines;
xPix = handles.constants.sensorXPixels;
yPix = handles.constants.sensorYPixels;
actualNumberLines = set_AOI_for_num_lines(handles.camHandle,targetLines,xPix,yPix);
handles.settings.numberLines = actualNumberLines;
set(handles.uiTextNumberLines,'String',actualNumberLines);

% Set Pixel Clock
targetPixelclock = handles.settings.pixelclock;
actualPixelclock = set_pixelclock(handles.camHandle,targetPixelclock);
handles.settings.pixelclock = actualPixelclock;
set(handles.uiTextPixelclock,'String',actualPixelclock);

% Set Framerate (and also: exposure)
targetFramerate = handles.settings.framerate;
[actualFramerate,actualExposure] = set_framerate(handles.camHandle,targetFramerate,handles.constants.fracFramePeriodForExposure);
handles.settings.framerate = actualFramerate;
handles.settings.exposure = actualExposure;
set(handles.uiTextFramerate,'String',num2str(0.1*round(actualFramerate*10)));
set(handles.displayExposure,'String',['(' num2str(round(actualExposure)) 'ms)']);

% Set bitdepth
bitdepthOptions = cellstr(get(handles.uiSelectBitdepth,'String'));
bitdepthIndex = 1:numel(bitdepthOptions);
targetBitdepth = handles.settings.bitdepth;
actualBitdepth = set_bitdepth(handles.camHandle,targetBitdepth);
handles.settings.bitdepth = actualBitdepth;
set(handles.uiSelectBitdepth,'Value',bitdepthIndex(strcmp(bitdepthOptions,num2str(actualBitdepth))));

% Set gain "boost"
targetGainBoost = handles.settings.gainBoost;
actualGainBoost = set_gainboost(handles.camHandle,targetGainBoost);
handles.settings.gainBoost = actualGainBoost;
set(handles.uiCheckGainBoost,'Value',actualGainBoost);

% Set Hardware offset
targetValue = handles.settings.hardwareOffset;
if targetValue < 0 % check if valid value
    actualValue = 0;
elseif targetValue > 255
    actualValue = 255;
elseif targetValue-round(targetValue) ~= 0
    actualValue = round(targetValue);
else
    actualValue = targetValue;
end
handles.setting.hardwareOffset = actualValue;
set(handles.uiTextHardwareOffset,'String',num2str(actualValue));
handles.camHandle.BlackLevel.Offset.Set(int32(actualValue));

% Set framesets to capture
targetFramesetsToCapture = round(handles.settings.framesetsToCapture);
set(handles.uiTextFramesetsToCapture,'String',targetFramesetsToCapture);

% Set number of frames to average on the fly
rollingAverageFramesOptions = cellstr(get(handles.uiSelectRollingAverageFrames,'String'));
rollingAverageFramesIdx = 1:numel(rollingAverageFramesOptions);
rollingAverageFramesValue = rollingAverageFramesIdx(strcmp(rollingAverageFramesOptions,num2str(handles.settings.rollingAverageFrames)));
set(handles.uiSelectRollingAverageFrames,'Value',rollingAverageFramesValue); 

% Set display levels
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
digitalOutputScan = [0 handles.settings.channelsEnable];
outputSingleScan(handles.daqHandle,digitalOutputScan);

% Set channel to show
set(handles.uiSelectChannel,'Value',handles.settings.selectChannel);

% Set base filename
set(handles.uiTextFileBaseName,'String',handles.settings.fileBaseName);

% Set capture number, then advance number until file folder doesn't exist
handles = advance_capture_number(handles);



