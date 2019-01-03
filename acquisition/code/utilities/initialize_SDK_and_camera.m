function [camHandle,cameraInfoString] = initialize_SDK_and_camera

% Open the library to load SDK data structures
rc = AT_InitialiseLibrary();
AT_CheckError(rc);

% Open camera connection--default 1st camera
[rc,camHandle] = AT_Open(0);
AT_CheckError(rc);


% Get the camera name and serial
[rc,maxStringLength] = AT_GetStringMaxLength(camHandle,'CameraName');
AT_CheckWarning(rc);
[rc,cameraNameString] = AT_GetString(camHandle,'CameraName',maxStringLength);
AT_CheckWarning(rc);
[rc,maxStringLength] = AT_GetStringMaxLength(camHandle,'CameraModel');
AT_CheckWarning(rc);
[rc,cameraModelString] = AT_GetString(camHandle,'CameraModel',maxStringLength);
AT_CheckWarning(rc);
[rc,maxStringLength] = AT_GetStringMaxLength(camHandle,'SerialNumber');
AT_CheckWarning(rc);
[rc,serialNumberString] = AT_GetString(camHandle,'SerialNumber',maxStringLength);
AT_CheckWarning(rc);

% Print the name and serial
cameraInfoString = [cameraNameString ', Model: ' cameraModelString ', SN: ' serialNumberString];
disp(['Camera initialized (' cameraInfoString ')']);
