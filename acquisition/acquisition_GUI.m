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

% Last Modified by GUIDE v2.5 30-Aug-2018 13:20:36

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
function acquisition_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
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

% CAMERA CHOICE
camName = 'DCC3240N'; % in future may add other options

% START UP
addpath(genpath('code')); % Add code subfolders to path
handles.camHandle = initialize_NET_camhandle_displaymode_shutter_trigger_GPIO(0);
handles.daqHandle = initialize_DAQ(7);
disable_hotpixel_correction_auto_offset(handles.camHandle)

% LOAD & SET DEFAULT SETTINGS, CONSTANTS
handles.constants = set_constants(camName);
handles = set_default_settings(handles,eventdata,camName);
handles.displayOffset = handles.settings.displayRangeLow*double(handles.settings.rollingAverageFrames);
handles.displayScale = 256/((handles.settings.displayRangeHigh-handles.settings.displayRangeLow)*double(handles.settings.rollingAverageFrames));
if handles.settings.bitdepth == 8
    handles.colorMode = uEye.Defines.ColorMode.Mono8; 
elseif handles.settings.bitdepth == 10
    handles.colorMode = uEye.Defines.ColorMode.Mono10; 
end

% ALLOCATE IMAGE SEQUENCE MEMORY
[handles.sequenceList,handles.memoryIDList] = allocate_sequence(handles.camHandle,handles.settings,handles.constants);

% UPDATE TIMING&MEMORY DISPLAYS
handles = update_timing_memory(handles);

% RENDER BLANK FRAME
handles.blankFrame = zeros([handles.settings.numberLines,handles.constants.sensorXPixels],'uint8'); %always show 8-bit images on screen
imshow(handles.blankFrame, [0, 256], 'Parent', handles.retinaAxis)
handles.retinaImg = get(handles.retinaAxis,'Children');

% RENDER HISTOGRAM
handles.histogramBinEdges = linspace(0,2^handles.settings.bitdepth,handles.constants.histogramBins);
handles.retinaHist = histogram(uint16(handles.blankFrame),handles.histogramBinEdges,'Parent',handles.histAxis); %histogram is always 16-bit
handles.histAxis.XLim = [handles.histogramBinEdges(1) handles.histogramBinEdges(end)];
handles.histAxis.YScale = 'log';
handles.histAxis.YLim = [1 10^4];

% UPDATE GUI HANDLES STRUCT
guidata(hObject,handles)


%% CLOSE FUNCTION
% --- Executes when user attempts to close acquisitionGUIFig.
function acquisitionGUIFig_CloseRequestFcn(hObject, eventdata, handles)
handles.camHandle.Exit; % disables camera handle and releases data structs and memory areas
delete(handles.daqHandle); daqreset % Close DAQ
delete(hObject); % delete(hObject) closes the figure

%% OUTPUT FUNCTION
function varargout = acquisition_GUI_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;



%% CALLBACKS
function uiTextFramerate_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of uiTextFramerate as text
%        str2double(get(hObject,'String')) returns contents of uiTextFramerate as a double
targetFramerate = str2double(get(hObject,'String'));
[actualFramerate,~] = set_framerate(handles.camHandle,targetFramerate,handles.constants.fracFramePeriodForExposure);
handles.settings.framerate = actualFramerate;
set(handles.uiTextFramerate,'String',num2str(0.1*round(actualFramerate*10)));
% also adjust sequence allocation (mostly the last few buffer frames) 
if ~get(handles.uiButtonPreview,'Value') %... but don't if in the middle of live mode since we're using the allocation!
    [handles.sequenceList,handles.memoryIDList] = adjust_sequence_allocation(handles.camHandle,handles.settings,handles.constants,handles.memoryIDList);
end
handles = update_timing_memory(handles); % Update displays
guidata(hObject,handles);

function uiTextPixelclock_Callback(hObject, eventdata, handles)
targetPixelclock = str2double(get(hObject,'String'));
actualPixelclock = set_pixelclock(handles.camHandle,targetPixelclock);
handles.settings.pixelclock = actualPixelclock;
set(handles.uiTextPixelclock,'String',actualPixelclock);
uiTextFramerate_Callback(handles.uiTextFramerate,eventdata,handles); % Update framerate
% displays updated by uiTextFramerate_Callback
guidata(hObject,handles);

function uiTextNumberLines_Callback(hObject, eventdata, handles)
targetLines = str2double(get(hObject,'String'));
% check that we're not exceeding max allocation size
estimatedAllocationSize = targetLines*handles.constants.sensorXPixels*ceil(handles.settings.bitdepth/8)*handles.settings.framesetsToCapture*sum(handles.settings.channelsEnable)/2^20;
if estimatedAllocationSize > handles.settings.maxAllocationSize
    set(hObject,'String',num2str(handles.settings.numberLines)); % set to old number of lines
    disp('Tried to allocate more memory than max allowable!'); guidata(hObject,handles); return % update GUI and get out
end
xPix = handles.constants.sensorXPixels; yPix = handles.constants.sensorYPixels;
actualNumberLines = set_AOI_for_num_lines(handles.camHandle,targetLines,xPix,yPix);
handles.settings.numberLines = actualNumberLines;
set(handles.uiTextNumberLines,'String',actualNumberLines);
uiTextFramerate_Callback(handles.uiTextFramerate,eventdata,handles); % Redo framerate
% and finally redo sequence allocation
[handles.sequenceList,handles.memoryIDList] = reallocate_sequence(handles.camHandle,handles.settings,handles.constants,handles.memoryIDList);
handles = update_timing_memory(handles); % Update displays
handles.settings.histYRangeLow = round(handles.settings.numberLines/2-handles.constants.sensorYPixels/6);
if handles.settings.histYRangeLow < 1
    handles.settings.histYRangeLow = 1;
end
handles.settings.histYRangeHigh = round(handles.settings.numberLines/2+handles.constants.sensorYPixels/6);
if handles.settings.histYRangeHigh > handles.settings.numberLines
    handles.settings.histYRangeHigh = handles.settings.numberLines;
end
guidata(hObject,handles);

function uiSelectBitdepth_Callback(hObject, eventdata, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns uiSelectBitdepth contents as cell array
%        contents{get(hObject,'Value')} returns selected item from uiSelectBitdepth
bitdepthOptions = cellstr(get(handles.uiSelectBitdepth,'String'));
bitdepthIndex = 1:numel(bitdepthOptions);
targetBitdepth = str2double(bitdepthOptions{get(hObject,'Value')});
% check that we're not exceeding max allocation size
estimatedAllocationSize = double(handles.settings.numberLines)*handles.constants.sensorXPixels*ceil(targetBitdepth/8)*handles.settings.framesetsToCapture*sum(handles.settings.channelsEnable)/2^20;
if estimatedAllocationSize > handles.settings.maxAllocationSize
    set(hObject,'Value',abs(get(hObject,'Value')-3)); % set to old bitdepth, this only works for 2 bit depths options
    disp('Tried to allocate more memory than max allowable!'); guidata(hObject,handles); return % update GUI and get out
end
actualBitdepth = set_bitdepth(handles.camHandle,targetBitdepth);
handles.settings.bitdepth = actualBitdepth;
set(handles.uiSelectBitdepth,'Value',bitdepthIndex(strcmp(bitdepthOptions,num2str(actualBitdepth))));
if handles.settings.bitdepth == 8
    handles.colorMode = uEye.Defines.ColorMode.Mono8; 
elseif handles.settings.bitdepth == 10
    handles.colorMode = uEye.Defines.ColorMode.Mono10; 
end
% new bitdepth set, now need to reallocate sequence
[handles.sequenceList,handles.memoryIDList] = reallocate_sequence(handles.camHandle,handles.settings,handles.constants,handles.memoryIDList);
handles = update_timing_memory(handles); % Update displays
% update histogram data
handles.histogramBinEdges = linspace(0,2^handles.settings.bitdepth,handles.constants.histogramBins);
handles.retinaHist = histogram(uint16(handles.blankFrame),handles.histogramBinEdges,'Parent',handles.histAxis); %histogram is always 16-bit
handles.histAxis.XLim = [handles.histogramBinEdges(1) handles.histogramBinEdges(end)];
handles.histAxis.YScale = 'log';
drawnow;
% update display range
if actualBitdepth == 8 % must do these in different orders
    set(handles.uiTextDisplayLow,'String',num2str(handles.settings.displayRangeLow*(1/4)));
    uiTextDisplayLow_Callback(handles.uiTextDisplayLow, eventdata, handles);
    handles = guidata(hObject); % get back gui data set in line above
    set(handles.uiTextDisplayHigh,'String',num2str(handles.settings.displayRangeHigh*(1/4)));
    uiTextDisplayHigh_Callback(handles.uiTextDisplayHigh, eventdata, handles);
elseif actualBitdepth == 10
    set(handles.uiTextDisplayHigh,'String',num2str(handles.settings.displayRangeHigh*(4)));
    uiTextDisplayHigh_Callback(handles.uiTextDisplayHigh, eventdata, handles);
    handles = guidata(hObject); % get back gui data set in line above
    set(handles.uiTextDisplayLow,'String',num2str(handles.settings.displayRangeLow*(4)));
    uiTextDisplayLow_Callback(handles.uiTextDisplayLow, eventdata, handles);
end

function uiCheckGainBoost_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of uiCheckGainBoost
targetGainBoost = logical(get(hObject,'Value'));
actualGainBoost = set_gainboost(handles.camHandle,targetGainBoost);
handles.settings.gainBoost = actualGainBoost;
set(handles.uiCheckGainBoost,'Value',actualGainBoost);
guidata(hObject,handles);

function uiTextHardwareOffset_Callback(hObject, eventdata, handles)
targetValue = str2double(get(hObject,'String'));
if targetValue < 0 % check if valid value
    actualValue = 0;
elseif targetValue > 255
    actualValue = 255;
elseif targetValue-round(targetValue) ~= 0
    actualValue = round(targetValue);
else
    actualValue = targetValue;
end
handles.setting.hardwareOffset = actualValue;
set(hObject,'String',num2str(actualValue));
handles.camHandle.BlackLevel.Offset.Set(int32(actualValue));
guidata(hObject,handles);

function uiTextFramesetsToCapture_Callback(hObject, eventdata, handles)
targetFramesetsToCapture = round(str2double(get(hObject,'String')));
% check that we're not exceeding max allocation size
estimatedAllocationSize = double(handles.settings.numberLines)*handles.constants.sensorXPixels*ceil(handles.settings.bitdepth/8)*targetFramesetsToCapture*sum(handles.settings.channelsEnable)/2^20;
if estimatedAllocationSize > handles.settings.maxAllocationSize
    set(hObject,'String',handles.settings.framesetsToCapture); % set to old # framesets
    disp('Tried to allocate more memory than max allowable!'); guidata(hObject,handles); return % update GUI and get out
end
handles.settings.framesetsToCapture = targetFramesetsToCapture;
set(hObject,'String',targetFramesetsToCapture);
[handles.sequenceList,handles.memoryIDList] = adjust_sequence_allocation(handles.camHandle,handles.settings,handles.constants,handles.memoryIDList);
handles = update_timing_memory(handles); % Update displays
guidata(hObject,handles);

function uiSelectRollingAverageFrames_Callback(hObject, eventdata, handles)
rollingAverageFramesOptions = cellstr(get(handles.uiSelectRollingAverageFrames,'String'));
rollingAverageFramesIdx = 1:numel(rollingAverageFramesOptions);
actualRollingAverageFrames = int32(str2num(rollingAverageFramesOptions{get(hObject,'Value')}));
handles.settings.rollingAverageFrames = actualRollingAverageFrames;
handles.displayOffset = handles.settings.displayRangeLow*double(handles.settings.rollingAverageFrames); % update display offset and scale
handles.displayScale = 256/((handles.settings.displayRangeHigh-handles.settings.displayRangeLow)*double(handles.settings.rollingAverageFrames));
guidata(hObject,handles); 

function uiTextDisplayLow_Callback(hObject, eventdata, handles)
targetValue = str2double(get(hObject,'String')); % get new value
if targetValue < 0 
    targetValue = 0; 
elseif targetValue >= handles.settings.displayRangeHigh
    targetValue = handles.settings.displayRangeHigh-1;
end
actualValue = round(targetValue); % ensure range and round
set(hObject,'String',num2str(actualValue)); % set new
handles.settings.displayRangeLow = actualValue;% update handles
handles.displayOffset = handles.settings.displayRangeLow*double(handles.settings.rollingAverageFrames); % update display offset and scale
handles.displayScale = 256/((handles.settings.displayRangeHigh-handles.settings.displayRangeLow)*double(handles.settings.rollingAverageFrames));
guidata(hObject,handles);

function uiTextDisplayHigh_Callback(hObject, eventdata, handles)
targetValue = str2double(get(hObject,'String')); % get new value
if targetValue > 2^handles.settings.bitdepth 
    targetValue = 2^handles.settings.bitdepth; 
elseif targetValue <= handles.settings.displayRangeLow
    targetValue = handles.settings.displayRangeLow+1;
end
actualValue = round(targetValue); % ensure range and round
set(hObject,'String',num2str(actualValue)); % set new
handles.settings.displayRangeHigh = actualValue;% update handles
handles.displayScale = 256/((handles.settings.displayRangeHigh-handles.settings.displayRangeLow)*double(handles.settings.rollingAverageFrames)); % update display scale
guidata(hObject,handles);

function uiTextFileBaseName_Callback(hObject, eventdata, handles)
handles.settings.fileBaseName = get(hObject,'String');
handles.settings.captureNumber = 1; % reset capture number
handles = advance_capture_number(handles); % check that capture folder does not already exist
guidata(hObject,handles);

function uiCheckChannel1_Callback(hObject, eventdata, handles)
handles = channel_enable_disable(hObject,handles,1);
handles = select_channel(handles.uiSelectChannel,handles);
guidata(hObject,handles);

function uiCheckChannel2_Callback(hObject, eventdata, handles)
handles = channel_enable_disable(hObject,handles,2);
handles = select_channel(handles.uiSelectChannel,handles);
guidata(hObject,handles);

function uiCheckChannel3_Callback(hObject, eventdata, handles)
handles = channel_enable_disable(hObject,handles,3);
handles = select_channel(handles.uiSelectChannel,handles);
guidata(hObject,handles);

function uiCheckChannel4_Callback(hObject, eventdata, handles)
handles = channel_enable_disable(hObject,handles,4);
handles = select_channel(handles.uiSelectChannel,handles);
guidata(hObject,handles);

function uiCheckChannel5_Callback(hObject, eventdata, handles)
handles = channel_enable_disable(hObject,handles,5);
handles = select_channel(handles.uiSelectChannel,handles);
guidata(hObject,handles);

function uiCheckChannel6_Callback(hObject, eventdata, handles)
handles = channel_enable_disable(hObject,handles,6);
handles = select_channel(handles.uiSelectChannel,handles);
guidata(hObject,handles);

function uiSelectChannel_Callback(hObject, eventdata, handles)
handles = select_channel(hObject,handles);
guidata(hObject,handles);

function uiDisplayCaptureNumber_Callback(hObject, eventdata, handles)
% no callback since always diabled from edit



%% PREVIEW FUNCTION
function uiButtonPreview_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    handles = disable_controls(handles); % Disable controls that are not updateable in real-time
    set(hObject,'String','Stop'); % switch the button
    digitalOutputScan = [1 handles.settings.channelsEnable]; % tell arduino that we're going to start
    outputSingleScan(handles.daqHandle,digitalOutputScan);
    
    frameWidth = handles.constants.sensorXPixels;
    frameHeight = handles.settings.numberLines;
    numChannels = int32(sum(handles.settings.channelsEnable));
    channelsEnableCumulSum = cumsum(handles.settings.channelsEnable);
    seqListCopy = int32(handles.sequenceList);
    finalSeqID = seqListCopy(end);
    
    % Rolling average buffer set-up (16 bit buffer, 64 frame max for 10bit)
    avgBuffer = zeros([64, frameWidth*frameHeight],'uint16');
    
    % Histogram data limits
    x1 = handles.constants.histXRangeLow; x2 = handles.constants.histXRangeHigh;
    y1 = handles.settings.histYRangeLow; y2 = handles.settings.histYRangeHigh;
    
    % Start
    handles.camHandle.Acquisition.Capture(uEye.Defines.DeviceParameter.DontWait);
    disp('Freerun On')

    % Loop around grabbing last sequence frame(s)
    tic; lastTime = toc;
    recentRefreshRates = zeros(4,1);
    while get(hObject,'Value')
        handles = guidata(hObject); % get back gui data that might have been updated elsewhere
        selectChannelInAcquisition = channelsEnableCumulSum(handles.settings.selectChannel); % check channel to show
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
    end
    % Re-enable controls
    handles = enable_controls(handles);
    set(hObject,'String','Start Preview');
    digitalOutputScan = [0 handles.settings.channelsEnable]; % tell arduino that we've ended
    outputSingleScan(handles.daqHandle,digitalOutputScan);
    % redo allocation (in case frame rate was changed)
    [handles.sequenceList,handles.memoryIDList] = adjust_sequence_allocation(handles.camHandle,handles.settings,handles.constants,handles.memoryIDList);
    guidata(hObject,handles); % Update GUI handles right before closing out preview
else
    % Turn the freerun off
    handles.camHandle.Acquisition.Stop;
    disp('Freerun Off')
end
  



%% CAPTURE FUNCTION 
function uiButtonCapture_Callback(hObject, eventdata, handles)
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
    disp('Freerun On')

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

        % Extract data and save
        handles = extract_save_data(handles,targetFramesToAcquire);
        handles = save_settings(handles);
        handles = advance_capture_number(handles); % find next capture number

        % Re-enable controls
        handles = enable_all_controls(handles);
        set(hObject,'String','Start Capture'); set(hObject,'Value',0);
        digitalOutputScan = [0 handles.settings.channelsEnable]; % tell arduino that we've ended
        outputSingleScan(handles.daqHandle,digitalOutputScan);
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


%% LEVELS FUNCTIONS 
function uiButtonAutoscaleLevels_Callback(hObject, eventdata, handles)
oldOffset = handles.displayOffset;
oldScale = handles.displayScale;
maxLevel = max(handles.retinaHist.Data(:));
minLevel = min(handles.retinaHist.Data(:));
set(handles.uiTextDisplayLow,'String',num2str(minLevel));
uiTextDisplayLow_Callback(handles.uiTextDisplayLow, eventdata, handles);
handles = guidata(hObject); % get back gui data set in line above
set(handles.uiTextDisplayHigh,'String',num2str(maxLevel));
uiTextDisplayHigh_Callback(handles.uiTextDisplayHigh, eventdata, handles);
handles = guidata(hObject); % get back gui data set in line above
if ~get(handles.uiButtonPreview,'Value')
    oldFrame = double(get(handles.retinaImg, 'CData'));
    oldFrameRaw = (oldFrame/oldScale)+oldOffset;
    oldFrameNewScale = uint8((oldFrameRaw - handles.displayOffset)*handles.displayScale);
    set(handles.retinaImg, 'CData', oldFrameNewScale);
    drawnow;
end

function uiButtonResetLevels_Callback(hObject, eventdata, handles)
oldOffset = handles.displayOffset;
oldScale = handles.displayScale;
set(handles.uiTextDisplayLow,'String',num2str(0));
uiTextDisplayLow_Callback(handles.uiTextDisplayLow, eventdata, handles);
handles = guidata(hObject); % get back gui data set in line above
set(handles.uiTextDisplayHigh,'String',num2str(2^handles.settings.bitdepth));
uiTextDisplayHigh_Callback(handles.uiTextDisplayHigh, eventdata, handles);
handles = guidata(hObject); % get back gui data set in line above
if ~get(handles.uiButtonPreview,'Value')
    oldFrame = double(get(handles.retinaImg, 'CData'));
    oldFrameRaw = (oldFrame/oldScale)+oldOffset;
    oldFrameNewScale = uint8((oldFrameRaw - handles.displayOffset)*handles.displayScale);
    set(handles.retinaImg, 'CData', oldFrameNewScale);
    drawnow;
end


%% CREATE FUNCTIONS
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

