function actualFrameRate = set_framerate(camHandle,targetFrameRate,numRows)

% Set framerate by calculating necessary exposure time (for the number of
% lines and readout rate), setting that, and setting maximum available
% framerate. Done this way because framerate is dependent on exposure.

% First, get frame readout time for this AOI & pixel readout rate
[rc,readoutTime] = AT_GetFloat(camHandle,'ReadoutTime');
AT_CheckWarning(rc);

% Calculate line readout time (assuming vertically-centered)
lineReadoutTime = readoutTime/(numRows/2);

% Calculate max framerate = reciprocal readout time, limit to this if over
frameRateReadoutLimited = min(targetFrameRate,1/readoutTime); 
idealExpTime = 1/frameRateReadoutLimited;

% Round exposure to units of line readout time, subtract 1 line readout
% time for the actual readout
roundExpTime = round(idealExpTime/(lineReadoutTime))*lineReadoutTime - lineReadoutTime;

% Constrain to min/max available exposures
[rc,maxExposure] = AT_GetFloatMax(camHandle,'ExposureTime');
AT_CheckWarning(rc); 
[rc,minExposure] = AT_GetFloatMin(camHandle,'ExposureTime');
AT_CheckWarning(rc);
if roundExpTime < minExposure, roundExpTime = minExposure;end
if roundExpTime > maxExposure, roundExpTime = maxExposure;end

% Set the calculated exposure
rc = AT_SetFloat(camHandle,'ExposureTime',roundExpTime);
AT_CheckWarning(rc);

% Next, get max framerate, and set it, and check it
[rc,maxFrameRate] = AT_GetFloatMax(camHandle,'FrameRate');
AT_CheckWarning(rc);

% Subtract off a single precision epsilon, to cover for a bug in SDK :[
% where the maximum returned float isn't settable (not in min/max limits)
maxFrameRateAdjusted = double(maxFrameRate - eps(single(maxFrameRate)));

% Set the tweaked max framerate
rc = AT_SetFloat(camHandle,'FrameRate',maxFrameRateAdjusted);
AT_CheckWarning(rc);

% Just to be sure, read the current frame rate and return this
[rc,actualFrameRate]=AT_GetFloat(camHandle,'FrameRate');
AT_CheckWarning(rc);
