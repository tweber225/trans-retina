function shut_down_GUI(handles)

% Flush any remain Andor SDK buffers
rc = AT_Flush(handles.camHandle);
AT_CheckWarning(rc);

% Close camera connection
rc = AT_Close(handles.camHandle);
AT_CheckWarning(rc);

% Close out Andor SDK library
rc = AT_FinaliseLibrary();
AT_CheckWarning(rc);
disp('Camera shutdown');

% Close out DAQ connection and reset
delete(handles.daqHandle); 
daqreset 
disp('DAQ shutdown')

