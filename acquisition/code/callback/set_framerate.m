function [actualFramerate, actualExposure] = set_framerate(camHandle,targetFramerate,fracFramePeriodForExposure)
% Updates framerate to nearly targetFramerate. Returns actual framerate and exposure time.

camHandle.Timing.Framerate.Set(targetFramerate);
[~,actualFramerate] = camHandle.Timing.Framerate.Get;

[~,~,maxExposure,~] = camHandle.Timing.Exposure.GetRange;
camHandle.Timing.Exposure.Set(maxExposure*fracFramePeriodForExposure);
[~,actualExposure] = camHandle.Timing.Exposure.Get;