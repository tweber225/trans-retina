function handles = update_timing_memory(handles)

% Current framerate
currentFramerateString = ['Current Frame Rate: ' num2str(handles.settings.framerate) ' fps'];
set(handles.displayFramerate,'String',currentFramerateString);

% Current Frameset Rate
framesetRate = handles.settings.framerate/sum(handles.settings.channelsEnable);
framesetRateString = ['Current Frameset Rate: ' num2str(framesetRate) ' fsps'];
set(handles.displayFramesetRate,'String',framesetRateString);
handles.settings.framesetRate = framesetRate;

% Max possible framerate
[~,~,maxFramerate,~] = handles.camHandle.Timing.Framerate.GetFrameRateRange; %check
maxFrameRateString = ['Max Frame Rate: ' num2str(maxFramerate) ' fps'];
set(handles.displayMaxFramerate,'String',maxFrameRateString);
handles.settings.maxFramerate = maxFramerate;

% Current exposure time
[~,currentExposure] = handles.camHandle.Timing.Exposure.Get;
handles.settings.exposure = double(currentExposure);
currentExposureString = ['Current Exposure: ' num2str(handles.settings.exposure) ' ms'];
set(handles.displayExposure,'String',currentExposureString);

% Current global exposure window (also updates the flash params)
[~,~,flashDurationMicroSec] = handles.camHandle.IO.Flash.GetGlobalParams;
globalExposureString = ['Global Exposure Window: ' num2str(double(flashDurationMicroSec)/1000) ' ms'];
set(handles.displayGlobalExposure,'String',globalExposureString);
handles.settings.globalExposure = double(flashDurationMicroSec)/1000;

% Illumination Duty Cycle
dutyCycle = ((double(flashDurationMicroSec)/1000)/handles.settings.exposure)*100;
dutyCycleString = ['Duty Cycle: ' num2str(dutyCycle) '%'];
set(handles.displayDutyCycle,'String',dutyCycleString);
handles.settings.dutyCycle = dutyCycle;

% Total frames in allocation
totalFrames = numel(int32(handles.sequenceList));
totalFramesString = ['Total Frames in Acquisition: ' num2str(totalFrames)];
set(handles.displayTotalFrames,'String',totalFramesString);
handles.settings.totalFrames = totalFrames;

% Acquisition time
acquisitionTime = totalFrames/handles.settings.framerate;
acquisitionTimeString = ['Acquistion Time: ' num2str(acquisitionTime) ' sec'];
set(handles.displayAcquisitionTime,'String',acquisitionTimeString);
handles.settings.acquistionTime = acquisitionTime;

% Memory used in allocation
if handles.settings.bitdepth > 8
    bytesPerPixel = 2;
else
    bytesPerPixel = 1;
end
pixCount = double(handles.settings.numberLines)*double(handles.constants.sensorXPixels);
bytesInAllocation = bytesPerPixel*pixCount*totalFrames;
MBsInAllocation = round(10*bytesInAllocation/(2^20))/10;
allocationSizeString = ['Allocation Size: ' num2str(MBsInAllocation) ' MB'];
set(handles.displayAllocationSize,'String',allocationSizeString);
handles.settings.allocationSize = MBsInAllocation;



