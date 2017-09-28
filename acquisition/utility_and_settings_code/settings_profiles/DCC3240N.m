% TRANS-RETINA/ACQUISITION/UTILITY_AND_SETTINGS_CODE/SETTINGS_PROFILES/DCC3240N.M
% Timothy D. Weber, BU Biomicroscopy Lab, 28 Sept. 2017
% Purpose: Profile with the default settings for the Thorlabs CMOS USB3.0
%   Camera, model DCC3240N (1280x1024, 1/8" sensor 5.3um, square pixels,
%   10-bit, 60fps, NIR-enhanced)
%
% After running, two structures will be available, camConstStruct
%   (containing constant values related to the camera) and camSetStruct
%   (contains the launch defaults for several variable camera parameters)

% Camera constants
camConstStruct.maxPixX = 1280;
camConstStruct.maxPixY = 1024;
camConstStruct.pixBitDepth = 10;
camConstStruct.shutterMode = 'global';
camConstStruct.GPIOExpOutput = 1;
camConstStruct.expIncrementMs = 1; % in ms (note 60fps is 16.67ms period)

% Default camera settings, note: these will be imported for preview mode
% and capture mode
camSetStruct.pixClock = 42e6; % pixels read / sec
camSetStruct.frameRate = 30; % frames / sec
camSetStruct.expTime = 15e3; % in usec
camSetStruct.gain = 1; % limited choices: 1=1X, 2=2X, 3=3X, 4=4X, 5=6X, 6=8X
camSetStruct.binSize = 1; % limited choices: 1=1x1, 2=2x2
camSetStruct.ADCOffset = 10; % arbitrary for now
camSetStruct.sensorHotPixCorrect = 0; % on or off for sensor-based hot pixel corrections

