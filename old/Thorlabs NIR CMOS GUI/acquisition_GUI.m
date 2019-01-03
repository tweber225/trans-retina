function varargout = acquisition_GUI(varargin)
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

% Last Modified by GUIDE v2.5 31-Aug-2018 15:46:08

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
camName = 'DCC3240N'; % in future may add other options
camNumber = 0; % in future may add support for more than 1 camera
numDigitalPins = 7; % 6 channels plus an 'arm' for acquisition pin

% ADD RELEVANT SUB-FOLDERS TO PATH (allows functions in these folders to be
% called)
addpath(genpath('code')); % Add code subfolders to path

% START UP FUNCTION
start_up_GUI(hObject,handles,camName,camNumber,numDigitalPins);



%% CLOSE FUNCTION --- Executes when user attempts to close acquisitionGUIFig. Very important.
function acquisitionGUIFig_CloseRequestFcn(hObject, ~, handles)
if get(handles.uiButtonCapture,'Value') == 1
    disp('Cannot close window! In middle of capture or saving.'); return % if capture is ongoing, reject the closing request
end
handles.camHandle.Exit; % disables camera handle and releases data structs and memory areas
delete(handles.daqHandle); daqreset % Close DAQ
delete(hObject); % delete(hObject) closes the figure

%% OUTPUT FUNCTION - not used
function varargout = acquisition_GUI_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


%% CALLBACK FUNCTIONS
function uiTextFramerate_Callback(hObject,~,handles)
% Hints: get(hObject,'String') returns contents of uiTextFramerate as text
%        str2double(get(hObject,'String')) returns contents of uiTextFramerate as a double
uiTextFramerateSeparateCallback(hObject,handles);

function uiTextPixelclock_Callback(hObject,~,handles)
uiTextPixelclockSeparateCallback(hObject,handles);

function uiTextNumberLines_Callback(hObject,~,handles)
% Note: Always centers area of interest (AOI, i.e. the result of reducing the number of frame lines) around the middle row
uiTextNumberLinesSeparateCallback(hObject,handles);

function uiSelectBitdepth_Callback(hObject, ~, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns uiSelectBitdepth contents as cell array
%        contents{get(hObject,'Value')} returns selected item from uiSelectBitdepth
uiSelectBitdepthSeparateCallback(hObject,handles);

function uiCheckGainBoost_Callback(hObject, ~, handles)
% Hint: get(hObject,'Value') returns toggle state of uiCheckGainBoost
uiCheckGainBoostSeparateCallback(hObject,handles);

function uiTextHardwareOffset_Callback(hObject, ~, handles)
uiTextHardwareOffsetSeparateCallback(hObject,handles);

function uiTextFramesetsToCapture_Callback(hObject, ~, handles)
uiTextFramesetsToCaptureSeparateCallback(hObject,handles);

function uiSelectRollingAverageFrames_Callback(hObject, ~, handles)
uiSelectRollingAverageFramesSeparateCallback(hObject,handles)

function uiTextDisplayLow_Callback(hObject, ~, handles)
uiTextDisplayLowSeparateCallback(hObject,handles);

function uiTextDisplayHigh_Callback(hObject, ~, handles)
uiTextDisplayHighSeparateCallback(hObject,handles);

function uiTextFileBaseName_Callback(hObject, ~, handles)
uiTextFileBaseNameSeparateCallback(hObject,handles);

function uiCheckChannel1_Callback(hObject, ~, handles)
handles = channel_enable_disable(hObject,handles,1);
select_channel(handles.uiSelectChannel,handles);

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

function uiSelectChannel_Callback(hObject, ~, handles)
select_channel(hObject,handles);

function uiDisplayCaptureNumber_Callback(hObject, eventdata, handles)
% no callback since always disabled from edit (automatically incremented)



%% PREVIEW FUNCTION
% Leave code in main GUI function because speed is important
function uiButtonPreview_Callback(hObject, eventdata, handles)
if get(hObject,'Value') %... if the button is depressed ...
    handles = disable_controls(handles); % Disable controls that are not allowed to be updated
    set(hObject,'String','Stop'); % switch the button's label
    digitalOutputScan = [1 handles.settings.channelsEnable]; % tell arduino that we're going to start (first bit of output)
    outputSingleScan(handles.daqHandle,digitalOutputScan);
    
    frameWidth = handles.constants.sensorXPixels;
    frameHeight = handles.settings.numberLines;
    numChannels = int32(sum(handles.settings.channelsEnable));
    channelsEnableCumulSum = cumsum(handles.settings.channelsEnable);
    seqListCopy = int32(handles.sequenceList);
    finalSeqID = seqListCopy(end);
    
    % Rolling average buffer set-up (16 bit buffer, so that's 64 frame max for 10bit)
    avgBuffer = zeros([64, frameWidth*frameHeight],'uint16');
    
    % Histogram data limits (what fraction of the image field to use in
    % histogram calc)
    x1 = handles.constants.histXRangeLow; x2 = handles.constants.histXRangeHigh;
    y1 = handles.settings.histYRangeLow; y2 = handles.settings.histYRangeHigh;
    
    % FFT data limits and buffer
    xFT1 = round(frameWidth/2-frameHeight/2+1);
    xFT2 = round(frameWidth/2+frameHeight/2);
    bhWindow = single(blackman_harris(round(double(frameHeight)/4)));
    oldFT = zeros(size(bhWindow),'single');
    colormap(handles.extraAxis,hsv)
        
    % Start!
    handles.camHandle.Acquisition.Capture(uEye.Defines.DeviceParameter.DontWait);
    disp('Freerun On')

    % Loop around grabbing last sequence frame(s)
    tic; lastTime = toc;
    recentRefreshRates = zeros(4,1);
    while get(hObject,'Value') % continuously loop while preview button is ON, or until capture is hit
        handles = guidata(hObject); % Update this function's GUI data (which could have been updated in another function)
        selectChannelInAcquisition = channelsEnableCumulSum(handles.settings.selectChannel); % check channel to show
        % Which sequence frame (any channel) was last acquired?
        [~,lastSeqID] = handles.camHandle.Memory.Sequence.GetLast;
        
        % Find the last frame FROM THE SELECTED CHANNEL to display on GUI
        framesIntoSet = mod(lastSeqID-1,numChannels)+1;
        framesetStart = lastSeqID - framesIntoSet;
        if lastSeqID >= framesetStart+selectChannelInAcquisition
            lastSelectedChannelSeqID = framesetStart+selectChannelInAcquisition;
        else
            lastSelectedChannelSeqID = mod(framesetStart-numChannels+selectChannelInAcquisition,finalSeqID);
        end
        
        % Compute sequence ID's (and corresponding memory IDs) to acquire
        framesToGet = mod(lastSelectedChannelSeqID - (0:(handles.settings.rollingAverageFrames-1))*numChannels - 1,finalSeqID) + 1;
        for avgIdx = 1:handles.settings.rollingAverageFrames % Copy the image data for the last X frames of selected channel
            [~,lastMemID] = handles.camHandle.Memory.Sequence.ToMemoryID(framesToGet(avgIdx));
            [~,rawFrameData] = handles.camHandle.Memory.CopyToArray(lastMemID,handles.colorMode);
            avgBuffer(avgIdx,:) = uint16(rawFrameData); % put into buffer
        end
          
        % Sum and display buffer
        sumFrame = reshape(sum(avgBuffer(1:handles.settings.rollingAverageFrames,:),1,'native'),[frameWidth frameHeight])';
        scaled8bFrame = uint8((sumFrame - handles.displayOffset)*handles.displayScale);
        set(handles.retinaImg, 'CData', scaled8bFrame);
        
        % Compute and display fft of decimated frame
        FTSmallSquareFrame = fftshift(fft2(imresize(single(sumFrame(:,xFT1:xFT2)),1/4).*bhWindow));
        xPowSpec = FTSmallSquareFrame.*conj(oldFT);
        set(handles.retinaExtra, 'CData', angle(xPowSpec));
        oldFT = FTSmallSquareFrame;
        
        % Recompute histogram
        handles.retinaHist.Data = bitshift(sumFrame(y1:y2,x1:x2),-log2(double(handles.settings.rollingAverageFrames)));
        drawnow; %Must drawnow to show new frame and histogram--also the interruption point when stopping
        
        % Update refresh rate
        thisTime = toc; % compute screen refresh rate
        recentRefreshRates = circshift(recentRefreshRates,1);
        recentRefreshRates(1) = 1/(thisTime - lastTime);         lastTime = thisTime;
        set(handles.displayRefreshRate,'String',['Refresh rate: ' num2str(round(10*mean(recentRefreshRates))/10) ' fps']);
    end
    handles = guidata(hObject);
    % Re-enable controls
    handles = enable_controls(handles);
    set(hObject,'String','Start Preview');
    digitalOutputScan = [0 handles.settings.channelsEnable]; % tell arduino that we've ended
    outputSingleScan(handles.daqHandle,digitalOutputScan);
    % redo allocation (in case frame rate was changed)
    [handles.sequenceList,handles.memoryIDList] = adjust_sequence_allocation(handles.camHandle,handles.settings,handles.constants,handles.memoryIDList);
    guidata(hObject,handles); % Update GUI handles right before closing out preview
    % Check whether we've been instructed to jump straight into capture
    if handles.jumpPreviewToCapture == 1
        handles.jumpPreviewToCapture = 0;
        set(handles.uiButtonCapture,'Value',1);
        uiButtonCapture_Callback(handles.uiButtonCapture, eventdata, handles);
    end
    
else
    % Self-interruption: turns the freerun off immediately
    handles.camHandle.Acquisition.Stop;
    disp('Freerun Off')
end
  



%% CAPTURE FUNCTION 
% Leave code in main GUI function because speed is important
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
    if get(hObject,'Value')
        handles = disable_all_controls(handles); % Disable all controls
        set(hObject,'String','Abort'); % switch the button
        digitalOutputScan = [1 handles.settings.channelsEnable]; % tell arduino that we're going to start
        outputSingleScan(handles.daqHandle,digitalOutputScan);

        frameWidth = handles.constants.sensorXPixels;
        frameHeight = handles.settings.numberLines;
        numChannels = int32(sum(handles.settings.channelsEnable));
        targetFramesToAcquire = numChannels*handles.settings.framesetsToCapture;
        channelsEnableCumulSum = cumsum(handles.settings.channelsEnable);
        selectChannelInAcquisition = channelsEnableCumulSum(handles.settings.selectChannel); % only needs to be updated once
        seqListCopy = int32(handles.sequenceList);
        finalSeqID = seqListCopy(end);

        % Rolling average buffer set-up (16 bit buffer, 64 frame max for 10bit)
        avgBuffer = zeros([64, frameWidth*frameHeight],'uint16');

        % Histogram data limits
        x1 = handles.constants.histXRangeLow; x2 = handles.constants.histXRangeHigh;
        y1 = handles.settings.histYRangeLow; y2 = handles.settings.histYRangeHigh;

        % Start
        handles.settings.captureStartTime = datestr(datetime); % note start time
        handles.camHandle.Acquisition.Capture(uEye.Defines.DeviceParameter.DontWait);
        disp('Starting Capture')

        % Loop around grabbing last sequence frame(or frameS if averaging), until acquiring enough
        tic; lastTime = toc; recentRefreshRates = zeros(4,1);
        lastSeqID = 0;
        while lastSeqID < targetFramesToAcquire && get(hObject,'Value')
            % Which sequence frame was last acquired?
            [~,lastSeqID] = handles.camHandle.Memory.Sequence.GetLast;

            % Find the last frame FROM THE SELECTED CHANNEL to display on GUI'
            framesIntoSet = mod(lastSeqID-1,numChannels)+1;
            framesetStart = lastSeqID - framesIntoSet;
            if lastSeqID >= framesetStart+selectChannelInAcquisition
                lastSelectedChannelSeqID = framesetStart+selectChannelInAcquisition;
            else
                lastSelectedChannelSeqID = mod(framesetStart-numChannels+selectChannelInAcquisition,finalSeqID);
            end

            % Compute sequence ID's (and corresponding memory IDs) to acquire
            framesToGet = mod(lastSelectedChannelSeqID - (0:(handles.settings.rollingAverageFrames-1))*numChannels - 1,finalSeqID) + 1;
            for avgIdx = 1:handles.settings.rollingAverageFrames % Copy the image data for the last X frames of selected channel
                [~,lastMemID] = handles.camHandle.Memory.Sequence.ToMemoryID(framesToGet(avgIdx));
                [~,rawFrameData] = handles.camHandle.Memory.CopyToArray(lastMemID,handles.colorMode);
                avgBuffer(avgIdx,:) = uint16(rawFrameData); % put into buffer
            end

            % Sum and display buffer, recompute histogram, update refresh rate
            sumFrame = reshape(sum(avgBuffer(1:handles.settings.rollingAverageFrames,:),1,'native'),[frameWidth frameHeight])';
            scaled8bFrame = uint8((sumFrame - handles.displayOffset)*handles.displayScale);
            set(handles.retinaImg, 'CData', scaled8bFrame);
            handles.retinaHist.Data = bitshift(sumFrame(y1:y2,x1:x2),-log2(double(handles.settings.rollingAverageFrames)));
            drawnow; %Must drawnow to show new frame and histogram--also the interruption point when stopping
            thisTime = toc; % compute screen refresh rate
            recentRefreshRates = circshift(recentRefreshRates,1);
            recentRefreshRates(1) = 1/(thisTime - lastTime);         lastTime = thisTime;
            set(handles.displayRefreshRate,'String',['Refresh rate: ' num2str(round(10*mean(recentRefreshRates))/10) ' fps']);
            % also display on button the capture progress
            set(hObject,'String',['Abort (' num2str(lastSeqID) '/' num2str(targetFramesToAcquire) ')']);
            % Check that last sequence ID again
            [~,lastSeqID] = handles.camHandle.Memory.Sequence.GetLast;
        end
        %if capture button is still ON, then not aborted, stop camera and save
        if get(hObject,'Value')
            handles.camHandle.Acquisition.Stop; % Stop! we have enough frames
            digitalOutputScan = [0 handles.settings.channelsEnable]; % tell arduino that we've ended
            outputSingleScan(handles.daqHandle,digitalOutputScan);
            
            % Extract data and save
            handles = extract_save_data(handles,targetFramesToAcquire);
            handles = save_settings(handles);
            handles = advance_capture_number(handles); % find next capture number

            % Re-enable controls
            handles = enable_all_controls(handles);
            set(hObject,'String','Start Capture'); set(hObject,'Value',0);
            disp('Capture Finished');
            
            guidata(hObject,handles); % Update GUI handles right before closing out
        end
    else
        % Aborting: turn the freerun off
        handles.camHandle.Acquisition.Stop;
        disp('Aborting capture')
        set(hObject,'String','Start Capture'); 
        % Don't save aborted data
        % Re-enable controls
        handles = enable_all_controls(handles);
        digitalOutputScan = [0 handles.settings.channelsEnable]; % tell arduino that we've ended
        outputSingleScan(handles.daqHandle,digitalOutputScan);
        guidata(hObject,handles); % Update GUI handles right before closing out
    end
end

%% LEVELS FUNCTIONS 
function uiButtonAutoscaleLevels_Callback(hObject, ~, handles)
uiButtonAutoscaleLevelsSeparateCallback(hObject,handles);

function uiButtonResetLevels_Callback(hObject, ~, handles)
uiButtonResetLevelsSeparateCallback(hObject,handles)


%% CREATE FUNCTIONS - uninteresting but necesssary to start
function uiTextFramerate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uiTextFramerate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function uiTextPixelclock_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function uiTextNumberLines_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function uiCheckGainBoost_CreateFcn(hObject, eventdata, handles)

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
