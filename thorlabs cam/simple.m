NET.addAssembly('C:\Program Files\IDS\uEye\Develop\DotNet\uEyeDotNet.dll');

cam = uEye.Camera;

cam.Init(0);

cam.Display.Mode.Set(uEye.Defines.DisplayMode.DiB);

cam.PixelFormat.Set(uEye.Defines.ColorMode.Mono8);

cam.Trigger.Set(uEye.Defines.TriggerMode.Software);

[~,MemId] = cam.Memory.Allocate(true);

[~,width,height,bits,~] = cam.Memory.Inquire(MemId);

% alter exposure time (in ms)
expTime = .5;
cam.Timing.Exposure.Set(expTime);

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

cam.Acquisition.Freeze(uEye.Defines.DeviceParameter.Wait);

[~,tmp] = cam.Memory.CopyToArray(MemId);

data = reshape(uint8(tmp),[width,height]);
data = data(1:width,1:height);
data = permute(data,[2,1]);

himg = imagesc(data);

cam.Exit;

