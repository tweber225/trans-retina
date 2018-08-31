function disable_hotpixel_correction_auto_offset(camHandle)

% Disable hotpixel correction
camHandle.Hotpixel.DisableSensorCorrection();
camHandle.Hotpixel.Camera.SetEnable(false);
camHandle.Hotpixel.Software.SetEnable(false);

% Disable auto offset
camHandle.BlackLevel.Set(uEye.Defines.BlackLevelMode.Off);