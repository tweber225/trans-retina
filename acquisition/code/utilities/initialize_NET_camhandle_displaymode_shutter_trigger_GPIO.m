function camHandle = initialize_NET_camhandle_displaymode_shutter_trigger_GPIO(camNumber)

NET.addAssembly('C:\Program Files\IDS\uEye\Develop\DotNet\uEyeDotNet.dll');

camHandle = uEye.Camera;
camHandle.Init(camNumber);

camHandle.Display.Mode.Set(uEye.Defines.DisplayMode.DiB);

camHandle.Device.Feature.ShutterMode.Set(uEye.Defines.Shuttermode.Rolling); % Global is noisy

camHandle.Trigger.Set(uEye.Defines.TriggerMode.Continuous);

% By default, using GPIO channel two for flash output
camHandle.IO.Gpio.SetConfiguration(uEye.Defines.IO.GPIO.Two,uEye.Defines.IO.GPIOConfiguration.Flash);
camHandle.IO.Flash.SetMode(uEye.Defines.IO.FlashMode.FreerunHighActive);