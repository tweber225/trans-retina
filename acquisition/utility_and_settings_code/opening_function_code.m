% TRANS-RETINA/ACQUISITION/UTILITY_AND_SETTINGS_CODE/OPENING_FUNCTION_CODE.M
% Timothy D. Weber, BU Biomicroscopy Lab, 28 Sept. 2017
% Purpose of script: contain code used in acquisition GUI's opening function


% Load the default program settings structures and add them to handles
[camConstStruct, camSetStruct, LEDsSetStruct, DAQSetupStruct, GUISetStruct, tempFlagsStruct, analysisSetStruct] = load_default_program_settings; 
handles.camConstStruct = camConstStruct;
handles.camSetStruct = camSetStruct;
handles.LEDsSetStruct = LEDsSetStruct;
handles.DAQSetupStruct = DAQSetupStruct;
handles.GUISetStruct = GUISetStruct;
handles.tempFlagsStruct = tempFlagsStruct;
handles.analysisSetStruct = analysisSetStruct;
clear camConstStruct camSetStruct LEDsSetStruct DAQSetupStruct GUISetStruct tempFlagsStruct analysisSetStruct 
 
% Make digital channels to send enable signal to Arduino with correct
% configuration of LEDs
disp('Starting DAQ System')
handles.NIDaqSession = daq.createSession('ni');
addDigitalChannel(handles.NIDaqSession,DAQSetupStruct.deviceName,DAQSetupStruct.portAndLines,'OutputOnly');
% Make sure the first output is set to low (=0) so we can trigger the Aruindo later
handles.tempFlagsStruct.digitalOutputScan = [0 handles.tempFlagsStruct.LEDsToEnable handles.GUISetStruct.commFixTarget];
outputSingleScan(handles.NIDaqSession,handles.digitalOutputScan);

% Open up and initialize camera
disp('Starting Camera ...')

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