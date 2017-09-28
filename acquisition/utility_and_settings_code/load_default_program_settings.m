function [camConstStruct, camSetStruct, LEDsSetStruct, DAQSetupStruct, GUISetStruct, tempFlagsStruct, analysisSetStruct] = load_default_program_settings()
% TRANS-RETINA/ACQUISITION/UTILITY_AND_SETTINGS_CODE/LOAD_DEFAULT_PROGRAM_SETTINGS.M
% Timothy D. Weber, BU Biomicroscopy Lab, 28 Sept. 2017
% Purpose: to load default program and camera parameter settings and
%   constants

% CAMERA CHOICE (can elaborate here in the future, if we need to switch
%   between cameras)
camName = 'DCC3240N'; %<-edit here for new camera
run(['settings_profiles' filesep camName '.m']);
% After run, there should be two structs: camConstStruct, camSetStruct
% the camSetStruct contains some redundant parameters as GUISetStruct, but
% it is meant to contain a "live" copy of the camera settings, whereas, the
% GUISetStruct.prevPixClock (etc) might be inaccurate if we're in capture
% mode

% LED CONFIGURATION (works the same as CAMERA CHOICE, for the most part)
ledConfigName = 'four_LEDs'; %<-edit here for new LED configuration
run(['settings_profiles' filesep ledConfigName '.m']);
% Now there's a structure called LEDConfigStruct, which this function does
% not need to pass, since all the info is saved into the GUI fields

% DAQ DIGITAL PIN CONFIGURATION (works the same as LED CONFIGURATION)
daqConfigName = 'DAQ_setup'; %<-edit here for new DAQ configuration
run(['settings_profiles' filesep daqConfigName '.m']);
% Now there's a structure called DAQSetupStruct

% GUI SETTINGS
% -Preview Mode Settings tab (use default camera settings)
GUISetStruct.prevPixClock = camSetStruct.pixClock; % pixels read / sec
GUISetStruct.prevFrameRate = camSetStruct.frameRate; % frames / sec
GUISetStruct.prevExpTime = camSetStruct.expTime; % in usec
GUISetStruct.prevGain = camSetStruct.gain; % see camera profile
GUISetStruct.prevBinSize = 1; % see camera profile
GUISetStruct.prevADCOffset = camSetStruct.ADCOffset;
GUISetStruct.prevSensorHotPixCorrect = 0;

% -Capture Mode Settings tab (use default camera settings)
GUISetStruct.capPixClock = camSetStruct.pixClock; % pixels read / sec
GUISetStruct.capFrameRate = camSetStruct.frameRate; % frames / sec
GUISetStruct.capExpTime = camSetStruct.expTime; % in usec
GUISetStruct.capGain = camSetStruct.gain; % see camera profile
GUISetStruct.capBinSize = 1; % see camera profile

% (Capture mode-specific items)
GUISetStruct.capNumFrames = 1; % actually it's the NUMBER of frame SETS (pairs, trios, etc.)
GUISetStruct.capWarningFlag = 0; % needs to be set to 0 on startup, indicates that some frames may have been dropped
GUISetStruct.capAborted = 0; % needs to be set to 0 on startup, indicates that the capture was aborted before completion
GUISetStruct.capLockSettings = 1; % To lock capture exposure time, bin size, pix clock, gain to those settings used in Preview Mode

% -Save Settings (actually located inside of capture mode tab)
GUISetStruct.saveBaseName = 'subject001';
GUISetStruct.saveSettings = 1; % Save a text file with current settings
GUISetStruct.saveFrameTimes = 1; % Save the time of the frames
GUISetStruct.saveCapNum = 1;
GUISetStruct.saveCapStartTime = -1;

% -Common Settings tab
%GUISetStruct.commAutoScale = 0; % MAY NOT NEED THIS, 28-Sept-17 (possibly
%related to a flag for needToAutoScale ?
GUISetStruct.commFixTarget = 0; % A little LED mounted outside the fundus camera
GUISetStruct.commXShift = 0;

% -Real-Time Settings tab
GUISetStruct.RTStats = 1;
GUISetStruct.RTHistogram = 1;
GUISetStruct.RTFlattening = 0; % Real-time flattening should be disabled during 
GUISetStruct.RTAveraging = 0; % Number of frame sets to average to improve SNR (useful with RTFlattening)
GUISetStruct.RTCalcsInCenter = 1; % Computer RT calculations for image data only from a centered circular AOI

% -Select LEDs tab
GUISetStruct.selectLEDsShow = 1; % LED channel to show on big image axis, only important if >2 LEDs are selected (Quad-channel view mode is automatically turned on)
GUISetStruct.prevLEDsEnable1 = 1; % MAKE SURE THAT AT LEAST ONE LED IS ENABLED BEFORE STARTING
GUISetStruct.prevLEDsEnable2 = 1;
GUISetStruct.prevLEDsEnable3 = 0;
GUISetStruct.prevLEDsEnable4 = 0;
GUISetStruct.capLEDsEnable1 = 1;
GUISetStruct.capLEDsEnable2 = 1;
GUISetStruct.capLEDsEnable3 = 1;
GUISetStruct.capLEDsEnable4 = 1;
GUISetStruct.selectLEDsLockCap = 1;

% -other (hidden) constants used by the GUI
GUISetStruct.constExpIncrementMs = camConstStruct.expIncrementMs;
GUISetStruct.constLED1CenterWavelength = LEDConfigStruct.constLED1CenterWavelength;
GUISetStruct.constLED2CenterWavelength = LEDConfigStruct.constLED2CenterWavelength;
GUISetStruct.constLED3CenterWavelength = LEDConfigStruct.constLED3CenterWavelength;
GUISetStruct.constLED4CenterWavelength = LEDConfigStruct.constLED4CenterWavelength;
GUISetStruct.constYOffset = 6;


% LEDs STRUCTURE (structure that contains the "current" LEDs enabled)
% presumably the first action will be a "preview", so copy preview-enabled LEDs
LEDsSetStruct.LED1Enable = GUISetStruct.prevLEDsEnable1; 
LEDsSetStruct.LED2Enable = GUISetStruct.prevLEDsEnable2;
LEDsSetStruct.LED3Enable = GUISetStruct.prevLEDsEnable3;
LEDsSetStruct.LED4Enable = GUISetStruct.prevLEDsEnable4;


% TEMPORARY FLAGS
% (used internally in the GUI to signal different events, not necessary to
% save)
tempFlagsStruct.justFinishedCap = 0; % Flag to fix a bug/situation when user changes preview mode LEDs choices after a capture has completed, but before preview mode has started
tempFlagsStruct.inCapMode = 0; % another (inelegant) fix to a bug with the capture mode LED choices 
tempFlagsStruct.inputExpNumbers = '-'; % Next few lines, to track numpad/keypad key strokes
tempFlagsStruct.capInputExpNumbers = '-';
tempFlagsStruct.enteringFilename = 0;
tempFlagsStruct.filenameChars = '';
tempFlagsStruct.shiftHit = 0; % tracks whether the shift key has been hit
tempFlagsStruct.requestCapture = 0; % tracks whether preview has been interrupted and a capture is requested
tempFlagsStruct.needToAutoScaleImage = 0; % Tracks whether we should autoscale the image levels on next frame update
tempFlagsStruct.prevLEDsToEnable = [GUISetStruct.prevLEDsEnable1;
    GUISetStruct.prevLEDsEnable2;
    GUISetStruct.prevLEDsEnable3; 
    GUISetStruct.prevLEDsEnable4];
tempFlagsStruct.capLEDsToEnable = [GUISetStruct.capLEDsEnable1;
    GUISetStruct.capLEDsEnable2;
    GUISetStruct.capLEDsEnable3; 
    GUISetStruct.capLEDsEnable4];
tempFlagsStruct.LEDsToEnable = [LEDsSetStruct.LED1Enable;
    LEDsSetStruct.LED2Enable;
    LEDsSetStruct.LED3Enable; 
    LEDsSetStruct.LED4Enable];


% DERIVED SETTINGS/PARAMETERS (some useful settings that are dependent on
% settings above)
% Figure out the expected number of pixels for the default bin size
GUISetStruct.derivePrevNumPixPerDim = camConstStruct.maxPixY/GUISetStruct.prevBinSize; 
GUISetStruct.deriveCapNumPixPerDim = camConstStruct.maxPixY/GUISetStruct.capBinSize;
GUISetStruct.numPixPerDim = GUISetStruct.derivePrevNumPixPerDim; % This is a "current" frame size (will start with preview mode, so copy that mode's setting)

% Enable quad-view mode (1 large preview and 4 smaller images for each LED
% channel
if sum([LEDsSetStruct.LED1Enable,LEDsSetStruct.LED2Enable,LEDsSetStruct.LED3Enable,LEDsSetStruct.LED4Enable]) > 2
    GUISetStruct.selectLEDsQuadViewOn = 1; % whether we're in the quad-view mode (when >2 LEDs are enabled)
else
    GUISetStruct.selectLEDsQuadViewOn = 0;
end


% ANALYSIS SETTINGS STRUCTURE
analysisSetStruct.analysisSelectCenterRadPercent = 0.95; % percentage of the image height to use as AOI circle diameter to compute RT calcs
analysisSetStruct.analysisAutoScaleHighQuantile = 0.995; % autoscale white/black level to these quantiles
analysisSetStruct.analysisAutoScaleLowQuantile = 0.005;
analysisSetStruct.analysisHistogramBins = 128; % Number of histogram bins
analysisSetStruct.analysisFilterKernelWidth = .06; % 0-1 fraction of width to use for flattening kernel low pass


