function settings = default_settings(camName)

switch camName
    case 'zyla42'
        settings.sessionStartTime = datestr(datetime);
        settings.captureStartTime = 'none';  % leave blank until capture time
        
        % Rolling shutter mode
        settings.electronicShutterMode = 'Rolling';
        
        % Pixel readout rate is doubled when using simultaneous readout
        settings.pixelReadoutRate = '270 MHz';
        settings.sensorReadoutMode = 'Centre Out Simultaneous';
        
        % Overlap mode maximizes framerate for given exposure time
        settings.overlap = 1;
        
        % Triggering internally-rather than external triggering or SW
        settings.triggerMode = 'Internal';
        
        % Camera cycle mode (continuous or fixed--stops at a number of frames)
        settings.cycleMode = 'Continuous';
        
        % Starting AOI height and width, always centered
        settings.initialNumCols = 1034;
        settings.initialNumRows = 1034;
        settings.numCols = settings.initialNumCols; % temporary number
        settings.numRows = settings.initialNumRows; % temporary number
        
        % Set framerate (frames per second)--this is not the frameset rate
        settings.frameRate = 20;
        
        % Data types and depths
        settings.simplePreAmpGainControl = '12-bit (high well capacity)'; % check next line
        settings.bitDepth = 0; % let this auto-calculate
        settings.pixelEncoding = 'none'; % also automatic
        
        settings.framesetRate = 0; % let this auto-calculate
        settings.maxFramerate = 0; % let this auto-calculate
        settings.exposure = 0; % let this auto-calculate
        settings.globalExposure = 0; % let this auto-calculate
        settings.dutyCycle = 0; % let this auto-calculate
        settings.totalFrames = 0; % let this auto-calculate
        settings.acquisitionTime = 0; % let this auto-calculate
        settings.allocationSize = 0; % let this auto-calculate
              
        % Data buffering and framesets to acquire
        settings.numBufferFrames = int32(84); % Frames to use for SDK buffer
        settings.maxAllocationSize = 1*2^10; % in MB
        settings.framesetsToCapture = 80;
        
        % Flash status and frame start
        settings.flash = 0;
        settings.flashStartFrame = int32(-1); %-1 means that it hasn't been set
        
        % Cooling Status -- obviously turn it on! this setting is automatic
        settings.coolerStatus = '---'; % nothing for now, auto-fill with memory display update
        
        % Target number of frames to show in preview / sec
        settings.targetRefresh = 10; % fps
        
        % To allow a number of frames to be averaged on the fly and
        % displayed
        settings.rollingAverageFrames = int32(1); % int32 for compatibility later, valid choices are powers of 2 up to 64
        settings.avgBufferSize = uint16(8); % Max number in buffer
        
        % Continuously auto-scale the levels
        settings.continuousAutoScale = 0;
        settings.continuousAutoScaleRate = 2; %Hz
        
        % Histogram display
        settings.histogramBins = 128;
        
        % Channel selection/display
        settings.selectChannel = 1; % Channel to display during acq.
        settings.channelsEnable = [1 0 0 0 0 0]; % Configured for 6 channels max
        
        % Saving files and filenames
        settings.dataPathName = 'data';
        settings.fileBaseName = 'subject001';
        settings.captureNumber = 1;
        settings.todaysDate = datestr(now,'yyyymmdd'); %auto
        settings.fullPathName = [cd filesep settings.dataPathName filesep settings.todaysDate]; %auto

end