% TRANS-RETINA/ACQUISITION/UTILITY_AND_SETTINGS_CODE/OPENING_FUNCTION_CODE.M
% Timothy D. Weber, BU Biomicroscopy Lab, 28 Sept. 2017
% Purpose: contain code used in acquisition GUI's opening function

% Load the default program settings
handles.settingsStruct = load_default_program_settings; % This script defines all the variables in the master settings structure "settingsStruct"
handles.inputExpNumbers = '-'; % Next few lines, to track numpad/keypad key strokes
handles.capInputExpNumbers = '-';
handles.enteringFilename = 0;
handles.filenameChars = '';
handles.shiftHit = 0; % tracks whether the shift key has been hit
handles.requestCapture = 0; % tracks whether preview has been interrupted and a capture is requested
handles.needToAutoScaleImage = 0; % Tracks whether we should autoscale the image levels on next frame update

% Make digital channels to send enable signal to Arduino with correct
% configuration of LEDs
handles.prevLEDsToEnable = [handles.settingsStruct.prevLEDsEnable1 handles.settingsStruct.prevLEDsEnable2 handles.settingsStruct.prevLEDsEnable3 handles.settingsStruct.prevLEDsEnable4];
handles.capLEDsToEnable = [handles.settingsStruct.capLEDsEnable1 handles.settingsStruct.capLEDsEnable2 handles.settingsStruct.capLEDsEnable3 handles.settingsStruct.capLEDsEnable4];
handles.LEDsToEnable = [handles.settingsStruct.selectLEDsEnable1 handles.settingsStruct.selectLEDsEnable2 handles.settingsStruct.selectLEDsEnable3 handles.settingsStruct.selectLEDsEnable4];
disp('Starting DAQ System')
handles.NIDaqSession = daq.createSession('ni');
addDigitalChannel(handles.NIDaqSession,'dev1','Port0/Line0:5','OutputOnly');
% Make sure the port is set to low so we can trigger the Aruindo later
handles.digitalOutputScan = [0 handles.LEDsToEnable handles.settingsStruct.fixationTarget];
outputSingleScan(handles.NIDaqSession,handles.digitalOutputScan);

% Open the camera adapters
disp('Starting Camera')
handles.vidObj = videoinput('pcocameraadaptor', 0); % vid input object
handles.srcObj = getselectedsource(handles.vidObj); % adapter source

%Set logging to memory
handles.vidObj.LoggingMode = 'memory';

% Update GUI settings, set up default camera parameters
handles = update_all_settings_on_GUI(handles);
selectLEDsLockCap_Callback(hObject, eventdata, handles); handles = guidata(hObject); % run callback for lock capture LED choices
capLockSettings_Callback(hObject, eventdata, handles); handles = guidata(hObject); % run callback for lock capture LED choices
handles.srcObj = set_all_camera_settings(handles.srcObj,handles.settingsStruct);

% Update Handles for GUI data tracking
guidata(hObject, handles);

% Black out all image frames - and generate handles for image data
handles = reset_GUI_displays_update_resolution(handles,handles.settingsStruct.derivePrevNumPixPerDim);

% Display the estimates (time and data) for capture
handles = estimate_capture_time_data(handles);

guidata(hObject, handles);