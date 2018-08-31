NET.addAssembly('C:\Program Files\IDS\uEye\Develop\DotNet\uEyeDotNet.dll');

cam = uEye.Camera;
cam.Init(0);

cam.Display.Mode.Set(uEye.Defines.DisplayMode.DiB);
cam.PixelFormat.Set(uEye.Defines.ColorMode.Mono8);

% Set to freerun software triggering
cam.Trigger.Set(uEye.Defines.TriggerMode.Continuous);

% Define AOI
AOIY = 10;
AOIX = 0;
AOIHeight = int32(750);
AOIWidth = int32(1280);
cam.Size.AOI.Set(AOIX,AOIY,AOIWidth,AOIHeight);


% Make frame memories
numFrames = 512;
memIDs = zeros([numFrames, 1],'int32');
for frameIdx = 1:numFrames
    [~,memIDs(frameIdx)] = cam.Memory.Allocate(true);
end
cam.Memory.Sequence.Add(memIDs);
[~,frameList] = cam.Memory.Sequence.GetList;

[~,width,height,bits,~] = cam.Memory.Inquire(memIDs(1));


% Gain settings
boostEnable = ~true;
masterGainLevel = 0;
bSupported = cam.Gain.Hardware.Boost.GetSupported;
cam.Gain.Hardware.Boost.SetEnable(boostEnable);
cam.Gain.Hardware.Scaled.SetMaster(masterGainLevel);

% shutter to rolling (lower noise)
cam.Device.Feature.ShutterMode.Set(uEye.Defines.Shuttermode.Rolling); 

% Disable hotpixel correction
cam.Hotpixel.DisableSensorCorrection();
cam.Hotpixel.Camera.SetEnable(false);
cam.Hotpixel.Software.SetEnable(false);

% Set pixel clock (after recieving range)
[~, minClock, maxClock] = cam.Timing.PixelClock.GetRange;
cam.Timing.PixelClock.Set(maxClock);

% Set framerate
targetFramerate = 10;
[~,~,maxFramerate,~] = cam.Timing.Framerate.GetFrameRateRange;
cam.Timing.Framerate.Set(maxFramerate);
[~,actualFrameRate] = cam.Timing.Framerate.Get;

% set max exposure time for the current framerate
[~,~,maxExposure,~] = cam.Timing.Exposure.GetRange;
%cam.Timing.Exposure.Set(maxExposure);
cam.Timing.Exposure.Set(.1);
[~,actualExposure] = cam.Timing.Exposure.Get;
pause(1)

% Start freerun
cam.Acquisition.Capture(uEye.Defines.DeviceParameter.DontWait);


% Display
tic

lastSeqID = 0;
a= zeros(100,1);aIdx = 1;
while lastSeqID < 400
    
    [~,lastSeqID] = cam.Memory.Sequence.GetLast;
    a(aIdx) = lastSeqID;aIdx = aIdx+1;
    [~,memID] = cam.Memory.Sequence.ToMemoryID(lastSeqID);
    [~,tmp] = cam.Memory.CopyToArray(memID,uEye.Defines.ColorMode.Mono8);
    data = reshape(uint8(tmp),[width,height]);
    himg = imshow(data(1:1000,1:end)');
    drawnow
end
cam.Acquisition.Stop();

toc

[~,activeSeqID] = cam.Memory.Sequence.GetActive;
disp(activeSeqID)


% Intergrate all the images taken
intImage = double(zeros(size(data')));
for intIdx = int32(frameList)
    [~,memID] = cam.Memory.Sequence.ToMemoryID(intIdx);
    [~,tmp] = cam.Memory.CopyToArray(memID,uEye.Defines.ColorMode.Mono8);
    intImage = intImage + double(reshape(uint8(tmp),[width,height])');
end

% disables camera handle and releases data structs and memory areas
cam.Exit;

