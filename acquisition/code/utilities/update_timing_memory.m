function handles = update_timing_memory(handles)

% Current frame rate - should already be stored in settings
currentFramerateString = ['Current Frame Rate: ' num2str(handles.settings.frameRate) ' fps'];
set(handles.displayFramerate,'String',currentFramerateString);

% Current Frameset Rate - need to calculate
framesetRate = handles.settings.frameRate/sum(handles.settings.channelsEnable,2);
framesetRateString = ['Current Frameset Rate: ' num2str(framesetRate) ' fsps'];
set(handles.displayFramesetRate,'String',framesetRateString);
handles.settings.framesetRate = framesetRate;

% Max possible frame rate for this interface
[rc,maxInterfaceTransferRate] = AT_GetFloat(handles.camHandle,'MaxInterfaceTransferRate');
AT_CheckWarning(rc);
maxFrameRateString = ['Max Transfer Rate: ' num2str(maxInterfaceTransferRate) ' fps'];
set(handles.displayMaxFramerate,'String',maxFrameRateString);
handles.settings.maxFramerate = maxInterfaceTransferRate;

% Current exposure time (in ms)
[rc,exposureTime] = AT_GetFloat(handles.camHandle,'ExposureTime');
AT_CheckWarning(rc);
handles.settings.exposure = exposureTime*1000; %in ms
currentExposureString = ['Current Exposure: ' num2str(handles.settings.exposure) ' ms'];
set(handles.displayExposure,'String',currentExposureString);

% Get sensor readout time - time to readout the whole sensor (in ms), don't
% bother displaying
[rc,readoutTime] = AT_GetFloat(handles.camHandle,'ReadoutTime');
AT_CheckWarning(rc);
handles.settings.readoutTime = 1000*readoutTime; %in ms

% Current global exposure window (in Andor parlence: FLASH ALL) (in ms)
% Calculate based on exposure time minus readout time
globalExposureWindowTime = handles.settings.exposure - handles.settings.readoutTime; %these both should already be in ms
globalExposureString = ['Global Exposure Window: ' num2str(globalExposureWindowTime) ' ms'];
set(handles.displayGlobalExposure,'String',globalExposureString);
handles.settings.globalExposure = globalExposureWindowTime;

% Illumination Duty Cycle (in percentage)
dutyCycle = (globalExposureWindowTime/handles.settings.exposure)*100;
dutyCycleString = ['Duty Cycle: ' num2str(dutyCycle) '%'];
set(handles.displayDutyCycle,'String',dutyCycleString);
handles.settings.dutyCycle = dutyCycle;

% Total frames in allocation - already calculated by allocation functions
totalFrames = handles.settings.totalFrames;
totalFramesString = ['Total Frames in Acquisition: ' num2str(totalFrames)];
set(handles.displayTotalFrames,'String',totalFramesString);

% Acquisition time
acquisitionTime = handles.settings.totalFrames/handles.settings.frameRate;
acquisitionTimeString = ['Acquistion Time: ' num2str(acquisitionTime) ' sec'];
set(handles.displayAcquisitionTime,'String',acquisitionTimeString);
handles.settings.acquisitionTime = acquisitionTime;

% Memory used in allocation - already calculated by allocation functions
MBsInAllocation = round(10*handles.settings.totalBufferSize)/10;
allocationSizeString = ['Allocation Size: ' num2str(MBsInAllocation) ' MB'];
set(handles.displayAllocationSize,'String',allocationSizeString);
handles.settings.allocationSize = MBsInAllocation;

% Cooling status
[rc,temperatureStatusIndex] = AT_GetEnumIndex(handles.camHandle,'TemperatureStatus');
AT_CheckWarning(rc);
[rc,temperatureStatusString] = AT_GetEnumStringByIndex(handles.camHandle,'TemperatureStatus',temperatureStatusIndex,256);
AT_CheckWarning(rc);
coolerStatusString = ['Cooler Status: ' temperatureStatusString];
set(handles.displayCoolerStatus,'String',coolerStatusString);
handles.settings.coolerStatus = temperatureStatusString;



