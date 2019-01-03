function settings = default_settings(camName)

switch camName
    case 'DCC3240N'
        settings.sessionStartTime = datestr(datetime);
        settings.captureStartTime = 'none';
             
        settings.numberLines = 1024;
        settings.histYRangeLow = round(settings.numberLines*(1/2-3.75/10)); % follows from above
        settings.histYRangeHigh = round(settings.numberLines*(1/2+3.75/10)); % follows from above
        settings.pixelclock = 86;
        settings.framerate = 25;
        settings.framesetRate = 0; % let this auto-calculate
        settings.maxFramerate = 0; % let this auto-calculate
        settings.exposure = 0; % let this auto-calculate
        settings.globalExposure = 0; % let this auto-calculate
        settings.dutyCycle = 0; % let this auto-calculate
        settings.totalFrames = 0; % let this auto-calculate
        settings.acquisitionTime = 0; % let this auto-calculate
        settings.allocationSize = 0; % let this auto-calculate
        settings.gainBoost = true;
        settings.hardwareOffset = 255;
              
        settings.selectChannel = 1;
        settings.channelsEnable = [1 0 0 0 0 0]; % Six channels max
        
        settings.framesetsToCapture = 128;
        settings.maxAllocationSize = 8*2^10; % in MB
        settings.bitdepth = 10;
        
        settings.rollingAverageFrames = int32(1); % int32 for compatibility later, valid choices are powers of 2 up to 64
        
        settings.displayRangeLow = 0;
        settings.displayRangeHigh = 2^settings.bitdepth; % let this auto-calculate
        
        settings.dataPathName = 'data';
        settings.fileBaseName = 'subject001';
        settings.captureNumber = 1;
        settings.todaysDate = datestr(now,'yyyymmdd'); %auto
        settings.fullPathName = [cd filesep settings.dataPathName filesep settings.todaysDate]; %auto

        
       

end