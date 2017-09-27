% Add NET assembly
NET.addAssembly('C:\Program Files\Thorlabs\Scientific Imaging\DCx Camera Support\Develop\DotNet\uc480DotNet.dll');

% Creating a camera object handle
cam = uc480.Camera;

% Open 1st camera
cam.Init(0);

% Setting display mode to DiB
cam.Display.Mode.Set(uc480.Defines.DisplayMode.DiB);

% Set Pixel color format
cam.PixelFormat.Set(uc480.Defines.ColorMode.SensorRaw12);

% Set trigger mode to software
cam.Trigger.Set(uc480.Defines.TriggerMode.Software);

% Allocate image memory
[~,MemId] = cam.Memory.Allocate(true);

% Get image height, width, and bit depth
[~, Width, Height, Bits, ~ ] = cam.Memory.Inquire(MemId);

% Acquire an image
a = cam.Acquisition.Freeze(uc480.Defines.DeviceParameter.Wait);

% Copy image data from memory
clear tmp
[~, Width, Height, Bits, ~ ] = cam.Memory.Inquire(MemId);
[qq,tmp] = cam.Memory.CopyToArray(MemId);
% data = reshape(uint16(tmp), [Bits/8,Width,Height]);
% data2 = permute(data,[3,2,1]);
% imagesc(data2(:,:,1));


% Close out camera
cam.Exit;