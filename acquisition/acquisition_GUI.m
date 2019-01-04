function varargout = acquisition_GUI(varargin)
% Retinal Imaging GUI v4.0 (for Andor Zyla 4.2 USB)
% Timothy Weber 
% BU Biomicroscopy Lab, 2019
%
% ACQUISITION_GUI MATLAB code for acquisition_GUI.fig
%      ACQUISITION_GUI, by itself, creates a new ACQUISITION_GUI or raises the existing
%      singleton*.
%
%      H = ACQUISITION_GUI returns the handle to a new ACQUISITION_GUI or the handle to
%      the existing singleton*.
%
%      ACQUISITION_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ACQUISITION_GUI.M with the given input arguments.
% 
%      ACQUISITION_GUI('Property','Value',...) creates a new ACQUISITION_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before acquisition_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to acquisition_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help acquisition_GUI

% Last Modified by GUIDE v2.5 03-Jan-2019 16:56:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @acquisition_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @acquisition_GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before acquisition_GUI is made visible.
function acquisition_GUI_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to acquisition_GUI (see VARARGIN)

% Choose default command line output for acquisition_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes acquisition_GUI wait for user response (see UIRESUME)
% uiwait(handles.acquisitionGUIFig);

% CAMERA AND SYSTEM CHOICES
camName = 'zyla42'; % nickname for cam, in future may add other options
numDigitalPins = 7; % 5 switchabel channels plus an 'arm', and 'pseudo-flash' (to enable channels 2-5)

% ADD RELEVANT SUB-FOLDERS TO PATH (allows functions in these folders to be
% called)
addpath(genpath('code')); % Add all code subfolders to path

% START UP FUNCTION
start_up_GUI(hObject,handles,camName,numDigitalPins);




%% CLOSE FUNCTION -- Executes when user attempts to close acquisition_GUI. Very important.
function acquisitionGUIFig_CloseRequestFcn(hObject, ~, handles)
if get(handles.uiButtonCapture,'Value') == 1
    % if capture is ongoing, reject the closing request
    disp('Cannot close window! In middle of capture or saving.'); return
end
shut_down_GUI(handles); delete(hObject); % shutdown function and close the figure


%% CALLBACK FUNCTIONS
% GENERAL SETTINGS
function uiTextFrameRate_Callback(hObject,~,handles)
uiTextFrameRateSeparateCallback(hObject,handles);

function uiTextNumCols_Callback(hObject,~,handles)
uiTextNumRowsCols(hObject,handles);

function uiTextNumRows_Callback(hObject,~,handles)
uiTextNumRowsCols(hObject,handles);

function uiSelectPreAmp_Callback(hObject, ~, handles)
uiSelectPreAmpSeparateCallback(hObject,handles);

% CHANNEL SELECTION
function uiSelectChannel_Callback(hObject, ~, handles)
select_channel(hObject,handles);

function uiCheckChannel1_Callback(hObject, ~, handles)
%(Channel 1 is always on)
%handles = channel_enable_disable(hObject,handles,1); 
%select_channel(handles.uiSelectChannel,handles);

function uiCheckChannel2_Callback(hObject, ~, handles)
handles = channel_enable_disable(hObject,handles,2);
select_channel(handles.uiSelectChannel,handles);

function uiCheckChannel3_Callback(hObject, ~, handles)
handles = channel_enable_disable(hObject,handles,3);
select_channel(handles.uiSelectChannel,handles);

function uiCheckChannel4_Callback(hObject, ~, handles)
handles = channel_enable_disable(hObject,handles,4);
select_channel(handles.uiSelectChannel,handles);

function uiCheckChannel5_Callback(hObject, ~, handles)
handles = channel_enable_disable(hObject,handles,5);
select_channel(handles.uiSelectChannel,handles);

function uiCheckChannel6_Callback(hObject, ~, handles)
handles = channel_enable_disable(hObject,handles,6);
select_channel(handles.uiSelectChannel,handles);

% DISPLAY SETTINGS
function uiSelectRollingAverageFrames_Callback(hObject, ~, handles)
uiSelectRollingAverageFramesSeparateCallback(hObject,handles);

function uiTextTargetRefresh_Callback(hObject, ~, handles)
uiTextTargetRefreshSeparateCallback(hObject,handles);

function uiButtonResetLevels_Callback(hObject, ~, handles)
uiButtonResetLevelsSeparateCallback(hObject,handles);

function uiButtonAutoscaleLevels_Callback(hObject, ~, handles)
uiButtonAutoscaleLevelsSeparateCallback(hObject,handles);

function uiCheckContinuousAutoScale_Callback(hObject, ~, handles)
uiCheckContinuousAutoScaleSeparateCallback(hObject,handles);

% CAPTURE SETTINGS
function uiTextFramesetsToCapture_Callback(hObject, ~, handles)
uiTextFramesetsToCaptureSeparateCallback(hObject,handles);

function uiButtonFlash_Callback(hObject, ~, handles)
toggle_pseudo_flash(hObject,handles);

function uiTextFileBaseName_Callback(hObject, ~, handles)
uiTextFileBaseNameSeparateCallback(hObject,handles);

function uiDisplayCaptureNumber_Callback(~, ~, ~)
% no callback since always disabled from edit (automatically incremented)

% DISPLAY RANGE
function uiTextDisplayLow_Callback(hObject, ~, handles)
uiTextDisplayLowSeparateCallback(hObject,handles);

function uiTextDisplayHigh_Callback(hObject, ~, handles)
uiTextDisplayHighSeparateCallback(hObject,handles);



%% PREVIEW FUNCTION
function uiButtonPreview_Callback(hObject, eventdata, handles)
if get(hObject,'Value') % ... if the button has been depressed ...
    handles = disable_controls(handles); % Disable controls that are not allowed to be updated
    set(hObject,'String','Stop'); % switch the button's label
    digitalOutputScan = [1, handles.settings.flash, handles.settings.channelsEnable(2:end)]; % display 1 on "acquisition" bit & enabled channels
    outputSingleScan(handles.daqHandle,digitalOutputScan);
    
    % Get full frame and sequence info
    frameWidth = handles.settings.numCols; frameHeight = handles.settings.numRows;
    [rc,frameStride] = AT_GetInt(handles.camHandle,'AOIStride'); AT_CheckWarning(rc);
    numChannels = int32(sum(handles.settings.channelsEnable)); 
    channelsEnableCumulSum = cumsum(handles.settings.channelsEnable);
    pixelEncoding = handles.settings.pixelEncoding;
    
    % Display data limits (what fraction of the image field to use in image
    % preview and histogram calcs). Displaying part of frame is faster.
    x1 = handles.settings.histXRangeLow; x2 = handles.settings.histXRangeHigh;
    y1 = handles.settings.histYRangeLow; y2 = handles.settings.histYRangeHigh;
    
    % Rolling average buffer (w/ 16b encoding we risk saturating this
    % datatype, but likely we're not using frame averaging with high DR)
    avgBuffer = zeros([y2-y1+1, x2-x1+1, handles.settings.avgBufferSize],'uint16');
    
    % Make the raw buffer/MATLAB buffer
    rawBuffer = zeros([handles.settings.imageSizeBytes,handles.settings.totalFrames],'uint8');
    
    % Compute number of frames to skip displaying, and show refresh rate in UI
    showNthFrame = int32(numChannels*round(handles.settings.framesetRate/handles.settings.targetRefresh));
    if showNthFrame < 1, showNthFrame = 1; end
    handles.settings.actualRefresh = handles.settings.frameRate/double(showNthFrame);
    set(handles.uiTextTargetRefresh,'String',num2str(round(handles.settings.actualRefresh*100)/100));
    
    % Circular buffer indices (0-start because we'll use a bunch of mod cmds)
    bufferIndex = int32(0); nextAvgFrame = int32(0); autoScaleCounter = int32(0);
    
    % Compute first frame to show (use 0-based index, like bufferIndex)
    oldChannelInSeq = channelsEnableCumulSum(handles.settings.selectChannel);
    nextFrameToShow = int32(oldChannelInSeq - 1);
    
    % Make list of recent refresh times
    recentRefreshRates = zeros(8,1);
    
    % Before starting, push new handles struct to GUI data
    guidata(hObject,handles);
    
    % START!
    rc = AT_Command(handles.camHandle,'AcquisitionStart'); AT_CheckWarning(rc);

    % Loop around grabbing available frame
    tic; lastTime = toc;
    while get(hObject,'Value') % continuously loop while preview button is ON, or until capture is hit
        % Get frame data from SDK buffer and put into MATLAB buffer, then
        % requeue the frame (~4ms)
        [rc,rawBuffer(:,bufferIndex+1)] = AT_WaitBuffer(handles.camHandle,1000);
        AT_CheckWarning(rc);
        rc = AT_QueueBuffer(handles.camHandle,handles.settings.imageSizeBytes);
        AT_CheckWarning(rc);

        % Check whether this frame is next scheduled frame to show 
        if bufferIndex == nextFrameToShow
            
            % If it is correct, then convert buffer into matrix (2ms)
            if strcmp(pixelEncoding,'Mono12Packed')
                [rc,frameMatrixRotated] = AT_ConvertMono12PackedToMatrix(rawBuffer(:,bufferIndex+1),frameHeight,frameWidth,frameStride);
            else
                [rc,frameMatrixRotated] = AT_ConvertMono16ToMatrix(rawBuffer(:,bufferIndex+1),frameHeight,frameWidth,frameStride);
            end
            AT_CheckWarning(rc);
            
            % Place cropped and rotated frame in average buffer (0.5ms)
            avgBuffer(:,:,nextAvgFrame+1) = rot90(frameMatrixRotated(x1:x2,y1:y2)); % note the rotation changes index ordering
            nextAvgFrame = mod(nextAvgFrame+1,handles.settings.rollingAverageFrames);
            
            % If the continuous auto-scaling option is selected (8.5ms)
            if (handles.settings.continuousAutoScale==1)
                if autoScaleCounter == 0, uiButtonAutoscaleLevelsSeparateCallback(handles.uiButtonAutoscaleLevels,handles); end
                autoScaleCounter = mod(autoScaleCounter+1,ceil (handles.settings.actualRefresh/handles.settings.continuousAutoScaleRate));
            end
            
            % Sum buffer and update image axis CData (2.8ms)
            sumFrame = sum(avgBuffer(:,:,1:handles.settings.rollingAverageFrames),3,'native');
            scaled8bFrame = uint8((sumFrame - handles.displayOffset)*handles.displayScale);
            set(handles.retinaImg, 'CData', scaled8bFrame);
                       
            % Recompute histogram (1.6ms)
            handles.retinaHist.Data = bitshift(sumFrame,-log2(double(handles.settings.rollingAverageFrames)));
            
            % Must drawnow to show new frame and histogram--also
            % interruption point (1024x1024:90ms, 724x724:30ms)
            drawnow;
                        
            % Get new GUI data in case anything has been changed (7ms)
            handles = guidata(hObject);
            
            % Adjust nextFrameToShow if "Select Channel" is changed
            if channelsEnableCumulSum(handles.settings.selectChannel) ~= oldChannelInSeq
                % Take old nextFrameToShow, add the relative position of
                % new channel, and add/skip another whole frame sequence
                % to give more time.
                nextFrameToShow = nextFrameToShow + (channelsEnableCumulSum(handles.settings.selectChannel)-oldChannelInSeq) + numChannels;
                oldChannelInSeq = channelsEnableCumulSum(handles.settings.selectChannel);
            end
            
            % Adjust showNthFrame if frame rate or target refresh change
            if int32(numChannels*round(handles.settings.frameRate/(numChannels*handles.settings.targetRefresh))) ~= showNthFrame
                showNthFrame = int32(numChannels*round(handles.settings.frameRate/(numChannels*handles.settings.targetRefresh)));
                if showNthFrame < 1, showNthFrame = 1; end
                handles.settings.actualRefresh = handles.settings.frameRate/double(showNthFrame);
                set(handles.uiTextTargetRefresh,'String',num2str(round(handles.settings.actualRefresh*100)/100));
            end
            
            % Compute next frame to display (<1ms)
            nextFrameToShow = mod(nextFrameToShow+showNthFrame, handles.settings.totalFrames);
            
            % Update refresh rate display
            thisTime = toc; % compute screen refresh rate
            recentRefreshRates = circshift(recentRefreshRates,1);
            recentRefreshRates(1) = 1/(thisTime - lastTime);         lastTime = thisTime;
            set(handles.displayRefreshRate,'String',['Refresh rate: ' num2str(round(100*mean(recentRefreshRates))/100) ' Hz']);
        end
        
        % Advance the buffer index - and loop around when in Preview Mode
        bufferIndex = mod(bufferIndex+1,handles.settings.totalFrames);
        
    end
    handles = guidata(hObject);
    
    % Re-enable controls
    handles = enable_controls(handles);
    set(hObject,'String','Start Preview');
    digitalOutputScan = [0, handles.settings.flash, handles.settings.channelsEnable(2:end)]; % tell arduino that we've ended
    outputSingleScan(handles.daqHandle,digitalOutputScan);
    
    % Redo allocation 
    handles = reallocate_series_buffer(handles);
    guidata(hObject,handles); % Update GUI handles right before closing out preview
    
    % Check whether we've been instructed to jump straight into capture
    if handles.jumpPreviewToCapture == 1
        handles.jumpPreviewToCapture = 0;
        set(handles.uiButtonCapture,'Value',1);
        uiButtonCapture_Callback(handles.uiButtonCapture, eventdata, handles);
    end
    
else
    % Self-interruption: turns the freerun off immediately
    rc = AT_Command(handles.camHandle,'AcquisitionStop'); AT_CheckWarning(rc);
    
end
  

%% CAPTURE FUNCTION 
function uiButtonCapture_Callback(hObject, eventdata, handles)
if get(handles.uiButtonPreview,'Value') % If Preview Mode is on, turn it off
    set(handles.uiButtonPreview,'Value',0);
    uiButtonPreview_Callback(handles.uiButtonPreview,eventdata,handles); % call the callback just as if it had be pressed to turn off
    handles.jumpPreviewToCapture = 1; % flag that we're jumping straight into a capture
    % Admittedly, this is a roundabout way of doing this: we're in preview
    % mode, then capture is called which calls preview mode again to turn
    % it off, and just before the first preview callback concludes, we call
    % capture callback
    guidata(hObject,handles);
else
    if get(hObject,'Value') % ... if the button has been depressed ... 
        handles = disable_all_controls(handles); % Disable all controls
        set(hObject,'String','Abort'); % switch the button's label
        digitalOutputScan = [1, handles.settings.flash, handles.settings.channelsEnable(2:end)]; % display 1 on "acquisition" bit & enabled channels
        outputSingleScan(handles.daqHandle,digitalOutputScan);

        % Get full frame and sequence info
        frameWidth = handles.settings.numCols; frameHeight = handles.settings.numRows;
        [rc,frameStride] = AT_GetInt(handles.camHandle,'AOIStride'); AT_CheckWarning(rc);
        numChannels = int32(sum(handles.settings.channelsEnable)); 
        channelsEnableCumulSum = cumsum(handles.settings.channelsEnable);
        pixelEncoding = handles.settings.pixelEncoding;
        targetFramesToAcquire = handles.settings.totalFrames;
        
        % Display data limits (what fraction of the image field to use in image
        % preview and histogram calcs). Displaying part of frame is faster.
        x1 = handles.settings.histXRangeLow; x2 = handles.settings.histXRangeHigh;
        y1 = handles.settings.histYRangeLow; y2 = handles.settings.histYRangeHigh;

        % Rolling average buffer (w/ 16b encoding we risk saturating this
        % datatype, but likely we're not using frame averaging with high DR)
        avgBuffer = zeros([y2-y1+1, x2-x1+1, handles.settings.avgBufferSize],'uint16');
        
        % Make the raw buffer/MATLAB buffer
        rawBuffer = zeros([handles.settings.imageSizeBytes,handles.settings.totalFrames],'uint8');

        % Compute number of frames to skip displaying, and show refresh rate in UI
        showNthFrame = int32(numChannels*round(handles.settings.framesetRate/handles.settings.targetRefresh));
        if showNthFrame < 1, showNthFrame = 1; end
        handles.settings.actualRefresh = handles.settings.frameRate/double(showNthFrame);
        set(handles.uiTextTargetRefresh,'String',num2str(round(handles.settings.actualRefresh*100)/100));
    
        % Circular buffer indices (0-start because we'll use a bunch of mod cmds)
        bufferIndex = int32(0); nextAvgFrame = int32(0); autoScaleCounter = int32(0);

        % Compute first frame to show (use 0-based index, like bufferIndex)
        oldChannelInSeq = channelsEnableCumulSum(handles.settings.selectChannel);
        nextFrameToShow = int32(oldChannelInSeq - 1);

        % Make list of recent refresh times
        recentRefreshRates = zeros(8,1);

        % Before starting, push new handles struct to GUI data
        guidata(hObject,handles);
        
        % Note the time
        handles.settings.captureStartTime = datestr(datetime);
        
        % START!
        rc = AT_Command(handles.camHandle,'AcquisitionStart'); AT_CheckWarning(rc);

        % Loop grabbing frames until reaching target number of frames
        tic; lastTime = toc;
        while bufferIndex < targetFramesToAcquire && get(hObject,'Value')
            % Get frame data from SDK buffer and put into MATLAB buffer, then
            % requeue the frame (~4ms for 1MPixel)
            [rc,rawBuffer(:,bufferIndex+1)] = AT_WaitBuffer(handles.camHandle,1000);
            AT_CheckWarning(rc);
            rc = AT_QueueBuffer(handles.camHandle,handles.settings.imageSizeBytes);
            AT_CheckWarning(rc);
            
            % Check whether this frame is next scheduled frame to show 
            if bufferIndex == nextFrameToShow

               % If it is correct, then convert buffer into matrix (2ms)
                if strcmp(pixelEncoding,'Mono12Packed')
                    [rc,frameMatrixRotated] = AT_ConvertMono12PackedToMatrix(rawBuffer(:,bufferIndex+1),frameHeight,frameWidth,frameStride);
                else
                    [rc,frameMatrixRotated] = AT_ConvertMono16ToMatrix(rawBuffer(:,bufferIndex+1),frameHeight,frameWidth,frameStride);
                end
                AT_CheckWarning(rc);

                % Place cropped and rotated frame in average buffer (0.5ms)
                avgBuffer(:,:,nextAvgFrame+1) = rot90(frameMatrixRotated(x1:x2,y1:y2)); % note the rotation changes index ordering
                nextAvgFrame = mod(nextAvgFrame+1,handles.settings.rollingAverageFrames);

                % If the continuous auto-scaling option is selected (8.5ms)
                if (handles.settings.continuousAutoScale==1)
                    if autoScaleCounter == 0, uiButtonAutoscaleLevelsSeparateCallback(handles.uiButtonAutoscaleLevels,handles); end
                    autoScaleCounter = mod(autoScaleCounter+1,ceil (handles.settings.actualRefresh/handles.settings.continuousAutoScaleRate));
                end
                
                % Sum buffer and update image axis CData (2.8ms)
                sumFrame = sum(avgBuffer(:,:,1:handles.settings.rollingAverageFrames),3,'native');
                scaled8bFrame = uint8((sumFrame - handles.displayOffset)*handles.displayScale);
                set(handles.retinaImg, 'CData', scaled8bFrame);
                
                % Recompute histogram (1.6ms)
                handles.retinaHist.Data = bitshift(sumFrame,-log2(double(handles.settings.rollingAverageFrames)));

                % Must drawnow to show new frame and histogram--also
                % interruption point (1024x1024:90ms, 724x724:30ms)
                drawnow;
                
                % Get new GUI data (flash may have changed)
                handles = guidata(hObject);
                if (handles.settings.flash == 1) && (handles.settings.flashStartFrame == -1)
                    handles.settings.flashStartFrame = bufferIndex;
                end
                
                % Compute next frame to display (<1ms)
                nextFrameToShow = mod(nextFrameToShow+showNthFrame, handles.settings.totalFrames);
                
                % Update refresh rate display
                thisTime = toc; % compute screen refresh rate
                recentRefreshRates = circshift(recentRefreshRates,1);
                recentRefreshRates(1) = 1/(thisTime - lastTime);         lastTime = thisTime;
                set(handles.displayRefreshRate,'String',['Refresh rate: ' num2str(round(100*mean(recentRefreshRates))/100) ' Hz']);   
                
                % Display capture progress
                set(hObject,'String',['Abort (' num2str(bufferIndex) '/' num2str(targetFramesToAcquire) ')']);
            end
            
            % Advance the buffer index - no circular looping in Capture
            bufferIndex = bufferIndex+1;
            
        end
        % if capture button is still ON, then we have not aborted, stop camera and save
        if get(hObject,'Value')
            % STOP! we have enough frames
            rc = AT_Command(handles.camHandle,'AcquisitionStop'); AT_CheckWarning(rc);
            
            % Also let arduino know we've stopped
            digitalOutputScan = [0, handles.settings.flash, handles.settings.channelsEnable(2:end)];
            outputSingleScan(handles.daqHandle,digitalOutputScan);
            
            % Extract data and save
            handles = extract_save_data(handles,rawBuffer,targetFramesToAcquire);
            handles = save_settings(handles);
            handles = advance_capture_number(handles); % find next capture number

            % Re-enable controls, switch button's label
            handles = enable_all_controls(handles);
            set(hObject,'String','Start Capture'); set(hObject,'Value',0);
            disp('Capture Finished');
            
            guidata(hObject,handles); % Update GUI handles right before closing out
        end
    else
        % We are aborting the capture, so stop camera
        rc = AT_Command(handles.camHandle,'AcquisitionStop'); AT_CheckWarning(rc);
        disp('Aborting capture')
        
        % Switch back the button's label
        set(hObject,'String','Start Capture');
        
        % Don't save aborted data. Re-enable controls
        handles = enable_all_controls(handles);
        digitalOutputScan = [0, handles.settings.flash, handles.settings.channelsEnable(2:end)]; % tell arduino that we've ended
        outputSingleScan(handles.daqHandle,digitalOutputScan);
        guidata(hObject,handles); % Update GUI handles right before closing out
    end
end

%% OUTPUT FUNCTION - not used
function varargout = acquisition_GUI_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


%% CREATE FUNCTIONS - no custom code here, but necesssary to start program
function uiTextFrameRate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uiTextFrameRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function uiTextNumCols_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function uiTextNumRows_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function uiSelectPreAmp_CreateFcn(hObject, eventdata, handles)

function uiSelectChannel_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function uiTextFramesetsToCapture_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function uiTextFileBaseName_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function uiSelectBitdepth_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function uiSelectRollingAverageFrames_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function uiTextDisplayLow_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function uiTextDisplayHigh_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function uiTextHardwareOffset_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function uiDisplayCaptureNumber_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function uiTextTargetRefresh_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% HOTKEYS 
% supported: F1 (Preview), F2 (Cont. Auto Scale), F4 (Capture), F5 (Flash)
function acquisitionGUIFig_WindowKeyPressFcn(hObject, eventdata, handles)
% Key that was pressed is in eventdata.Key field
if strcmp(eventdata.Key,'f1') % Toggle Preview Button and run callback
    oldValue = get(handles.uiButtonPreview,'Value');
    set(handles.uiButtonPreview,'Value',~oldValue);
    uiButtonPreview_Callback(handles.uiButtonPreview, eventdata, handles);

elseif strcmp(eventdata.Key,'f4') % Toggle Capture button and run callback
    oldValue = get(handles.uiButtonCapture,'Value');
    set(handles.uiButtonCapture,'Value',~oldValue);
    uiButtonCapture_Callback(handles.uiButtonCapture, eventdata, handles);
    
elseif strcmp(eventdata.Key,'f2') % Toggle continuous autoscale and run callback
    oldValue = get(handles.uiCheckContinuousAutoScale,'Value');
    set(handles.uiCheckContinuousAutoScale,'Value',~oldValue);
    uiCheckContinuousAutoScale_Callback(handles.uiCheckContinuousAutoScale, eventdata, handles);
    
elseif strcmp(eventdata.Key,'f5') % Toggle quasi-flash and run callback
    oldValue = get(handles.uiButtonFlash,'Value');
    set(handles.uiButtonFlash,'Value',~oldValue);
    uiButtonFlash_Callback(handles.uiButtonFlash, eventdata, handles);
end

