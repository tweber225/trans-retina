function varargout = multicolor_imaging_GUI(varargin)
% MULTICOLOR_IMAGING_GUI MATLAB code for multicolor_imaging_GUI.fig
%      MULTICOLOR_IMAGING_GUI, by itself, creates a new MULTICOLOR_IMAGING_GUI or raisest the existing
%      singleton*.
%
%      H = MULTICOLOR_IMAGING_GUI returns the handle to a new MULTICOLOR_IMAGING_GUI or the handle to
%      the existing singleton*.
%
%      MULTICOLOR_IMAGING_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MULTICOLOR_IMAGING_GUI.M with the given input arguments.
%
%      MULTICOLOR_IMAGING_GUI('Property','Value',...) creates a new MULTICOLOR_IMAGING_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before multicolor_imaging_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to multicolor_imaging_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help multicolor_imaging_GUI

% Last Modified by GUIDE v2.5 08-Aug-2017 11:48:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @multicolor_imaging_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @multicolor_imaging_GUI_OutputFcn, ...
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


% --- Executes just before multicolor_imaging_GUI is made visible.
function multicolor_imaging_GUI_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for multicolor_imaging_GUI
handles.output = hObject;

% Update handles structure- not sure why this is needed here? won't hurt
guidata(hObject, handles);

% START TDW EDIT
% Load the default program settings
handles.settingsStruct = load_default_program_settings; % This script defines all the variables in the master settings structure "settingsStruct"
handles.inputExpNumbers = '-'; % Next few lines, to track numpad/keypad key strokes
handles.capInputExpNumbers = '-';
handles.enteringFilename = 0;
handles.filenameChars = '';
handles.shiftHit = 0; % tracks whether the shift key has been hit
handles.requestCapture = 0; % tracks whether preview has been interrupted and a capture is requested

% Make digital channels to send enable signal to Arduino with correct
% configuration of LEDs
handles.prevLEDsToEnable = [handles.settingsStruct.prevLEDsEnable1 handles.settingsStruct.prevLEDsEnable2 handles.settingsStruct.prevLEDsEnable3 handles.settingsStruct.prevLEDsEnable4];
handles.capLEDsToEnable = [handles.settingsStruct.capLEDsEnable1 handles.settingsStruct.capLEDsEnable2 handles.settingsStruct.capLEDsEnable3 handles.settingsStruct.capLEDsEnable4];
handles.LEDsToEnable = [handles.settingsStruct.selectLEDsEnable1 handles.settingsStruct.selectLEDsEnable2 handles.settingsStruct.selectLEDsEnable3 handles.settingsStruct.selectLEDsEnable4];
disp('Starting DAQ System')
handles.NIDaqSession = daq.createSession('ni');
addDigitalChannel(handles.NIDaqSession,'dev1','Port0/Line0:5','OutputOnly');
% Make sure the port is set to low so we can trigger the Aruindo later
handles.digitalOutputScan = [0 handles.LEDsToEnable handles.settingsStruct.fixationTarget];
outputSingleScan(handles.NIDaqSession,handles.digitalOutputScan);

% Open the camera adapters
disp('Starting Camera')
handles.vidObj = videoinput('pcocameraadaptor', 0); % vid input object
handles.srcObj = getselectedsource(handles.vidObj); % adapter source

%Set logging to memory
handles.vidObj.LoggingMode = 'memory';

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


% END TDW EDIT


% UNNEEDED --- Outputs from this function are returned to the command line.
function varargout = multicolor_imaging_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% The following will change the Capture exposure time in settingsStruct
function capExpTime_Callback(hObject, eventdata, handles)
newExpTime = str2double(get(handles.capExpTime,'String'));
% Update this in the settings structure
handles.settingsStruct.capExpTime = newExpTime;
handles = estimate_capture_time_data(handles);
disp(['Capture exposure time set to ' num2str(newExpTime) ' ms']);
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function capExpTime_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in capBinSize.
function capBinSize_Callback(hObject, eventdata, handles)
handles.settingsStruct.capBinSize = get(handles.capBinSize,'Value');
switch handles.settingsStruct.capBinSize
    case 1
        handles.settingsStruct.deriveCapNumPixPerDim = handles.settingsStruct.constNumPixHeight;
        dispSize = '1x1';
    case 2
        handles.settingsStruct.deriveCapNumPixPerDim = handles.settingsStruct.constNumPixHeight/2;
        dispSize = '2x2';
    case 3
        handles.settingsStruct.deriveCapNumPixPerDim = handles.settingsStruct.constNumPixHeight/4;
        dispSize = '4x4';
end
handles = estimate_capture_time_data(handles);
guidata(hObject, handles);
disp(['Capture bin size set to ' dispSize ]);


% --- Executes during object creation, after setting all properties.
function capBinSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to capBinSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in capGain.
function capGain_Callback(hObject, eventdata, handles)
handles.settingsStruct.capGain = get(handles.capGain,'Value');
switch handles.settingsStruct.capGain
    case 1
        dispGain = '1.00 ADU/e-';
    case 2
        dispGain = '0.67 ADU/e-';
end
guidata(hObject, handles);
disp(['Capture gain set to ' dispGain]);

% --- Executes during object creation, after setting all properties.
function capGain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to capGain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% The following will change the Preview exposure time in settingsStruct
function prevExpTime_Callback(hObject, eventdata, handles)
newExpTime = str2double(get(handles.prevExpTime,'String'));
% Update this in the settings structure
handles.settingsStruct.prevExpTime = newExpTime;
% Also update camera source object with new exposure time. Do this because
% it will automatically update the exposure time, so it can be changed
% mid-preview.
handles.srcObj.E2ExposureTime = newExpTime;
disp(['Preview exposure time set to ' num2str(newExpTime) ' ms']);
% also if the capture lock settings is on, change the capture mode setting
if handles.settingsStruct.capLockSettings== 1
    handles.settingsStruct.capExpTime = newExpTime;
    set(handles.capExpTime,'String',num2str(newExpTime));
    handles = estimate_capture_time_data(handles);
    disp(['Capture exposure time set to ' num2str(newExpTime) ' ms']);
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function prevExpTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to prevExpTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in prevBinSize.
function prevBinSize_Callback(hObject, eventdata, handles)
handles.settingsStruct.prevBinSize = get(handles.prevBinSize,'Value');
switch handles.settingsStruct.prevBinSize
    case 1
        handles.settingsStruct.derivePrevNumPixPerDim = handles.settingsStruct.constNumPixHeight;
        dispSize = '1x1';
    case 2
        handles.settingsStruct.derivePrevNumPixPerDim = handles.settingsStruct.constNumPixHeight/2;
        dispSize = '2x2';
    case 3
        handles.settingsStruct.derivePrevNumPixPerDim = handles.settingsStruct.constNumPixHeight/4;
        dispSize = '4x4';
end
disp(['Preview bin size set to ' dispSize ]);
% also if the capture lock settings is on, change the capture mode setting
if handles.settingsStruct.capLockSettings == 1
    handles.settingsStruct.capBinSize = handles.settingsStruct.prevBinSize;
    set(handles.capBinSize,'Value',handles.settingsStruct.capBinSize);
    handles.settingsStruct.deriveCapNumPixPerDim = handles.settingsStruct.derivePrevNumPixPerDim;
    handles = estimate_capture_time_data(handles);
    disp(['Capture bin size set to ' dispSize ]);
end
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function prevBinSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to prevBinSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in prevGain.
function prevGain_Callback(hObject, eventdata, handles)
handles.settingsStruct.prevGain = get(handles.prevGain,'Value');
switch handles.settingsStruct.prevGain
    case 1
        dispGain = '1.00 ADU/e-';
    case 2
        dispGain = '0.67 ADU/e-';
end
disp(['Preview gain set to ' dispGain]);
% also if the capture lock settings is on, change the capture mode setting
if handles.settingsStruct.capLockSettings== 1
    handles.settingsStruct.capGain = handles.settingsStruct.prevGain;
    set(handles.capGain,'Value',handles.settingsStruct.capGain);
    disp(['Capture gain set to ' dispGain]);
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function prevGain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to prevGain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function commXShift_Callback(hObject, eventdata, handles)
newXShift = round(str2double(get(handles.commXShift,'String')));
% Bound this new shift value so we don't reach outside of the returned
% image resolution
switch handles.settingsStruct.numPixPerDim
    case 1040
        maxShift = 352;
    case 520
        maxShift = 176;
    case 260
        maxShift = 88;
end
if newXShift < 0
    newXShift = 0; 
elseif newXShift > maxShift
    newXShift = maxShift; 
end

% Update this in the settings structure and edit on GUI if out of bounds
handles.settingsStruct.commXShift = newXShift;
set(handles.commXShift,'String',num2str(newXShift));
guidata(hObject, handles);
disp(['Horizontal ROI shift set to ' num2str(handles.settingsStruct.commXShift) ' pixels']);

% --- Executes during object creation, after setting all properties.
function commXShift_CreateFcn(hObject, eventdata, handles)
% hObject    handle to commXShift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% !!! Starts CAPTURE Button 
% --- Executes on button press in capStartButton.
function capStartButton_Callback(hObject, eventdata, handles)
if get(handles.capStartButton,'Value') == 1
    
    % If we're not in preview mode, then carry out the core capture mode
    % code, otherwise set preview button to zero
    if get(handles.prevStartButton,'Value') == 0
        
        % Set some tracker to indicate we're in capture mode now
        handles.settingsStruct.inCapMode = 1;
        % Get LEDs to use for capture mode, switch axes view modes
        if handles.prevLEDsToEnable(1) ~= handles.capLEDsToEnable(1)
            % Force capture state for this button to capture state
            set(handles.selectLEDsEnable1,'Value',handles.capLEDsToEnable(1));
            % Run callback for this LED's button
            selectLEDsEnable1_Callback(hObject, eventdata, handles)
            handles = guidata(hObject);
        end
        if handles.prevLEDsToEnable(2) ~= handles.capLEDsToEnable(2)
            % Force capture state for this button to capture state
            set(handles.selectLEDsEnable2,'Value',handles.capLEDsToEnable(2));
            % Run callback for this LED's button
            selectLEDsEnable2_Callback(hObject, eventdata, handles)
            handles = guidata(hObject);
        end
        if handles.prevLEDsToEnable(3) ~= handles.capLEDsToEnable(3)
            % Force capture state for this button to capture state
            set(handles.selectLEDsEnable3,'Value',handles.capLEDsToEnable(3));
            % Run callback for this LED's button
            selectLEDsEnable3_Callback(hObject, eventdata, handles)
            handles = guidata(hObject);
        end
        if handles.prevLEDsToEnable(4) ~= handles.capLEDsToEnable(4)
            % Force capture state for this button to capture state
            set(handles.selectLEDsEnable4,'Value',handles.capLEDsToEnable(4));
            % Run callback for this LED's button
            selectLEDsEnable4_Callback(hObject, eventdata, handles)
            handles = guidata(hObject);
        end
        % Force back state of all 4 buttons to preview mode
        set(handles.selectLEDsEnable4,'Value',handles.prevLEDsToEnable(4));
        set(handles.selectLEDsEnable3,'Value',handles.prevLEDsToEnable(3));
        set(handles.selectLEDsEnable2,'Value',handles.prevLEDsToEnable(2));
        set(handles.selectLEDsEnable1,'Value',handles.prevLEDsToEnable(1));


        % Output TTL HIGH to Arduino to signal the start of an acquisition and
        % arm the arduino's toggling
        handles.digitalOutputScan = [1 handles.LEDsToEnable handles.settingsStruct.fixationTarget];
        outputSingleScan(handles.NIDaqSession,handles.digitalOutputScan);
        numLEDsEnabled = sum(handles.LEDsToEnable,2);

        disp('Starting Capture')      
        handles.settingsStruct.saveCapStartTime = datetime('now');

        % Check whether the current image data displayed on GUI matches the
        % desired capture resolutionn (numPixPerDim is always the currently
        % displayed image dimension, while the others are for desired
        % dimensions, which may or may not be active now)
        if handles.settingsStruct.numPixPerDim ~= handles.settingsStruct.deriveCapNumPixPerDim
            handles = reset_GUI_displays_update_resolution(handles,handles.settingsStruct.deriveCapNumPixPerDim);
        end

        % Set up space for the image files & frame times
        captureFrames = zeros([handles.settingsStruct.numPixPerDim,handles.settingsStruct.numPixPerDim,1,numLEDsEnabled,handles.settingsStruct.capNumFrames],'uint16');
        timesList = zeros([numLEDsEnabled,handles.settingsStruct.capNumFrames]);

        % Set up camera for preview with the latest settings
        handles = set_preview_or_capture_settings(handles,'capture');

        % Var allocation before the loop begins
        timeDataLastPair = 0; % for frame sets per second (FSPS) calculation
        numLEDsEnabled = sum(handles.LEDsToEnable,2);
        numPixsInMask = sum(handles.imageMask(:));
        maskedCroppedFrames = zeros(numPixsInMask,numLEDsEnabled);
        repMask = repmat(handles.imageMask,[1 1 1 numLEDsEnabled]);


        guidata(hObject,handles);

        setIdx = 1; % Counter to track number of frames and stop the loop when done

        start(handles.vidObj);

        while ((setIdx-1) < handles.settingsStruct.capNumFrames) && (get(handles.capStartButton,'Value') == 1) % While we haven't acquire all the frames yet AND the toggle button is still DOWN
            % Don't get new GUI info here (as opposed to as is done in Preview)
            % because Capture Mode isn't supposed to be changed on the fly

            % Get number of frames that are available now, check below whether
            % there are too many frames (not keeping up!) or just the right
            % number of frames (gather the data and show+analyze)
            numFramesAvailNow = handles.vidObj.FramesAvailable;

            if numFramesAvailNow > numLEDsEnabled % Warn if not keeping up with frame rate
                disp('WARNING: Program is struggling to keep up with frame rate.')
                set(handles.capStartButton,'String','(!)Abort');
                handles.settingsStruct.capWarningFlag = 1; % Log this warning in the metadata/settings
            end

            if numFramesAvailNow >= numLEDsEnabled % when N frames are available put them up on the GUI displays
                [currentFrameSet,timeDataNow] = getdata(handles.vidObj,numLEDsEnabled);

                % Crop to square (shifted in x) and place in big recording
                % matrix, also save time data for frames
                captureFrames(:,:,1,:,setIdx) = currentFrameSet(:,(1+handles.settingsStruct.commXShift):(handles.settingsStruct.numPixPerDim+handles.settingsStruct.commXShift),1,:);
                timesList(:,setIdx) = timeDataNow(:);

                % Show image data - dependent on whether "quad-channel view"
                % (quadview) is on
                if handles.settingsStruct.selectLEDsQuadViewOn == 1 % if quad mode is ON
                    % Show all the individual images in smaller "thumbnails",
                    % and determine which frame in buffer belongs in each image
                    % spot on GUI
                    frameIdx = 1;
                    bigFrameToShow = -1;
                    bigFrameRequest = get(handles.selectLEDsShow,'Value');
                    if handles.settingsStruct.selectLEDsEnable1 == 1
                        set(handles.imgHandLEDQuad1, 'CData', captureFrames(:,:,1,frameIdx,setIdx));
                        if bigFrameRequest == 1;
                            bigFrameToShow = frameIdx;
                        end
                        frameIdx = frameIdx+1;
                    end
                    if handles.settingsStruct.selectLEDsEnable2 == 1
                        set(handles.imgHandLEDQuad2, 'CData', captureFrames(:,:,1,frameIdx,setIdx));
                        if bigFrameRequest == 2;
                            bigFrameToShow = frameIdx;
                        end
                        frameIdx = frameIdx+1;
                    end
                    if handles.settingsStruct.selectLEDsEnable3 == 1
                        set(handles.imgHandLEDQuad3, 'CData', captureFrames(:,:,1,frameIdx,setIdx));
                        if bigFrameRequest == 3;
                            bigFrameToShow = frameIdx;
                        end
                        frameIdx = frameIdx+1;
                    end
                    if handles.settingsStruct.selectLEDsEnable4 == 1
                        set(handles.imgHandLEDQuad4, 'CData', captureFrames(:,:,1,frameIdx,setIdx));
                        if bigFrameRequest == 4;
                            bigFrameToShow = frameIdx;
                        end
                    end

                    % Show one of these (specified in select LEDs panel) in
                    % large LED1Ax frame
                    set(handles.imgHandLED1, 'CData', captureFrames(:,:,1,bigFrameToShow,setIdx));

                else % if not in quad mode, we can just put the frames into each standard axis
                    if numLEDsEnabled == 1
                        set(handles.imgHandLED1, 'CData', captureFrames(:,:,1,1,setIdx));
                    else
                        set(handles.imgHandLED1, 'CData', captureFrames(:,:,1,1,setIdx));
                        set(handles.imgHandLED2, 'CData', captureFrames(:,:,1,2,setIdx));
                    end
                end

                % Mask current image set if doing any RT Stats or Hist
                if handles.settingsStruct.commRTHistogram || handles.settingsStruct.commRTStats
                    % Do computations on the masked images only
                    intermediateCroppedFrames = captureFrames(:,:,1,:,setIdx).*repMask;
                    maskedCroppedFrames = reshape(intermediateCroppedFrames(intermediateCroppedFrames>0),[numPixsInMask,numLEDsEnabled]);
                end

                % If requested, compute histogram
                if handles.settingsStruct.commRTHistogram == 1
                    if handles.settingsStruct.selectLEDsQuadViewOn == 0 % for regular (non-quad) view
                        handles.histHandLED1.Data = maskedCroppedFrames(:,1);
                        if numLEDsEnabled>1
                            handles.histHandLED2.Data = maskedCroppedFrames(:,2);
                        end
                    else % different handling, if IN quad mode:
                        quadIdx = 1;
                        if handles.settingsStruct.selectLEDsEnable1 == 1
                            handles.histHandLEDQuad1.Data = maskedCroppedFrames(:,quadIdx);
                            quadIdx = quadIdx + 1;
                        end
                        if handles.settingsStruct.selectLEDsEnable2 == 1
                            handles.histHandLEDQuad2.Data = maskedCroppedFrames(:,quadIdx);
                            quadIdx = quadIdx + 1;
                        end
                        if handles.settingsStruct.selectLEDsEnable3 == 1
                            handles.histHandLEDQuad3.Data = maskedCroppedFrames(:,quadIdx);
                            quadIdx = quadIdx + 1;
                        end
                        if handles.settingsStruct.selectLEDsEnable4 == 1
                            handles.histHandLEDQuad4.Data = maskedCroppedFrames(:,quadIdx);
                        end
                    end
                end

                % If requested, compute statistics
                if handles.settingsStruct.commRTStats == 1
                    if handles.settingsStruct.selectLEDsQuadViewOn == 0 % if quad-view not enabled...
                        set(handles.LED1MaxIndicator,'String',['Max: ' num2str(max(maskedCroppedFrames(:,1)))]);
                        set(handles.LED1MinIndicator,'String',['Min: ' num2str(min(maskedCroppedFrames(:,1)))]);
                        set(handles.LED1MeanIndicator,'String',['Mean: ' num2str(mean(maskedCroppedFrames(:,1)),4)]);
                        set(handles.LED1MedianIndicator,'String',['Median: ' num2str(median(maskedCroppedFrames(:,1)),4)]);
                        percentSat = 100*sum(maskedCroppedFrames(:,1) == (2^handles.settingsStruct.constCameraBits-1))/numel(maskedCroppedFrames(:,1));
                        set(handles.LED1PercentSaturatedIndicator,'String',['% Saturated: ' num2str(percentSat,3) '%']);
                        if numLEDsEnabled > 1
                            set(handles.LED2MaxIndicator,'String',['Max: ' num2str(max(maskedCroppedFrames(:,2)))]);
                            set(handles.LED2MinIndicator,'String',['Min: ' num2str(min(maskedCroppedFrames(:,2)))]);
                            set(handles.LED2MeanIndicator,'String',['Mean: ' num2str(mean(maskedCroppedFrames(:,2)),4)]);
                            set(handles.LED2MedianIndicator,'String',['Median: ' num2str(median(maskedCroppedFrames(:,2)),4)]);
                            percentSat = 100*sum(maskedCroppedFrames(:,2) == (2^handles.settingsStruct.constCameraBits-1))/numel(maskedCroppedFrames(:,2));
                            set(handles.LED2PercentSaturatedIndicator,'String',['% Saturated: ' num2str(percentSat,3) '%']);
                        end
                    else % otherwise we are in quad view, and there's slightly different information to show
                        quadIdx = 1;
                        if handles.settingsStruct.selectLEDsEnable1 == 1
                            percentSat = 100*sum(maskedCroppedFrames(:,quadIdx) == (2^handles.settingsStruct.constCameraBits-1))/numel(maskedCroppedFrames(:,quadIdx));
                            dispStr = [handles.settingsStruct.constLED1CenterWavelength ': Min: ' num2str(min(maskedCroppedFrames(:,quadIdx))) ', Max: ' num2str(max(maskedCroppedFrames(:,quadIdx))) ', Mean: ' num2str(mean(maskedCroppedFrames(:,quadIdx)),5) ', Sat: ' num2str(percentSat,3) '%'];
                            set(handles.LEDQuad1StatsIndicator,'String',dispStr);
                            quadIdx = quadIdx + 1;
                        end
                        if handles.settingsStruct.selectLEDsEnable2 == 1
                            percentSat = 100*sum(maskedCroppedFrames(:,quadIdx) == (2^handles.settingsStruct.constCameraBits-1))/numel(maskedCroppedFrames(:,quadIdx));
                            dispStr = [handles.settingsStruct.constLED2CenterWavelength ': Min: ' num2str(min(maskedCroppedFrames(:,quadIdx))) ', Max: ' num2str(max(maskedCroppedFrames(:,quadIdx))) ', Mean: ' num2str(mean(maskedCroppedFrames(:,quadIdx)),5) ', Sat: ' num2str(percentSat,3) '%'];
                            set(handles.LEDQuad2StatsIndicator,'String',dispStr);
                            quadIdx = quadIdx + 1;
                        end
                        if handles.settingsStruct.selectLEDsEnable3 == 1
                            percentSat = 100*sum(maskedCroppedFrames(:,quadIdx) == (2^handles.settingsStruct.constCameraBits-1))/numel(maskedCroppedFrames(:,quadIdx));
                            dispStr = [handles.settingsStruct.constLED3CenterWavelength ': Min: ' num2str(min(maskedCroppedFrames(:,quadIdx))) ', Max: ' num2str(max(maskedCroppedFrames(:,quadIdx))) ', Mean: ' num2str(mean(maskedCroppedFrames(:,quadIdx)),5) ', Sat: ' num2str(percentSat,3) '%'];
                            set(handles.LEDQuad3StatsIndicator,'String',dispStr);
                            quadIdx = quadIdx + 1;
                        end
                        if handles.settingsStruct.selectLEDsEnable4 == 1
                            percentSat = 100*sum(maskedCroppedFrames(:,quadIdx) == (2^handles.settingsStruct.constCameraBits-1))/numel(maskedCroppedFrames(:,quadIdx));
                            dispStr = [handles.settingsStruct.constLED4CenterWavelength ': Min: ' num2str(min(maskedCroppedFrames(:,quadIdx))) ', Max: ' num2str(max(maskedCroppedFrames(:,quadIdx))) ', Mean: ' num2str(mean(maskedCroppedFrames(:,quadIdx)),5) ', Sat: ' num2str(percentSat,3) '%'];
                            set(handles.LEDQuad4StatsIndicator,'String',dispStr);
                        end
                    end
                end

                % Update Frame Sets Per Second Indicator
                set(handles.capFPSIndicator,'String',[num2str(1/(timeDataNow(1)-timeDataLastPair),4) ' fsps']); % calculate FPS

                drawnow; % Must drawnow to show new frame data
                timeDataLastPair = timeDataNow(1); % Record this set's time for next FSPS calculation

                % update the start capture button with progress and any warning
                if handles.settingsStruct.capWarningFlag == 1
                    progStr = ['(!)Abort ' num2str(setIdx) '/' num2str(handles.settingsStruct.capNumFrames)];
                else
                    progStr = ['Abort ' num2str(setIdx) '/' num2str(handles.settingsStruct.capNumFrames)];
                end
                set(handles.capStartButton,'String',progStr);

                % increment the set counter
                setIdx=setIdx+1; 
            end
        end

        stop(handles.vidObj)
        handles = re_enable_preview_or_capture_settings(handles,'capture');
        disp('Capture ended')

        % Start the saving procedure
        disp('Saving...')
        set(handles.capStartButton,'String','Saving...');drawnow;

        % First check whether a folder exists to save in
        dateDir = ['data' filesep datestr(now,'yymmdd')];
        if ~exist(dateDir,'dir')
            mkdir(dateDir);
        end

        fileName = [datestr(now,'yymmdd') '_' handles.settingsStruct.saveBaseName '_capture' sprintf('%.3d',handles.settingsStruct.saveCapNum)];
        dateAndCapDir = [dateDir filesep fileName];
        while exist(dateAndCapDir,'dir') % WHILE Loop to make sure that you've selected something that won't overwrite before saving this data
            disp('WARNING: POTENTIAL OVERWRITE DETECTED');
            % prompt user to make a new subject name
            prompt = {'Enter new subject name:'};
            dlg_title = 'Overwrite detection';
            num_lines = 1;
            defaultans = {'subject00'};
            newSaveBaseName = inputdlg(prompt,dlg_title,num_lines,defaultans);
            % update the appropriate settings and input boxes
            set(handles.saveBaseName,'String',newSaveBaseName{1});
            handles.settingsStruct.saveBaseName = newSaveBaseName{1};
            saveBaseName_Callback(hObject, eventdata, handles);
            % Make the new save directory
            fileName = [datestr(now,'yymmdd') '_' handles.settingsStruct.saveBaseName '_capture' sprintf('%.3d',handles.settingsStruct.saveCapNum)];
            dateAndCapDir = [dateDir filesep fileName];
        end
        mkdir(dateAndCapDir);

        % Save data in tiff stacks (one for each LED channel)
        LEDOptions = {handles.settingsStruct.constLED1CenterWavelength,handles.settingsStruct.constLED2CenterWavelength,handles.settingsStruct.constLED3CenterWavelength,handles.settingsStruct.constLED4CenterWavelength};
        LEDsEnabled = LEDOptions(logical(handles.LEDsToEnable));

        saveastiff(reshape(captureFrames(:,:,1,1,:),[handles.settingsStruct.numPixPerDim,handles.settingsStruct.numPixPerDim,handles.settingsStruct.capNumFrames]),[dateAndCapDir filesep fileName '_' LEDsEnabled{1} '.tiff']);
        if numLEDsEnabled > 1
            saveastiff(reshape(captureFrames(:,:,1,2,:),[handles.settingsStruct.numPixPerDim,handles.settingsStruct.numPixPerDim,handles.settingsStruct.capNumFrames]),[dateAndCapDir filesep fileName '_' LEDsEnabled{2} '.tiff']);
        end
        if numLEDsEnabled > 2
            saveastiff(reshape(captureFrames(:,:,1,3,:),[handles.settingsStruct.numPixPerDim,handles.settingsStruct.numPixPerDim,handles.settingsStruct.capNumFrames]),[dateAndCapDir filesep fileName '_' LEDsEnabled{3} '.tiff']);
        end
        if numLEDsEnabled > 3
            saveastiff(reshape(captureFrames(:,:,1,4,:),[handles.settingsStruct.numPixPerDim,handles.settingsStruct.numPixPerDim,handles.settingsStruct.capNumFrames]),[dateAndCapDir filesep fileName '_' LEDsEnabled{4} '.tiff']);
        end
        disp(['Finished Saving Data (' handles.settingsStruct.saveBaseName '_capture' num2str(handles.settingsStruct.saveCapNum) ')'])

        % If the save settings check box is active, then export the
        % settingsStruct to a csv table
        if handles.settingsStruct.saveSettings
            tempTable = struct2table(handles.settingsStruct);
            writetable(tempTable,[dateAndCapDir filesep fileName '_settings.csv']);
        end

        % If the save frame times check box is active, then save the times in a
        % csv file
        if handles.settingsStruct.saveFrameTimes
            tempTable = array2table(timesList);
            writetable(tempTable,[dateAndCapDir filesep fileName '_frameTimes.csv']);
        end

        % Update capture number
        handles.settingsStruct.saveCapNum = handles.settingsStruct.saveCapNum + 1;

        % Send TTL low signal to Arduino to signal the acquisition has finished
        % so it can reset its toggle
        handles.digitalOutputScan = [0 handles.LEDsToEnable handles.settingsStruct.fixationTarget];
        outputSingleScan(handles.NIDaqSession,handles.digitalOutputScan);

        % Reset warning flag, aborted, and requested capture flags
        handles.settingStruct.capWarningFlag = 0;
        handles.settingStruct.capAborted = 0;
        handles.requestCapture = 0;

        % And finally reset the Capture Start button
        set(handles.capStartButton,'String','Start Capture');
        handles.settingsStruct.justFinishedCap = 1;
        handles.settingsStruct.inCapMode = 0;
 
    else
        % Initiate preview mode termination by turning off its start button
        % and set a flag to initiate capture when done
        set(handles.prevStartButton,'Value',0)
        handles.requestCapture = 1;
    end
    guidata(hObject, handles);
else
    disp('Aborting Capture!')
    % Flag this dataset as aborted
    handles.settingsStruct.capAborted = 1;
    % Reset button--not sure whether this is necessary
    set(handles.capStartButton,'String','Start Capture');
    guidata(hObject, handles);
end


% !!! Starts PREVIEW Button 
% --- Executes on button press in prevStartButton.
function prevStartButton_Callback(hObject, eventdata, handles)
if get(handles.prevStartButton,'Value') == 1
    % Insure the right LEDs are selected for this preview (i.e. if we
    % just finished a capture with different LED channels selected, then
    % change the image axes displayed)
    if handles.settingsStruct.justFinishedCap == 1
        handles.settingsStruct.justFinishedCap = 0; % turn off this flag here or else it will affect callback fcns below
        if handles.prevLEDsToEnable(1) ~= handles.capLEDsToEnable(1)
            % Force capture state for this button to capture state
            set(handles.selectLEDsEnable1,'Value',handles.prevLEDsToEnable(1));
            % Run callback for this LED's button
            selectLEDsEnable1_Callback(hObject, eventdata, handles)
            handles = guidata(hObject);
        end
        if handles.prevLEDsToEnable(2) ~= handles.capLEDsToEnable(2)
            % Force capture state for this button to capture state
            set(handles.selectLEDsEnable2,'Value',handles.prevLEDsToEnable(2));
            % Run callback for this LED's button
            selectLEDsEnable2_Callback(hObject, eventdata, handles)
            handles = guidata(hObject);
        end
        if handles.prevLEDsToEnable(3) ~= handles.capLEDsToEnable(3)
            % Force capture state for this button to capture state
            set(handles.selectLEDsEnable3,'Value',handles.prevLEDsToEnable(3));
            % Run callback for this LED's button
            selectLEDsEnable3_Callback(hObject, eventdata, handles)
            handles = guidata(hObject);
        end
        if handles.prevLEDsToEnable(4) ~= handles.capLEDsToEnable(4)
            % Force capture state for this button to capture state
            set(handles.selectLEDsEnable4,'Value',handles.prevLEDsToEnable(4));
            % Run callback for this LED's button
            selectLEDsEnable4_Callback(hObject, eventdata, handles)
            handles = guidata(hObject);
        end
    end
       
    % Output TTL HIGH to Arduino to signal the start of an acquisition and
    % indicate active LEDs
    handles.digitalOutputScan = [1 handles.LEDsToEnable handles.settingsStruct.fixationTarget];
    outputSingleScan(handles.NIDaqSession,handles.digitalOutputScan);
    
    disp('Starting Preview')      
    % Check whether the current image data displayed on GUI matches the
    % desired capture resolutionn (numPixPerDim is always the currently
    % displayed image dimension, while the others are for desired
    % dimensions, which may or may not be active now)
    if handles.settingsStruct.numPixPerDim ~= handles.settingsStruct.derivePrevNumPixPerDim
        handles = reset_GUI_displays_update_resolution(handles,handles.settingsStruct.derivePrevNumPixPerDim);
    end
    
    % Make a filter kernel for potential real-time image flattening (for
    % focus finding especially)
    kernelWidth = handles.settingsStruct.derivePrevNumPixPerDim*handles.settingsStruct.analysisFilterKernelWidth;
    filterKernel = fspecial('gaussian',round(kernelWidth.*[1 1]),.5*kernelWidth);
        
    % Set up camera for preview with the latest settings &gray out settings
    % that should not be changed
    handles = set_preview_or_capture_settings(handles,'preview');
    
    % Var allocation before the loop begins
    timeDataLastPair = 0; % for frame sets per second (FSPS) calculation
    numLEDsEnabled = sum(handles.LEDsToEnable,2);
    numPixsInMask = sum(handles.imageMask(:));
    maskedCroppedFrames = zeros(numPixsInMask,numLEDsEnabled);
    repMask = repmat(handles.imageMask,[1 1 1 numLEDsEnabled]);
    
    start(handles.vidObj);
    
    guidata(hObject,handles);
     
    while (get(handles.prevStartButton,'Value') == 1) % While the toggle button is DOWN
        % Get current GUI UI data (for update-able properties)
        handles = guidata(hObject);
        
        % Get number of frames that are available now, check below whether
        % there are too many frames (not keeping up!) or just the right
        % number of frames (gather the data and show+analyze)
        numFramesAvailNow = handles.vidObj.FramesAvailable;        
        
        if numFramesAvailNow > numLEDsEnabled 
            %If there are more frames available than LED channels enabled,
            %then the program is not keeping up. Try to take up slack by
            %gathering a number of frames and not doing anything with them
            getdata(handles.vidObj,numLEDsEnabled);
            disp('WARNING: DETECTED DROPPED FRAMES')
            set(handles.prevStartButton,'String','Dropped Fr.');
        end
        
        if numFramesAvailNow == numLEDsEnabled % when the number of frames requested are available, gather data and show them
            [currentFrameSet,timeDataNow] = getdata(handles.vidObj,numLEDsEnabled);

            % Gather data and crop to square (shifted in x)
            croppedFrames = currentFrameSet(:,(1+handles.settingsStruct.commXShift):(handles.settingsStruct.numPixPerDim+handles.settingsStruct.commXShift),1,:);
            
            % Show image data - dependent on whether "quad-channel view"
            % (quadview) is on
            if handles.settingsStruct.selectLEDsQuadViewOn == 1 % if quad mode is ON
                % Show all the individual images in smaller "thumbnails",
                % and determine which frame in buffer belongs in each image
                % spot on GUI
                frameIdx = 1;
                bigFrameToShow = -1;
                bigFrameRequest = get(handles.selectLEDsShow,'Value');
                if handles.settingsStruct.selectLEDsEnable1 == 1
                    set(handles.imgHandLEDQuad1, 'CData', croppedFrames(:,:,:,frameIdx));
                    if bigFrameRequest == 1;
                        bigFrameToShow = frameIdx;
                    end
                    frameIdx = frameIdx+1;
                end
                if handles.settingsStruct.selectLEDsEnable2 == 1
                    set(handles.imgHandLEDQuad2, 'CData', croppedFrames(:,:,:,frameIdx));
                    if bigFrameRequest == 2;
                        bigFrameToShow = frameIdx;
                    end
                    frameIdx = frameIdx+1;
                end
                if handles.settingsStruct.selectLEDsEnable3 == 1
                    set(handles.imgHandLEDQuad3, 'CData', croppedFrames(:,:,:,frameIdx));
                    if bigFrameRequest == 3;
                        bigFrameToShow = frameIdx;
                    end
                    frameIdx = frameIdx+1;
                end
                if handles.settingsStruct.selectLEDsEnable4 == 1
                    set(handles.imgHandLEDQuad4, 'CData', croppedFrames(:,:,:,frameIdx));
                    if bigFrameRequest == 4;
                        bigFrameToShow = frameIdx;
                    end
                end
                
                % Show one of these (specified in select LEDs panel) in
                % large LED1Ax frame
                if handles.settingsStruct.RTFlattening == 1
                    maxCamVal = 2^handles.settingsStruct.constCameraBits - 1;
                    set(handles.imgHandLED1, 'CData', uint16(realtime_image_flattening(double(croppedFrames(:,:,:,bigFrameToShow)),double(handles.imageMask),filterKernel,maxCamVal)));
                else
                    set(handles.imgHandLED1, 'CData', croppedFrames(:,:,:,bigFrameToShow));
                end
                
            else % if not in quad mode, we can just put the frames into each standard axis
                if numLEDsEnabled == 1
                    if handles.settingsStruct.RTFlattening == 1
                        maxCamVal = 2^handles.settingsStruct.constCameraBits - 1;
                        set(handles.imgHandLED1, 'CData', uint16(realtime_image_flattening(double(croppedFrames(:,:,:,1)),double(handles.imageMask),filterKernel,maxCamVal)));
                    else
                        set(handles.imgHandLED1, 'CData', croppedFrames(:,:,:,1));
                    end
                else
                    if handles.settingsStruct.RTFlattening == 1
                        maxCamVal = 2^handles.settingsStruct.constCameraBits - 1;
                        set(handles.imgHandLED1, 'CData', uint16(realtime_image_flattening(double(croppedFrames(:,:,:,1)),double(handles.imageMask),filterKernel,maxCamVal)));
                    else
                        set(handles.imgHandLED1, 'CData', croppedFrames(:,:,:,1));
                    end
                    set(handles.imgHandLED2, 'CData', croppedFrames(:,:,:,2));
                end
            end
            
            % Mask image if doing any RT Stats or Hist
            if handles.settingsStruct.commRTHistogram || handles.settingsStruct.commRTStats
                % Do computations on the masked images only
                intermediateCroppedFrames = croppedFrames.*repMask;
                maskedCroppedFrames = reshape(intermediateCroppedFrames(intermediateCroppedFrames>0),[numPixsInMask,numLEDsEnabled]);
            end
            
            % If requested, compute histogram
            if handles.settingsStruct.commRTHistogram == 1
                if handles.settingsStruct.selectLEDsQuadViewOn == 0 % for regular (non-quad) view
                    handles.histHandLED1.Data = maskedCroppedFrames(:,1);
                    if numLEDsEnabled>1
                        handles.histHandLED2.Data = maskedCroppedFrames(:,2);
                    end
                else % different handling, if IN quad mode:
                    quadIdx = 1;
                    if handles.settingsStruct.selectLEDsEnable1 == 1
                        handles.histHandLEDQuad1.Data = maskedCroppedFrames(:,quadIdx);
                        quadIdx = quadIdx + 1;
                    end
                    if handles.settingsStruct.selectLEDsEnable2 == 1
                        handles.histHandLEDQuad2.Data = maskedCroppedFrames(:,quadIdx);
                        quadIdx = quadIdx + 1;
                    end
                    if handles.settingsStruct.selectLEDsEnable3 == 1
                        handles.histHandLEDQuad3.Data = maskedCroppedFrames(:,quadIdx);
                        quadIdx = quadIdx + 1;
                    end
                    if handles.settingsStruct.selectLEDsEnable4 == 1
                        handles.histHandLEDQuad4.Data = maskedCroppedFrames(:,quadIdx);
                    end
                end
            end
            
            % If requested, compute statistics
            if handles.settingsStruct.commRTStats == 1
                if handles.settingsStruct.selectLEDsQuadViewOn == 0 % if quad-view not enabled...
                    set(handles.LED1MaxIndicator,'String',['Max: ' num2str(max(maskedCroppedFrames(:,1)))]);
                    set(handles.LED1MinIndicator,'String',['Min: ' num2str(min(maskedCroppedFrames(:,1)))]);
                    set(handles.LED1MeanIndicator,'String',['Mean: ' num2str(mean(maskedCroppedFrames(:,1)),4)]);
                    set(handles.LED1MedianIndicator,'String',['Median: ' num2str(median(maskedCroppedFrames(:,1)),4)]);
                    percentSat = 100*sum(maskedCroppedFrames(:,1) == (2^handles.settingsStruct.constCameraBits-1))/numel(maskedCroppedFrames(:,1));
                    set(handles.LED1PercentSaturatedIndicator,'String',['% Saturated: ' num2str(percentSat,3) '%']);
                    if numLEDsEnabled > 1
                        set(handles.LED2MaxIndicator,'String',['Max: ' num2str(max(maskedCroppedFrames(:,2)))]);
                        set(handles.LED2MinIndicator,'String',['Min: ' num2str(min(maskedCroppedFrames(:,2)))]);
                        set(handles.LED2MeanIndicator,'String',['Mean: ' num2str(mean(maskedCroppedFrames(:,2)),4)]);
                        set(handles.LED2MedianIndicator,'String',['Median: ' num2str(median(maskedCroppedFrames(:,2)),4)]);
                        percentSat = 100*sum(maskedCroppedFrames(:,2) == (2^handles.settingsStruct.constCameraBits-1))/numel(maskedCroppedFrames(:,2));
                        set(handles.LED2PercentSaturatedIndicator,'String',['% Saturated: ' num2str(percentSat,3) '%']);
                    end
                else % otherwise we are in quad view, and there's slightly different information to show
                    quadIdx = 1;
                    if handles.settingsStruct.selectLEDsEnable1 == 1
                        percentSat = 100*sum(maskedCroppedFrames(:,quadIdx) == (2^handles.settingsStruct.constCameraBits-1))/numel(maskedCroppedFrames(:,quadIdx));
                        dispStr = [handles.settingsStruct.constLED1CenterWavelength ': Min: ' num2str(min(maskedCroppedFrames(:,quadIdx))) ', Max: ' num2str(max(maskedCroppedFrames(:,quadIdx))) ', Mean: ' num2str(mean(maskedCroppedFrames(:,quadIdx)),5) ', Sat: ' num2str(percentSat,3) '%'];
                        set(handles.LEDQuad1StatsIndicator,'String',dispStr);
                        quadIdx = quadIdx + 1;
                    end
                    if handles.settingsStruct.selectLEDsEnable2 == 1
                        percentSat = 100*sum(maskedCroppedFrames(:,quadIdx) == (2^handles.settingsStruct.constCameraBits-1))/numel(maskedCroppedFrames(:,quadIdx));
                        dispStr = [handles.settingsStruct.constLED2CenterWavelength ': Min: ' num2str(min(maskedCroppedFrames(:,quadIdx))) ', Max: ' num2str(max(maskedCroppedFrames(:,quadIdx))) ', Mean: ' num2str(mean(maskedCroppedFrames(:,quadIdx)),5) ', Sat: ' num2str(percentSat,3) '%'];
                        set(handles.LEDQuad2StatsIndicator,'String',dispStr);
                        quadIdx = quadIdx + 1;
                    end
                    if handles.settingsStruct.selectLEDsEnable3 == 1
                        percentSat = 100*sum(maskedCroppedFrames(:,quadIdx) == (2^handles.settingsStruct.constCameraBits-1))/numel(maskedCroppedFrames(:,quadIdx));
                        dispStr = [handles.settingsStruct.constLED3CenterWavelength ': Min: ' num2str(min(maskedCroppedFrames(:,quadIdx))) ', Max: ' num2str(max(maskedCroppedFrames(:,quadIdx))) ', Mean: ' num2str(mean(maskedCroppedFrames(:,quadIdx)),5) ', Sat: ' num2str(percentSat,3) '%'];
                        set(handles.LEDQuad3StatsIndicator,'String',dispStr);
                        quadIdx = quadIdx + 1;
                    end
                    if handles.settingsStruct.selectLEDsEnable4 == 1
                        percentSat = 100*sum(maskedCroppedFrames(:,quadIdx) == (2^handles.settingsStruct.constCameraBits-1))/numel(maskedCroppedFrames(:,quadIdx));
                        dispStr = [handles.settingsStruct.constLED4CenterWavelength ': Min: ' num2str(min(maskedCroppedFrames(:,quadIdx))) ', Max: ' num2str(max(maskedCroppedFrames(:,quadIdx))) ', Mean: ' num2str(mean(maskedCroppedFrames(:,quadIdx)),5) ', Sat: ' num2str(percentSat,3) '%'];
                        set(handles.LEDQuad4StatsIndicator,'String',dispStr);
                    end
                end
            end
            
            % Update Frame Sets Per Second Indicator
            set(handles.prevFPSIndicator,'String',[num2str(1/(timeDataNow(1)-timeDataLastPair),4) ' fsps']); % calculate FPS
            
            drawnow; % Must drawnow to show new frame data
            timeDataLastPair = timeDataNow(1); % Record this set's time for next Frame Sets Per Second calculation
        end
    end
    
    handles = guidata(hObject); % get new handles data
    stop(handles.vidObj)
    handles = re_enable_preview_or_capture_settings(handles,'preview');
    
    % Send TTL LOW to Arduino to signal end of this acquisition event and
    % reset its LED toggle
    handles.digitalOutputScan = [1 handles.LEDsToEnable handles.settingsStruct.fixationTarget];
    outputSingleScan(handles.NIDaqSession, handles.digitalOutputScan);
    
    if handles.requestCapture == 1
        capStartButton_Callback(hObject, eventdata, handles) % calling GUI data is done at end of this callback anyway
    else
        guidata(hObject, handles);
    end
    
else
    disp('Ending Preview')
end


function capNumFrames_Callback(hObject, eventdata, handles)
handles.settingsStruct.capNumFrames = str2double(get(handles.capNumFrames,'String'));
handles = estimate_capture_time_data(handles);
guidata(hObject, handles);
disp(['Capture number of frame pairs set to ' num2str(handles.settingsStruct.capNumFrames)]);



% --- Executes during object creation, after setting all properties.
function capNumFrames_CreateFcn(hObject, eventdata, handles)
% hObject    handle to capNumFrames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function saveBaseName_Callback(hObject, eventdata, handles)
handles.settingsStruct.saveBaseName = get(handles.saveBaseName,'String');
disp(['Base filename set to: ' handles.settingsStruct.saveBaseName]);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function saveBaseName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to saveBaseName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in commIRMode.
function commIRMode_Callback(hObject, eventdata, handles)
handles.settingsStruct.commIRMode = get(handles.commIRMode,'Value');
switch handles.settingsStruct.commIRMode
    case 0
        dispIRMode = 'off';
    case 1
        dispIRMode = 'on';
end
guidata(hObject, handles);
disp(['IR-sensitive mode turned ' dispIRMode]);

% --- Executes on button press in commAutoScale.
function commAutoScale_Callback(hObject, eventdata, handles)
% Time is not really of the essence here, so we will just auto-scale every
% image axis, regardless of whether it's actively used

% Get image data from all frames
LED1Data = get(handles.imgHandLED1, 'CData');
LED2Data = get(handles.imgHandLED2, 'CData');
LEDQuad1Data = get(handles.imgHandLEDQuad1,'CData');
LEDQuad2Data = get(handles.imgHandLEDQuad2,'CData');
LEDQuad3Data = get(handles.imgHandLEDQuad3,'CData');
LEDQuad4Data = get(handles.imgHandLEDQuad4,'CData');

% Apply image mask to raw image data--to select the central region
maskedLED1Data = LED1Data.*handles.imageMask;
maskedLED2Data = LED2Data.*handles.imageMask;
maskedLEDQuad1Data = LEDQuad1Data.*handles.imageMask;
maskedLEDQuad2Data = LEDQuad2Data.*handles.imageMask;
maskedLEDQuad3Data = LEDQuad3Data.*handles.imageMask;
maskedLEDQuad4Data = LEDQuad4Data.*handles.imageMask;

% find min and max for each within central circular region
QVals = quantile(double(maskedLED1Data(maskedLED1Data>0)),[handles.settingsStruct.analysisAutoScaleLowQuantile,handles.settingsStruct.analysisAutoScaleHighQuantile]);
if QVals(1) == QVals(2) % if the quantiles are exactly the same, then there's probably no valid image data, and it's better to set this to default 0 to 2^(cam bits)
    QVals(1) = 0;
    QVals(2) = 2^(handles.settingsStruct.constCameraBits)-1;
end
handles.settingsStruct.blackLevelLED1 = QVals(1);
handles.settingsStruct.whiteLevelLED1 = QVals(2);
QVals = quantile(double(maskedLED2Data(maskedLED2Data>0)),[handles.settingsStruct.analysisAutoScaleLowQuantile,handles.settingsStruct.analysisAutoScaleHighQuantile]);
if QVals(1) == QVals(2)
    QVals(1) = 0;
    QVals(2) = 2^(handles.settingsStruct.constCameraBits)-1;
end
handles.settingsStruct.blackLevelLED2 = QVals(1);
handles.settingsStruct.whiteLevelLED2 = QVals(2);
QVals = quantile(double(maskedLEDQuad1Data(maskedLEDQuad1Data>0)),[handles.settingsStruct.analysisAutoScaleLowQuantile,handles.settingsStruct.analysisAutoScaleHighQuantile]);
if QVals(1) == QVals(2)
    QVals(1) = 0;
    QVals(2) = 2^(handles.settingsStruct.constCameraBits)-1;
end
handles.settingsStruct.blackLevelLEDQuad1 = QVals(1);
handles.settingsStruct.whiteLevelLEDQuad1 = QVals(2);
QVals = quantile(double(maskedLEDQuad2Data(maskedLEDQuad2Data>0)),[handles.settingsStruct.analysisAutoScaleLowQuantile,handles.settingsStruct.analysisAutoScaleHighQuantile]);
if QVals(1) == QVals(2)
    QVals(1) = 0;
    QVals(2) = 2^(handles.settingsStruct.constCameraBits)-1;
end
handles.settingsStruct.blackLevelLEDQuad2 = QVals(1);
handles.settingsStruct.whiteLevelLEDQuad2 = QVals(2);
QVals = quantile(double(maskedLEDQuad3Data(maskedLEDQuad3Data>0)),[handles.settingsStruct.analysisAutoScaleLowQuantile,handles.settingsStruct.analysisAutoScaleHighQuantile]);
if QVals(1) == QVals(2)
    QVals(1) = 0;
    QVals(2) = 2^(handles.settingsStruct.constCameraBits)-1;
end
handles.settingsStruct.blackLevelLEDQuad3 = QVals(1);
handles.settingsStruct.whiteLevelLEDQuad3 = QVals(2);
QVals = quantile(double(maskedLEDQuad4Data(maskedLEDQuad4Data>0)),[handles.settingsStruct.analysisAutoScaleLowQuantile,handles.settingsStruct.analysisAutoScaleHighQuantile]);
if QVals(1) == QVals(2)
    QVals(1) = 0;
    QVals(2) = 2^(handles.settingsStruct.constCameraBits)-1;
end
handles.settingsStruct.blackLevelLEDQuad4 = QVals(1);
handles.settingsStruct.whiteLevelLEDQuad4 = QVals(2);

% scale image "CLim"s
set(handles.LED1Ax,'CLim',[handles.settingsStruct.blackLevelLED1,handles.settingsStruct.whiteLevelLED1]);
set(handles.LED2Ax,'CLim',[handles.settingsStruct.blackLevelLED2,handles.settingsStruct.whiteLevelLED2]);
set(handles.LEDQuad1Ax,'CLim',[handles.settingsStruct.blackLevelLEDQuad1,handles.settingsStruct.whiteLevelLEDQuad1]);
set(handles.LEDQuad2Ax,'CLim',[handles.settingsStruct.blackLevelLEDQuad2,handles.settingsStruct.whiteLevelLEDQuad2]);
set(handles.LEDQuad3Ax,'CLim',[handles.settingsStruct.blackLevelLEDQuad3,handles.settingsStruct.whiteLevelLEDQuad3]);
set(handles.LEDQuad4Ax,'CLim',[handles.settingsStruct.blackLevelLEDQuad4,handles.settingsStruct.whiteLevelLEDQuad4]);

% Set the indicators of black vs white values correctly
set(handles.LED1BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLED1))]);
set(handles.LED1WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLED1))]);
set(handles.LED2BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLED2))]);
set(handles.LED2WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLED2))]);
set(handles.LEDQuad1BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLEDQuad1))]);
set(handles.LEDQuad1WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLEDQuad1))]);
set(handles.LEDQuad2BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLEDQuad2))]);
set(handles.LEDQuad2WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLEDQuad2))]);
set(handles.LEDQuad3BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLEDQuad3))]);
set(handles.LEDQuad3WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLEDQuad3))]);
set(handles.LEDQuad4BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLEDQuad4))]);
set(handles.LEDQuad4WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLEDQuad4))]);

guidata(hObject, handles);


% --- Executes on button press in commRTStats.
function commRTStats_Callback(hObject, eventdata, handles)
% Get the new state of RT (=real time) Statistics button
handles.settingsStruct.commRTStats = get(handles.commRTStats,'Value');
prevModeOn = get(handles.prevStartButton,'Value');
% if the button is now checked, we need to enable several stat indicators
if handles.settingsStruct.commRTStats == 1
    % check which viewing mode
    if handles.settingsStruct.selectLEDsQuadViewOn == 1 % ... if we are in quad-view mode
        if handles.LEDsToEnable(1) == 1
            handles.LEDQuad1StatsIndicator.Visible = 'on';
            if prevModeOn == 0 % if the preview mode is not on, we can compute stats based on current image data
                frameData = get(handles.imgHandLEDQuad1,'CData').*handles.imageMask;
                maskedCroppedData = frameData(frameData>0);
                percentSat = 100*sum(maskedCroppedData == (2^handles.settingsStruct.constCameraBits-1))/numel(maskedCroppedData);
                dispStr = [handles.settingsStruct.constLED1CenterWavelength ': Min: ' num2str(min(maskedCroppedData)) ', Max: ' num2str(max(maskedCroppedData)) ', Mean: ' num2str(mean(maskedCroppedData),5) ', Sat: ' num2str(percentSat,3) '%'];
                set(handles.LEDQuad1StatsIndicator,'String',dispStr);
            end
        else
            handles.LEDQuad1StatsIndicator.Visible = 'off';
        end
        if handles.LEDsToEnable(2) == 1
            handles.LEDQuad2StatsIndicator.Visible = 'on';
            if prevModeOn == 0 % if the preview mode is not on, we can compute stats based on current image data
                frameData = get(handles.imgHandLEDQuad2,'CData').*handles.imageMask;
                maskedCroppedData = frameData(frameData>0);
                percentSat = 100*sum(maskedCroppedData == (2^handles.settingsStruct.constCameraBits-1))/numel(maskedCroppedData);
                dispStr = [handles.settingsStruct.constLED2CenterWavelength ': Min: ' num2str(min(maskedCroppedData)) ', Max: ' num2str(max(maskedCroppedData)) ', Mean: ' num2str(mean(maskedCroppedData),5) ', Sat: ' num2str(percentSat,3) '%'];
                set(handles.LEDQuad2StatsIndicator,'String',dispStr);
            end
        else
            handles.LEDQuad2StatsIndicator.Visible = 'off';
        end
        if handles.LEDsToEnable(3) == 1
            handles.LEDQuad3StatsIndicator.Visible = 'on';
            if prevModeOn == 0 % if the preview mode is not on, we can compute stats based on current image data
                frameData = get(handles.imgHandLEDQuad3,'CData').*handles.imageMask;
                maskedCroppedData = frameData(frameData>0);
                percentSat = 100*sum(maskedCroppedData == (2^handles.settingsStruct.constCameraBits-1))/numel(maskedCroppedData);
                dispStr = [handles.settingsStruct.constLED3CenterWavelength ': Min: ' num2str(min(maskedCroppedData)) ', Max: ' num2str(max(maskedCroppedData)) ', Mean: ' num2str(mean(maskedCroppedData),5) ', Sat: ' num2str(percentSat,3) '%'];
                set(handles.LEDQuad3StatsIndicator,'String',dispStr);
            end
        else
            handles.LEDQuad3StatsIndicator.Visible = 'off';
        end
        if handles.LEDsToEnable(4) == 1
            handles.LEDQuad4StatsIndicator.Visible = 'on';
            if prevModeOn == 0 % if the preview mode is not on, we can compute stats based on current image data
                frameData = get(handles.imgHandLEDQuad4,'CData').*handles.imageMask;
                maskedCroppedData = frameData(frameData>0);
                percentSat = 100*sum(maskedCroppedData == (2^handles.settingsStruct.constCameraBits-1))/numel(maskedCroppedData);
                dispStr = [handles.settingsStruct.constLED4CenterWavelength ': Min: ' num2str(min(maskedCroppedData)) ', Max: ' num2str(max(maskedCroppedData)) ', Mean: ' num2str(mean(maskedCroppedData),5) ', Sat: ' num2str(percentSat,3) '%'];
                set(handles.LEDQuad4StatsIndicator,'String',dispStr);
            end
        else
            handles.LEDQuad4StatsIndicator.Visible = 'off';
        end
        handles.LED1ColorIndicator.Visible = 'off';
        handles.LED1MinIndicator.Visible = 'off';
        handles.LED1MaxIndicator.Visible = 'off';
        handles.LED1MeanIndicator.Visible = 'off';
        handles.LED1MedianIndicator.Visible = 'off';
        handles.LED1PercentSaturatedIndicator.Visible = 'off';
        handles.LED2ColorIndicator.Visible = 'off';
        handles.LED2MinIndicator.Visible = 'off';
        handles.LED2MaxIndicator.Visible = 'off';
        handles.LED2MeanIndicator.Visible = 'off';
        handles.LED2MedianIndicator.Visible = 'off';
        handles.LED2PercentSaturatedIndicator.Visible = 'off';
    else % otherwise, we're not in quad view-mode
        % We need to choose which LEDs to show on the RT stat indicators
        allLEDChoices = {handles.settingsStruct.constLED1CenterWavelength handles.settingsStruct.constLED2CenterWavelength handles.settingsStruct.constLED3CenterWavelength handles.settingsStruct.constLED4CenterWavelength};
        requestedLEDChoices = allLEDChoices(logical(handles.LEDsToEnable));
        set(handles.LED1ColorIndicator,'String',['LED 1: ' requestedLEDChoices{1}]);
        if sum(handles.LEDsToEnable,2) == 2
            set(handles.LED2ColorIndicator,'String',['LED 2: ' requestedLEDChoices{2}]);
        end
        % Show/hide indicator fields and update if not in live mode already
        handles.LED1ColorIndicator.Visible = 'on';
        handles.LED1MinIndicator.Visible = 'on';
        handles.LED1MaxIndicator.Visible = 'on';
        handles.LED1MeanIndicator.Visible = 'on';
        handles.LED1MedianIndicator.Visible = 'on';
        handles.LED1PercentSaturatedIndicator.Visible = 'on';
        if prevModeOn == 0
            frameData = get(handles.imgHandLED1,'CData').*handles.imageMask;
            maskedCroppedData = frameData(frameData>0);
            set(handles.LED1MaxIndicator,'String',['Max: ' num2str(max(maskedCroppedData))]);
            set(handles.LED1MinIndicator,'String',['Min: ' num2str(min(maskedCroppedData))]);
            set(handles.LED1MeanIndicator,'String',['Mean: ' num2str(mean(maskedCroppedData),4)]);
            set(handles.LED1MedianIndicator,'String',['Median: ' num2str(median(maskedCroppedData),4)]);
            percentSat = 100*sum(maskedCroppedData == (2^handles.settingsStruct.constCameraBits-1))/numel(maskedCroppedData);
            set(handles.LED1PercentSaturatedIndicator,'String',['% Saturated: ' num2str(percentSat,3) '%']);
        end
        if sum(handles.LEDsToEnable,2) == 2
            handles.LED2ColorIndicator.Visible = 'on';
            handles.LED2MinIndicator.Visible = 'on';
            handles.LED2MaxIndicator.Visible = 'on';
            handles.LED2MeanIndicator.Visible = 'on';
            handles.LED2MedianIndicator.Visible = 'on';
            handles.LED2PercentSaturatedIndicator.Visible = 'on';
            if prevModeOn == 0
                frameData = get(handles.imgHandLED2,'CData').*handles.imageMask;
                maskedCroppedData = frameData(frameData>0);
                set(handles.LED2MaxIndicator,'String',['Max: ' num2str(max(maskedCroppedData))]);
                set(handles.LED2MinIndicator,'String',['Min: ' num2str(min(maskedCroppedData))]);
                set(handles.LED2MeanIndicator,'String',['Mean: ' num2str(mean(maskedCroppedData),4)]);
                set(handles.LED2MedianIndicator,'String',['Median: ' num2str(median(maskedCroppedData),4)]);
                percentSat = 100*sum(maskedCroppedData == (2^handles.settingsStruct.constCameraBits-1))/numel(maskedCroppedData);
                set(handles.LED2PercentSaturatedIndicator,'String',['% Saturated: ' num2str(percentSat,3) '%']);
            end
        else
            handles.LED2ColorIndicator.Visible = 'off';
            handles.LED2MinIndicator.Visible = 'off';
            handles.LED2MaxIndicator.Visible = 'off';
            handles.LED2MeanIndicator.Visible = 'off';
            handles.LED2MedianIndicator.Visible = 'off';
            handles.LED2PercentSaturatedIndicator.Visible = 'off';
        end
        handles.LEDQuad1StatsIndicator.Visible = 'off';
        handles.LEDQuad2StatsIndicator.Visible = 'off';
        handles.LEDQuad3StatsIndicator.Visible = 'off';
        handles.LEDQuad4StatsIndicator.Visible = 'off';
    end
    
else % otherwise we chose to hide the RT stats
    % so hide all the stat indicators
    handles.LEDQuad1StatsIndicator.Visible = 'off';
    handles.LEDQuad2StatsIndicator.Visible = 'off';
    handles.LEDQuad3StatsIndicator.Visible = 'off';
    handles.LEDQuad4StatsIndicator.Visible = 'off';
    handles.LED1ColorIndicator.Visible = 'off';
    handles.LED1MinIndicator.Visible = 'off';
    handles.LED1MaxIndicator.Visible = 'off';
    handles.LED1MeanIndicator.Visible = 'off';
    handles.LED1MedianIndicator.Visible = 'off';
    handles.LED1PercentSaturatedIndicator.Visible = 'off';
    handles.LED2ColorIndicator.Visible = 'off';
    handles.LED2MinIndicator.Visible = 'off';
    handles.LED2MaxIndicator.Visible = 'off';
    handles.LED2MeanIndicator.Visible = 'off';
    handles.LED2MedianIndicator.Visible = 'off';
    handles.LED2PercentSaturatedIndicator.Visible = 'off';
end
guidata(hObject, handles);


% --- Executes on button press in commRTHistogram.
function commRTHistogram_Callback(hObject, eventdata, handles)
% Get the new state of RT (=Real-time) Histogram setting
handles.settingsStruct.commRTHistogram = get(handles.commRTHistogram,'Value');
prevModeOn = get(handles.prevStartButton,'Value');
if handles.settingsStruct.commRTHistogram == 1 % If it is now on, check whether...
    %... we are in quad mode
    if handles.settingsStruct.selectLEDsQuadViewOn == 1
        % then we need to show all the quad view histogram axes that are
        % required
        if handles.LEDsToEnable(1) == 1
            handles.histHandLEDQuad1.Visible = 'on';
            handles.LEDQuad1Hist.Visible = 'on';
            if prevModeOn == 0
                intermediateData = get(handles.imgHandLEDQuad1,'CData').*handles.imageMask;
                handles.histHandLEDQuad1.Data = intermediateData(intermediateData>0);
            end
        else
            handles.histHandLEDQuad1.Visible = 'off';
            handles.LEDQuad1Hist.Visible = 'off';
        end
        if handles.LEDsToEnable(2) == 1
            handles.histHandLEDQuad2.Visible = 'on';
            handles.LEDQuad2Hist.Visible = 'on';
            if prevModeOn == 0
                intermediateData = get(handles.imgHandLEDQuad2,'CData').*handles.imageMask;
                handles.histHandLEDQuad2.Data = intermediateData(intermediateData>0);
            end
        else
            handles.histHandLEDQuad2.Visible = 'off';
            handles.LEDQuad2Hist.Visible = 'off';
        end
        if handles.LEDsToEnable(3) == 1
            handles.histHandLEDQuad3.Visible = 'on';
            handles.LEDQuad3Hist.Visible = 'on';
            if prevModeOn == 0
                intermediateData = get(handles.imgHandLEDQuad3,'CData').*handles.imageMask;
                handles.histHandLEDQuad3.Data = intermediateData(intermediateData>0);
            end
        else
            handles.histHandLEDQuad3.Visible = 'off';
            handles.LEDQuad3Hist.Visible = 'off';
        end
        if handles.LEDsToEnable(4) == 1
            handles.histHandLEDQuad4.Visible = 'on';
            handles.LEDQuad4Hist.Visible = 'on';
            if prevModeOn == 0
                intermediateData = get(handles.imgHandLEDQuad4,'CData').*handles.imageMask;
                handles.histHandLEDQuad4.Data = intermediateData(intermediateData>0);
            end
        else
            handles.histHandLEDQuad4.Visible = 'off';
            handles.LEDQuad4Hist.Visible = 'off';
        end
        handles.histHandLED1.Visible = 'off';
        handles.LED1Hist.Visible = 'off';
        handles.histHandLED2.Visible = 'off';
        handles.LED2Hist.Visible = 'off';
    else %otherwise we're not in quad view
        handles.histHandLED1.Visible = 'on';
        handles.LED1Hist.Visible = 'on';
        if prevModeOn == 0
            intermediateData = get(handles.imgHandLED1,'CData').*handles.imageMask;
            handles.histHandLED1.Data = intermediateData(intermediateData>0);
        end
        if sum(handles.LEDsToEnable,2) == 2
            handles.histHandLED2.Visible = 'on';
            handles.LED2Hist.Visible = 'on';
            if prevModeOn == 0
                intermediateData = get(handles.imgHandLED2,'CData').*handles.imageMask;
                handles.histHandLED2.Data = intermediateData(intermediateData>0);
            end
        else
            handles.histHandLED2.Visible = 'off';
            handles.LED2Hist.Visible = 'off';
        end
        handles.histHandLEDQuad1.Visible = 'off';
        handles.LEDQuad1Hist.Visible = 'off';
        handles.histHandLEDQuad2.Visible = 'off';
        handles.LEDQuad2Hist.Visible = 'off';
        handles.histHandLEDQuad3.Visible = 'off';
        handles.LEDQuad3Hist.Visible = 'off';
        handles.histHandLEDQuad4.Visible = 'off';
        handles.LEDQuad4Hist.Visible = 'off';
    end
else % Otherwise, we just un-checked RT Histograms, so hide all hist axes
    handles.histHandLEDQuad1.Visible = 'off';
    handles.LEDQuad1Hist.Visible = 'off';
    handles.histHandLEDQuad2.Visible = 'off';
    handles.LEDQuad2Hist.Visible = 'off';
    handles.histHandLEDQuad3.Visible = 'off';
    handles.LEDQuad3Hist.Visible = 'off';
    handles.histHandLEDQuad4.Visible = 'off';
    handles.LEDQuad4Hist.Visible = 'off';
    handles.histHandLED1.Visible = 'off';
    handles.LED1Hist.Visible = 'off';
    handles.histHandLED2.Visible = 'off';
    handles.LED2Hist.Visible = 'off';
end
guidata(hObject, handles);


% --- Executes on button press in saveSettings.
function saveSettings_Callback(hObject, eventdata, handles)
handles.settingsStruct.saveSettings = get(handles.saveSettings,'Value');
guidata(hObject, handles);

% --- Executes on selection change in capPixClock.
function capPixClock_Callback(hObject, eventdata, handles)
handles.settingsStruct.capPixClock = get(handles.capPixClock,'Value');
switch handles.settingsStruct.capPixClock
    case 1
        dispPixClock = '12 MPix/s';
    case 2
        dispPixClock = '24 MPix/s';
end
handles = estimate_capture_time_data(handles);
guidata(hObject, handles);
disp(['Capture pixel read set to ' dispPixClock]);

% --- Executes during object creation, after setting all properties.
function capPixClock_CreateFcn(hObject, eventdata, handles)
% hObject    handle to capPixClock (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in prevPixClock.
function prevPixClock_Callback(hObject, eventdata, handles)
handles.settingsStruct.prevPixClock = get(handles.prevPixClock,'Value');
switch handles.settingsStruct.prevPixClock
    case 1
        dispPixClock = '12 MPix/s';
    case 2
        dispPixClock = '24 MPix/s';
end
disp(['Preview pixel read set to ' dispPixClock]);
% if the lock capture settings option is enabled, then update the capture
% mode's setting for this
if handles.settingsStruct.capLockSettings == 1
    handles.settingsStruct.capPixClock = handles.settingsStruct.prevPixClock;
    set(handles.capPixClock,'Value',handles.settingsStruct.capPixClock);
    handles = estimate_capture_time_data(handles);
    disp(['Capture pixel read set to ' dispPixClock]);
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function prevPixClock_CreateFcn(hObject, eventdata, handles)
% hObject    handle to prevPixClock (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in saveFrameTimes.
function saveFrameTimes_Callback(hObject, eventdata, handles)
handles.settingsStruct.saveFrameTimes = get(handles.saveFrameTimes,'Value');
guidata(hObject,handles);

% --- Executes on button press in RTFlattening.
function RTFlattening_Callback(hObject, eventdata, handles)
handles.settingsStruct.RTFlattening = get(handles.RTFlattening,'Value');
guidata(hObject,handles);

% % Update image mask [[NOTE ALL OF THIS HAS BEEN RETIRED BC STAT/HIST IN
% CENTER IS NOW ON BY DEFAULT AND NOT ADJUSTABLE DURING IMAGING]]
% pixDim = handles.settingsStruct.numPixPerDim;
% if handles.settingsStruct.analysisReduceNumPixels == 1
%     imageMaskMask = mod(bsxfun(@plus,uint16(1:pixDim),uint16((1:pixDim)')),2);
% else
%     imageMaskMask = ones(pixDim,'uint16');
% end
% if handles.settingsStruct.commStatHistInCenter == 1
%     selectRad = 0.5*pixDim*handles.settingsStruct.analysisSelectCenterRadPercent;
%     scaledYOffset = round(handles.settingsStruct.constYOffset*pixDim/520);
%     [x, y] = meshgrid(1:pixDim, (1+scaledYOffset):(pixDim+scaledYOffset));
%     handles.imageMask = uint16((x-.5*pixDim-1).^2+(y-.5*pixDim-1).^2 <= selectRad^2).*imageMaskMask;
% else
%     handles.imageMask = ones(pixDim,'uint16').*imageMaskMask;
% end
% 
% % if de-selected then disable the ascii timestamps because that will mess
% % up the thresholding
% if handles.settingsStruct.commStatHistInCenter == 0
%     handles.settingsStruct.TMTimestampMode = 'No Stamp';
%     handles.srcObj.TMTimestampMode = 'No Stamp';
% end
% 
% guidata(hObject,handles);


% --- Executes on button press in selectLEDsEnable1. -- NOTE: this button
% is unavailable to click during preview mode (and of course capture mode)
function selectLEDsEnable1_Callback(hObject, eventdata, handles)
% If we were just in capture mode with different LEDs selected, then fix
% this before enabling anything here
if handles.settingsStruct.justFinishedCap == 1
    handles.settingsStruct.justFinishedCap = 0; % Important to disable this flag here or else it will go into a never-ending loop
    if handles.prevLEDsToEnable(1) ~= handles.capLEDsToEnable(1)
        % Get previous state
        previousState = get(handles.selectLEDsEnable1,'Value');
        % Force preview state for this button
        set(handles.selectLEDsEnable1,'Value',handles.prevLEDsToEnable(1));
        % Run callback for this LED's button & update handles
        selectLEDsEnable1_Callback(hObject, eventdata, handles);handles = guidata(hObject);
        % Reset Value to previous state-so the rest of the callback can do
        % its thing
        set(handles.selectLEDsEnable1,'Value',previousState);
    end
    if handles.prevLEDsToEnable(2) ~= handles.capLEDsToEnable(2)
        % Force preview state for this button
        set(handles.selectLEDsEnable2,'Value',handles.prevLEDsToEnable(2));
        % Run callback for this LED's button & update handles
        selectLEDsEnable2_Callback(hObject, eventdata, handles);handles = guidata(hObject);
    end
    if handles.prevLEDsToEnable(3) ~= handles.capLEDsToEnable(3)
        % Force preview state for this button
        set(handles.selectLEDsEnable3,'Value',handles.prevLEDsToEnable(3));
        % Run callback for this LED's button & update handles
        selectLEDsEnable3_Callback(hObject, eventdata, handles);handles = guidata(hObject);
    end
    if handles.prevLEDsToEnable(4) ~= handles.capLEDsToEnable(4)
        % Force preview state for this button
        set(handles.selectLEDsEnable4,'Value',handles.prevLEDsToEnable(4));
        % Run callback for this LED's button & update handles
        selectLEDsEnable4_Callback(hObject, eventdata, handles);handles = guidata(hObject);
    end
end

if (sum(handles.LEDsToEnable,2) == 1) && (get(handles.selectLEDsEnable1,'value') == 0)
    disp('Error: You may not disable all LEDs.')
    set(handles.selectLEDsEnable1,'value',1);
    return
end
if (get(handles.selectLEDsEnable1,'Value') == 0) && (handles.settingsStruct.selectLEDsShow == 1)
    % if we de-selected this LED, but the show LED on big axis is supposed
    % to show this LED, fix it, and put the right data on the big axis
    % RELEVANT FOR 4->3 LED CHANNELS
    if sum(handles.LEDsToEnable,2) == 4 % if the sum here is 4 (was 4 before clicking), then we must have deselected this LED
        if handles.LEDsToEnable(2) == 1
            set(handles.selectLEDsShow,'Value',2);
            handles.settingsStruct.selectLEDsShow = 2;
            newFrameData = get(handles.imgHandLEDQuad2,'CData');
            newLims = get(handles.LEDQuad2Ax,'CLim');
        elseif handles.LEDsToEnable(3) == 1
            set(handles.selectLEDsShow,'Value',3);
            handles.settingsStruct.selectLEDsShow = 3;
            newFrameData = get(handles.imgHandLEDQuad3,'CData');
            newLims = get(handles.LEDQuad3Ax,'CLim');
        elseif handles.LEDsToEnable(4) == 1
            set(handles.selectLEDsShow,'Value',4);
            handles.settingsStruct.selectLEDsShow = 4;
            newFrameData = get(handles.imgHandLEDQuad4,'CData');
            newLims = get(handles.LEDQuad4Ax,'CLim');
        end
        set(handles.imgHandLED1,'CData',newFrameData);
        set(handles.LED1Ax,'CLim',newLims);
        handles.settingsStruct.blackLevelLED1= newLims(1);
        handles.settingsStruct.whiteLevelLED1 = newLims(2);
        set(handles.LED1BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLED1))]);
        set(handles.LED1WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLED1))]);
    else
        if handles.LEDsToEnable(2) == 1 % and these 3 options just change the selected LED to show on big axis (but nothing changes)
            set(handles.selectLEDsShow,'Value',2);
            handles.settingsStruct.selectLEDsShow = 2;
        elseif handles.LEDsToEnable(3) == 1
            set(handles.selectLEDsShow,'Value',3);
            handles.settingsStruct.selectLEDsShow = 3;
        elseif handles.LEDsToEnable(4) == 1
            set(handles.selectLEDsShow,'Value',4);
            handles.settingsStruct.selectLEDsShow = 4;
        end 
    end
end

% Determine if quad view was enabled before changing LEDs
prevQuad = handles.settingsStruct.selectLEDsQuadViewOn;
% Save the new setting for this LED
handles.settingsStruct.selectLEDsEnable1 = get(handles.selectLEDsEnable1,'value');
prevLEDsToEnable = handles.LEDsToEnable; % for switching image data around
handles.LEDsToEnable(1) = handles.settingsStruct.selectLEDsEnable1;
if handles.settingsStruct.inCapMode == 0
    handles.settingsStruct.prevLEDsEnable1 = handles.settingsStruct.selectLEDsEnable1;
    handles.prevLEDsToEnable(1) = handles.settingsStruct.selectLEDsEnable1;
    % If the capture mode LED choices are locked to preview mode, then
    % switch capture mode settings, gui values
    if handles.settingsStruct.selectLEDsLockCap == 1
        handles.settingsStruct.capLEDsEnable1 = handles.settingsStruct.selectLEDsEnable1;
        handles.capLEDsToEnable(1) = handles.prevLEDsToEnable(1);
        set(handles.capLEDsEnable1,'Value',handles.settingsStruct.capLEDsEnable1);
    end
end
% Confirm (on command line) the LED change made
if handles.settingsStruct.selectLEDsEnable1 == 1
    disp([handles.settingsStruct.constLED1CenterWavelength ' LED turned ON.']);
else
    disp([handles.settingsStruct.constLED1CenterWavelength ' LED turned OFF.']);
end

% Turn on quad-view setting/change the quad view enable mode
if sum(handles.LEDsToEnable,2) > 2
    handles.settingsStruct.selectLEDsQuadViewOn = 1;
else
    handles.settingsStruct.selectLEDsQuadViewOn = 0;
end

% Determine which image axes to show/hide
if handles.settingsStruct.selectLEDsQuadViewOn == 1
    if prevQuad == 0
        disp('Turning quad-channel view mode on')
        % We have crossed the threshold and need to switch some axes to
        % enable the quad-channel view
        handles.imgHandLED2.Visible = 'off';
        handles.LED1DisplayedValues.Visible = 'off';
        handles.LED1BlackValueIndicator.Visible = 'off';
        handles.LED1WhiteValueIndicator.Visible = 'off';
        handles.LED2DisplayedValues.Visible = 'off';
        handles.LED2BlackValueIndicator.Visible = 'off';
        handles.LED2WhiteValueIndicator.Visible = 'off';
        
        % Variable for switching frames
        switchFrames=ones(size(handles.imageMask,1),size(handles.imageMask,2),2,'uint16');
        switchCLim=zeros(2,2);
        switchFrames(:,:,1) = get(handles.imgHandLED1,'CData'); 
        switchFrames(:,:,2) = get(handles.imgHandLED2,'CData');
        switchCLim(:,1) = get(handles.LED1Ax,'CLim');
        switchCLim(:,2) = get(handles.LED2Ax,'CLim');
        quadIdx = 1;
        
        %If we have transitions from quad off to on, then we MUST have enabled this channel
        handles.imgHandLEDQuad1.Visible = 'on'; 
        handles.LEDQuad1DisplayedValues.Visible = 'on';
        handles.LEDQuad1BlackValueIndicator.Visible = 'on';
        handles.LEDQuad1WhiteValueIndicator.Visible = 'on';
        % Also blank this frame axis (in case there is old imagery)
        set(handles.imgHandLEDQuad1,'CData',ones(size(handles.imageMask,1),'uint16'));
        blankLims = [0, (2^(handles.settingsStruct.constCameraBits)-1)];
        set(handles.LEDQuad1Ax,'CLim',blankLims);
        handles.settingsStruct.blackLevelLEDQuad1= blankLims(1);
        handles.settingsStruct.whiteLevelLEDQuad1 = blankLims(2);
        set(handles.LEDQuad1BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLEDQuad1))]);
        set(handles.LEDQuad1WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLEDQuad1))]);
        
        if handles.LEDsToEnable(2) == 1
            handles.imgHandLEDQuad2.Visible = 'on';
            handles.LEDQuad2DisplayedValues.Visible = 'on';
            handles.LEDQuad2BlackValueIndicator.Visible = 'on';
        	handles.LEDQuad2WhiteValueIndicator.Visible = 'on';
            if prevLEDsToEnable(2) == 1
                set(handles.imgHandLEDQuad2,'CData',switchFrames(:,:,quadIdx));
                set(handles.LEDQuad2Ax,'CLim',switchCLim(:,quadIdx));
                handles.settingsStruct.blackLevelLEDQuad2= switchCLim(1,quadIdx);
                handles.settingsStruct.whiteLevelLEDQuad2 = switchCLim(2,quadIdx);
                set(handles.LEDQuad2BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLEDQuad2))]);
                set(handles.LEDQuad2WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLEDQuad2))]);
                quadIdx = quadIdx + 1;
            end
        end
        if handles.LEDsToEnable(3) == 1
            handles.imgHandLEDQuad3.Visible = 'on';
            handles.LEDQuad3DisplayedValues.Visible = 'on';
            handles.LEDQuad3BlackValueIndicator.Visible = 'on';
            handles.LEDQuad3WhiteValueIndicator.Visible = 'on';
            if prevLEDsToEnable(3) == 1
                set(handles.imgHandLEDQuad3,'CData',switchFrames(:,:,quadIdx));
                set(handles.LEDQuad3Ax,'CLim',switchCLim(:,quadIdx));
                handles.settingsStruct.blackLevelLEDQuad3= switchCLim(1,quadIdx);
                handles.settingsStruct.whiteLevelLEDQuad3 = switchCLim(2,quadIdx);
                set(handles.LEDQuad3BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLEDQuad3))]);
                set(handles.LEDQuad3WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLEDQuad3))]);
                quadIdx = quadIdx + 1;
            end
        end
        if handles.LEDsToEnable(4) == 1
            handles.imgHandLEDQuad4.Visible = 'on';
            handles.LEDQuad4DisplayedValues.Visible = 'on';
            handles.LEDQuad4BlackValueIndicator.Visible = 'on';
            handles.LEDQuad4WhiteValueIndicator.Visible = 'on';
            if prevLEDsToEnable(4) == 1
                set(handles.imgHandLEDQuad4,'CData',switchFrames(:,:,quadIdx));
                set(handles.LEDQuad4Ax,'CLim',switchCLim(:,quadIdx));
                handles.settingsStruct.blackLevelLEDQuad4 = switchCLim(1,quadIdx);
                handles.settingsStruct.whiteLevelLEDQuad4 = switchCLim(2,quadIdx);
                set(handles.LEDQuad4BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLEDQuad4))]);
                set(handles.LEDQuad4WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLEDQuad4))]);
            end
        end
    else
        % If we were in quad mode and we still are, then there are two possibilities
        if handles.settingsStruct.selectLEDsEnable1 == 1
            handles.imgHandLEDQuad1.Visible = 'on';
            handles.LEDQuad1DisplayedValues.Visible = 'on';
            handles.LEDQuad1BlackValueIndicator.Visible = 'on';
            handles.LEDQuad1WhiteValueIndicator.Visible = 'on';
            set(handles.imgHandLEDQuad1,'CData',ones(size(handles.imageMask,1),'uint16')); % show blank frame
            blankLims = [0, (2^(handles.settingsStruct.constCameraBits)-1)];
            set(handles.LEDQuad1Ax,'CLim',blankLims);
            handles.settingsStruct.blackLevelLEDQuad1= blankLims(1);
            handles.settingsStruct.whiteLevelLEDQuad1 = blankLims(2);
            set(handles.LEDQuad1BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLEDQuad1))]);
            set(handles.LEDQuad1WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLEDQuad1))]);
        else
            handles.imgHandLEDQuad1.Visible = 'off';
            handles.LEDQuad1DisplayedValues.Visible = 'off';
            handles.LEDQuad1BlackValueIndicator.Visible = 'off';
            handles.LEDQuad1WhiteValueIndicator.Visible = 'off';
        end
    end
else % now we are NOT in quad mode
    if prevQuad == 1 % but if we just were in quad mode, then make sure to hide all those axis
        disp('Turning quad-channel view mode off')
        handles.imgHandLED2.Visible = 'on';
        handles.LED1DisplayedValues.Visible = 'on';
        handles.LED1BlackValueIndicator.Visible = 'on';
        handles.LED1WhiteValueIndicator.Visible = 'on';
        handles.LED2DisplayedValues.Visible = 'on';
        handles.LED2BlackValueIndicator.Visible = 'on';
        handles.LED2WhiteValueIndicator.Visible = 'on';
        handles.imgHandLEDQuad1.Visible = 'off';
        handles.imgHandLEDQuad2.Visible = 'off';
        handles.imgHandLEDQuad3.Visible = 'off';
        handles.imgHandLEDQuad4.Visible = 'off';
        handles.LEDQuad1DisplayedValues.Visible = 'off';
        handles.LEDQuad1BlackValueIndicator.Visible = 'off';
        handles.LEDQuad1WhiteValueIndicator.Visible = 'off';
        handles.LEDQuad2DisplayedValues.Visible = 'off';
        handles.LEDQuad2BlackValueIndicator.Visible = 'off';
        handles.LEDQuad2WhiteValueIndicator.Visible = 'off';
        handles.LEDQuad3DisplayedValues.Visible = 'off';
        handles.LEDQuad3BlackValueIndicator.Visible = 'off';
        handles.LEDQuad3WhiteValueIndicator.Visible = 'off';
        handles.LEDQuad4DisplayedValues.Visible = 'off';
        handles.LEDQuad4BlackValueIndicator.Visible = 'off';
        handles.LEDQuad4WhiteValueIndicator.Visible = 'off';
        % Determine which frames to put where--use LEDsToEnable to
        % determine which frame data to add to 2-image axes
        switchFrames=ones(size(handles.imageMask,1),size(handles.imageMask,2),2,'uint16');
        switchCLim = zeros(2,2);
        quadIdx = 1;
        if handles.LEDsToEnable(2) == 1
            switchFrames(:,:,quadIdx) = get(handles.imgHandLEDQuad2,'CData');
            switchCLim(:,quadIdx) = get(handles.LEDQuad2Ax,'CLim');
            quadIdx = quadIdx+1;
        end
        if handles.LEDsToEnable(3) == 1
            switchFrames(:,:,quadIdx) = get(handles.imgHandLEDQuad3,'CData');
            switchCLim(:,quadIdx) = get(handles.LEDQuad3Ax,'CLim');
            quadIdx = quadIdx+1;
        end
        if handles.LEDsToEnable(4) == 1
            switchFrames(:,:,quadIdx) = get(handles.imgHandLEDQuad4,'CData');
            switchCLim(:,quadIdx) = get(handles.LEDQuad4Ax,'CLim');
        end
        set(handles.imgHandLED1,'CData',switchFrames(:,:,1));
        set(handles.imgHandLED2,'CData',switchFrames(:,:,2));
        set(handles.LED1Ax,'CLim',switchCLim(:,1));
        set(handles.LED2Ax,'CLim',switchCLim(:,2));
        handles.settingsStruct.blackLevelLED1= switchCLim(1,1);
        handles.settingsStruct.whiteLevelLED1 = switchCLim(2,1);
        set(handles.LED1BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLED1))]);
        set(handles.LED1WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLED1))]);
        handles.settingsStruct.blackLevelLED2= switchCLim(1,2);
        handles.settingsStruct.whiteLevelLED2 = switchCLim(2,2);
        set(handles.LED2BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLED2))]);
        set(handles.LED2WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLED2))]);

    else % if we were not in quad mode and are still not in quad mode
        if handles.settingsStruct.selectLEDsEnable1 == 1
            handles.imgHandLED2.Visible = 'on';
            handles.LED2DisplayedValues.Visible = 'on';
            handles.LED2BlackValueIndicator.Visible = 'on';
            handles.LED2WhiteValueIndicator.Visible = 'on';
            set(handles.imgHandLED2,'CData',ones(size(handles.imageMask,1),'uint16')); % blank the second axis
            blankLims = [0, (2^(handles.settingsStruct.constCameraBits)-1)];
            set(handles.LED2Ax,'CLim',blankLims);
            handles.settingsStruct.blackLevelLED2= blankLims(1);
            handles.settingsStruct.whiteLevelLED2 = blankLims(2);
            set(handles.LED2BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLED2))]);
            set(handles.LED2WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLED2))]);
        else
            handles.imgHandLED2.Visible = 'off';
            handles.LED2DisplayedValues.Visible = 'off';
            handles.LED2BlackValueIndicator.Visible = 'off';
            handles.LED2WhiteValueIndicator.Visible = 'off';
            % Transfer image data from one frame to the other, if necessary
            countVect = 1:4;
            if 1 < countVect(logical(handles.LEDsToEnable))
                swapFrame = get(handles.imgHandLED2,'CData');
                swapCLim = get(handles.LED2Ax,'CLim');
                set(handles.imgHandLED1,'CData',swapFrame);
                set(handles.LED1Ax,'CLim',swapCLim);
                handles.settingsStruct.blackLevelLED1= swapCLim(1);
                handles.settingsStruct.whiteLevelLED1 = swapCLim(2);
                set(handles.LED1BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLED1))]);
                set(handles.LED1WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLED1))]);
            end
        end
    end
end

% Recompute RT Stats and Histograms (if requested, functions below will
% check this)
commRTStats_Callback(hObject, eventdata, handles);
commRTHistogram_Callback(hObject, eventdata, handles);
guidata(hObject,handles);


% --- Executes on button press in selectLEDsEnable2. -- NOTE: this button
% is unavailable to click during preview mode (and of course capture mode)
function selectLEDsEnable2_Callback(hObject, eventdata, handles)
% If we were just in capture mode with different LEDs selected, then fix
% this before enabling anything here
if handles.settingsStruct.justFinishedCap == 1
    handles.settingsStruct.justFinishedCap = 0; % Important to disable this flag here or else it will go into a never-ending loop
    if handles.prevLEDsToEnable(1) ~= handles.capLEDsToEnable(1)
        % Force preview state for this button
        set(handles.selectLEDsEnable1,'Value',handles.prevLEDsToEnable(1));
        % Run callback for this LED's button & update handles
        selectLEDsEnable1_Callback(hObject, eventdata, handles);handles = guidata(hObject);
    end
    if handles.prevLEDsToEnable(2) ~= handles.capLEDsToEnable(2)
        % Get previous state
        previousState = get(handles.selectLEDsEnable2,'Value');
        % Force preview state for this button
        set(handles.selectLEDsEnable2,'Value',handles.prevLEDsToEnable(2));
        % Run callback for this LED's button & update handles
        selectLEDsEnable2_Callback(hObject, eventdata, handles);handles = guidata(hObject);
        % Reset Value to previous state-so the rest of the callback can do
        % its thing
        set(handles.selectLEDsEnable2,'Value',previousState);
    end
    if handles.prevLEDsToEnable(3) ~= handles.capLEDsToEnable(3)
        % Force preview state for this button
        set(handles.selectLEDsEnable3,'Value',handles.prevLEDsToEnable(3));
        % Run callback for this LED's button & update handles
        selectLEDsEnable3_Callback(hObject, eventdata, handles);handles = guidata(hObject);
    end
    if handles.prevLEDsToEnable(4) ~= handles.capLEDsToEnable(4)
        % Force preview state for this button
        set(handles.selectLEDsEnable4,'Value',handles.prevLEDsToEnable(4));
        % Run callback for this LED's button & update handles
        selectLEDsEnable4_Callback(hObject, eventdata, handles);handles = guidata(hObject);
    end
end
if (sum(handles.LEDsToEnable,2) == 1) && (get(handles.selectLEDsEnable2,'value') == 0)
    disp('Error: You may not disable all LEDs.')
    set(handles.selectLEDsEnable2,'value',1);
    return
end
if (get(handles.selectLEDsEnable2,'Value') == 0) && (handles.settingsStruct.selectLEDsShow == 2)
     % if we de-selected this LED, but the show LED on big axis is supposed
    % to show this LED, fix it, and put the right data on the big axis
    % RELEVANT FOR 4->3 LED CHANNELS
    if sum(handles.LEDsToEnable,2) == 4
        if handles.LEDsToEnable(1) == 1
            set(handles.selectLEDsShow,'Value',1);
            handles.settingsStruct.selectLEDsShow = 1;
            newFrameData = get(handles.imgHandLEDQuad1,'CData');
            newLims = get(handles.LEDQuad1Ax,'CLim');
        elseif handles.LEDsToEnable(3) == 1
            set(handles.selectLEDsShow,'Value',3);
            handles.settingsStruct.selectLEDsShow = 3;
            newFrameData = get(handles.imgHandLEDQuad3,'CData');
            newLims = get(handles.LEDQuad3Ax,'CLim');
        elseif handles.LEDsToEnable(4) == 1
            set(handles.selectLEDsShow,'Value',4);
            handles.settingsStruct.selectLEDsShow = 4;
            newFrameData = get(handles.imgHandLEDQuad4,'CData');
            newLims = get(handles.LEDQuad4Ax,'CLim');
        end
        set(handles.imgHandLED1,'CData',newFrameData);
        set(handles.LEDQuad1Ax,'CLim',newLims);
        handles.settingsStruct.blackLevelLED1= newLims(1);
        handles.settingsStruct.whiteLevelLED1 = newLims(2);
        set(handles.LED1BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLED1))]);
        set(handles.LED1WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLED1))]);
    else
        if handles.LEDsToEnable(1) == 1
            set(handles.selectLEDsShow,'Value',1);
            handles.settingsStruct.selectLEDsShow = 1;
        elseif handles.LEDsToEnable(3) == 1
            set(handles.selectLEDsShow,'Value',3);
            handles.settingsStruct.selectLEDsShow = 3;
        elseif handles.LEDsToEnable(4) == 1
            set(handles.selectLEDsShow,'Value',4);
            handles.settingsStruct.selectLEDsShow = 4;
        end 
    end
end
% Determine if quad view was enabled before changing LEDs
prevQuad = handles.settingsStruct.selectLEDsQuadViewOn;
% Save the new setting for this LED
handles.settingsStruct.selectLEDsEnable2 = get(handles.selectLEDsEnable2,'value');
prevLEDsToEnable = handles.LEDsToEnable; % for switching image data around
handles.LEDsToEnable(2) = handles.settingsStruct.selectLEDsEnable2;
if handles.settingsStruct.inCapMode == 0
    handles.settingsStruct.prevLEDsEnable2 = handles.settingsStruct.selectLEDsEnable2;
    handles.prevLEDsToEnable(2) = handles.settingsStruct.selectLEDsEnable2;
    % If the capture mode LED choices are locked to preview mode, then
    % switch capture mode settings, gui values
    if handles.settingsStruct.selectLEDsLockCap == 1
        handles.settingsStruct.capLEDsEnable2 = handles.settingsStruct.selectLEDsEnable2;
        handles.capLEDsToEnable(2) = handles.prevLEDsToEnable(2);
        set(handles.capLEDsEnable2,'Value',handles.settingsStruct.capLEDsEnable2);
    end
end
% Confirm (on command line) the LED change made
if handles.settingsStruct.selectLEDsEnable2== 1
    disp([handles.settingsStruct.constLED2CenterWavelength ' LED turned ON.']);
else
    disp([handles.settingsStruct.constLED2CenterWavelength ' LED turned OFF.']);
end

% Turn on quad-view setting/change the quad view enable mode
if sum(handles.LEDsToEnable,2) > 2
    handles.settingsStruct.selectLEDsQuadViewOn = 1;
else
    handles.settingsStruct.selectLEDsQuadViewOn = 0;
end

% Determine which image axes to show/hide
if handles.settingsStruct.selectLEDsQuadViewOn == 1
    if prevQuad == 0
        disp('Turning quad-channel view mode on')
        % We have crossed the threshold and need to switch some axes to
        % enable the quad-channel view
        handles.imgHandLED2.Visible = 'off';
        handles.LED1DisplayedValues.Visible = 'off';
        handles.LED1BlackValueIndicator.Visible = 'off';
        handles.LED1WhiteValueIndicator.Visible = 'off';
        handles.LED2DisplayedValues.Visible = 'off';
        handles.LED2BlackValueIndicator.Visible = 'off';
        handles.LED2WhiteValueIndicator.Visible = 'off';
        
        % Variable for switching frames
        switchFrames=ones(size(handles.imageMask,1),size(handles.imageMask,2),2,'uint16');
        switchCLim=zeros(2,2);
        switchFrames(:,:,1) = get(handles.imgHandLED1,'CData'); 
        switchFrames(:,:,2) = get(handles.imgHandLED2,'CData');
        switchCLim(:,1) = get(handles.LED1Ax,'CLim');
        switchCLim(:,2) = get(handles.LED2Ax,'CLim');
        quadIdx = 1;
        
        if handles.LEDsToEnable(1) == 1
            handles.imgHandLEDQuad1.Visible = 'on';
            handles.LEDQuad1DisplayedValues.Visible = 'on';
            handles.LEDQuad1BlackValueIndicator.Visible = 'on';
        	handles.LEDQuad1WhiteValueIndicator.Visible = 'on';
            if prevLEDsToEnable(1) == 1
                set(handles.imgHandLEDQuad1,'CData',switchFrames(:,:,quadIdx));
                set(handles.LEDQuad1Ax,'CLim',switchCLim(:,quadIdx));
                handles.settingsStruct.blackLevelLEDQuad1= switchCLim(1,quadIdx);
                handles.settingsStruct.whiteLevelLEDQuad1 = switchCLim(2,quadIdx);
                set(handles.LEDQuad1BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLEDQuad1))]);
                set(handles.LEDQuad1WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLEDQuad1))]);
                quadIdx = quadIdx + 1;
            end
        end
        
        %If we have transitions from quad off to on, then we MUST have enabled this channel
        handles.imgHandLEDQuad2.Visible = 'on'; 
        handles.LEDQuad2DisplayedValues.Visible = 'on';
        handles.LEDQuad2BlackValueIndicator.Visible = 'on';
        handles.LEDQuad2WhiteValueIndicator.Visible = 'on';
        % Also blank this frame axis (in case there is old imagery)
        set(handles.imgHandLEDQuad2,'CData',ones(size(handles.imageMask,1),'uint16'));
        blankLims = [0, (2^(handles.settingsStruct.constCameraBits)-1)];
        set(handles.LEDQuad2Ax,'CLim',blankLims);
        handles.settingsStruct.blackLevelLEDQuad2= blankLims(1);
        handles.settingsStruct.whiteLevelLEDQuad2 = blankLims(2);
        set(handles.LEDQuad2BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLEDQuad2))]);
        set(handles.LEDQuad2WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLEDQuad2))]);

        if handles.LEDsToEnable(3) == 1
            handles.imgHandLEDQuad3.Visible = 'on';
            handles.LEDQuad3DisplayedValues.Visible = 'on';
            handles.LEDQuad3BlackValueIndicator.Visible = 'on';
            handles.LEDQuad3WhiteValueIndicator.Visible = 'on';
            if prevLEDsToEnable(3) == 1
                set(handles.imgHandLEDQuad3,'CData',switchFrames(:,:,quadIdx));
                set(handles.LEDQuad3Ax,'CLim',switchCLim(:,quadIdx));
                handles.settingsStruct.blackLevelLEDQuad3= switchCLim(1,quadIdx);
                handles.settingsStruct.whiteLevelLEDQuad3 = switchCLim(2,quadIdx);
                set(handles.LEDQuad3BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLEDQuad3))]);
                set(handles.LEDQuad3WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLEDQuad3))]);
                quadIdx = quadIdx + 1;
            end
        end
        if handles.LEDsToEnable(4) == 1
            handles.imgHandLEDQuad4.Visible = 'on';
            handles.LEDQuad4DisplayedValues.Visible = 'on';
            handles.LEDQuad4BlackValueIndicator.Visible = 'on';
            handles.LEDQuad4WhiteValueIndicator.Visible = 'on';
            if prevLEDsToEnable(4) == 1
                set(handles.imgHandLEDQuad4,'CData',switchFrames(:,:,quadIdx));
                set(handles.LEDQuad4Ax,'CLim',switchCLim(:,quadIdx));
                handles.settingsStruct.blackLevelLEDQuad4= switchCLim(1,quadIdx);
                handles.settingsStruct.whiteLevelLEDQuad4 = switchCLim(2,quadIdx);
                set(handles.LEDQuad4BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLEDQuad4))]);
                set(handles.LEDQuad4WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLEDQuad4))]);
            end
        end
    else
        % If we were in quad mode and we still are, then there are two possibilities
        if handles.settingsStruct.selectLEDsEnable2 == 1
            handles.imgHandLEDQuad2.Visible = 'on';
            handles.LEDQuad2DisplayedValues.Visible = 'on';
            handles.LEDQuad2BlackValueIndicator.Visible = 'on';
            handles.LEDQuad2WhiteValueIndicator.Visible = 'on';
            set(handles.imgHandLEDQuad2,'CData',ones(size(handles.imageMask,1),'uint16')); % show blank frame
            blankLims = [0, (2^(handles.settingsStruct.constCameraBits)-1)];
            set(handles.LEDQuad2Ax,'CLim',blankLims);
            handles.settingsStruct.blackLevelLEDQuad2= blankLims(1);
            handles.settingsStruct.whiteLevelLEDQuad2 = blankLims(2);
            set(handles.LEDQuad2BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLEDQuad2))]);
            set(handles.LEDQuad2WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLEDQuad2))]);
        else
            handles.imgHandLEDQuad2.Visible = 'off';
            handles.LEDQuad2DisplayedValues.Visible = 'off';
            handles.LEDQuad2BlackValueIndicator.Visible = 'off';
            handles.LEDQuad2WhiteValueIndicator.Visible = 'off';
        end
    end
else % now we are NOT in quad mode
    if prevQuad == 1 % but if we just were in quad mode, then make sure to hide all those axis
        disp('Turning quad-channel view mode off')
        handles.imgHandLED2.Visible = 'on';
        handles.LED1DisplayedValues.Visible = 'on';
        handles.LED1BlackValueIndicator.Visible = 'on';
        handles.LED1WhiteValueIndicator.Visible = 'on';
        handles.LED2DisplayedValues.Visible = 'on';
        handles.LED2BlackValueIndicator.Visible = 'on';
        handles.LED2WhiteValueIndicator.Visible = 'on';
        handles.imgHandLEDQuad1.Visible = 'off';
        handles.imgHandLEDQuad2.Visible = 'off';
        handles.imgHandLEDQuad3.Visible = 'off';
        handles.imgHandLEDQuad4.Visible = 'off';
        handles.LEDQuad1DisplayedValues.Visible = 'off';
        handles.LEDQuad1BlackValueIndicator.Visible = 'off';
        handles.LEDQuad1WhiteValueIndicator.Visible = 'off';
        handles.LEDQuad2DisplayedValues.Visible = 'off';
        handles.LEDQuad2BlackValueIndicator.Visible = 'off';
        handles.LEDQuad2WhiteValueIndicator.Visible = 'off';
        handles.LEDQuad3DisplayedValues.Visible = 'off';
        handles.LEDQuad3BlackValueIndicator.Visible = 'off';
        handles.LEDQuad3WhiteValueIndicator.Visible = 'off';
        handles.LEDQuad4DisplayedValues.Visible = 'off';
        handles.LEDQuad4BlackValueIndicator.Visible = 'off';
        handles.LEDQuad4WhiteValueIndicator.Visible = 'off';
        % Determine which frames to put where--use LEDsToEnable to
        % determine which frame data to add to 2-image axes
        switchFrames=ones(size(handles.imageMask,1),size(handles.imageMask,2),2,'uint16');
        switchCLim = zeros(2,2);
        quadIdx = 1;
        if handles.LEDsToEnable(1) == 1
            switchFrames(:,:,quadIdx) = get(handles.imgHandLEDQuad1,'CData');
            switchCLim(:,quadIdx) = get(handles.LEDQuad1Ax,'CLim');
            quadIdx = quadIdx+1;
        end
        if handles.LEDsToEnable(3) == 1
            switchFrames(:,:,quadIdx) = get(handles.imgHandLEDQuad3,'CData');
            switchCLim(:,quadIdx) = get(handles.LEDQuad3Ax,'CLim');
            quadIdx = quadIdx+1;
        end
        if handles.LEDsToEnable(4) == 1
            switchFrames(:,:,quadIdx) = get(handles.imgHandLEDQuad4,'CData');
            switchCLim(:,quadIdx) = get(handles.LEDQuad4Ax,'CLim');
        end
        set(handles.imgHandLED1,'CData',switchFrames(:,:,1));
        set(handles.imgHandLED2,'CData',switchFrames(:,:,2));
        set(handles.LED1Ax,'CLim',switchCLim(:,1));
        set(handles.LED2Ax,'CLim',switchCLim(:,2));
        handles.settingsStruct.blackLevelLED1= switchCLim(1,1);
        handles.settingsStruct.whiteLevelLED1 = switchCLim(2,1);
        set(handles.LED1BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLED1))]);
        set(handles.LED1WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLED1))]);
        handles.settingsStruct.blackLevelLED2= switchCLim(1,2);
        handles.settingsStruct.whiteLevelLED2 = switchCLim(2,2);
        set(handles.LED2BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLED2))]);
        set(handles.LED2WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLED2))]);
        
    else % if we were not in quad mode and are still not in quad mode
        if handles.settingsStruct.selectLEDsEnable2 == 1
            handles.imgHandLED2.Visible = 'on';
            handles.LED2DisplayedValues.Visible = 'on';
            handles.LED2BlackValueIndicator.Visible = 'on';
            handles.LED2WhiteValueIndicator.Visible = 'on';
            set(handles.imgHandLED2,'CData',ones(size(handles.imageMask,1),'uint16')); % blank the second axis
            blankLims = [0, (2^(handles.settingsStruct.constCameraBits)-1)];
            set(handles.LED2Ax,'CLim',blankLims);
            handles.settingsStruct.blackLevelLED2= blankLims(1);
            handles.settingsStruct.whiteLevelLED2 = blankLims(2);
            set(handles.LED2BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLED2))]);
            set(handles.LED2WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLED2))]);
        else
            handles.imgHandLED2.Visible = 'off';
            handles.LED2DisplayedValues.Visible = 'off';
            handles.LED2BlackValueIndicator.Visible = 'off';
            handles.LED2WhiteValueIndicator.Visible = 'off';
            % Transfer image data from one frame to the other, if necessary
            countVect = 1:4;
            if 2 < countVect(logical(handles.LEDsToEnable))
                swapFrame = get(handles.imgHandLED2,'CData');
                swapCLim = get(handles.LED2Ax,'CLim');
                set(handles.imgHandLED1,'CData',swapFrame);
                set(handles.LED1Ax,'CLim',swapCLim);
                handles.settingsStruct.blackLevelLED1= swapCLim(1);
                handles.settingsStruct.whiteLevelLED1 = swapCLim(2);
                set(handles.LED1BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLED1))]);
                set(handles.LED1WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLED1))]);
            end
        end
    end
end

% Switch RT Histograms and RT Stats on/off
commRTStats_Callback(hObject, eventdata, handles);
commRTHistogram_Callback(hObject, eventdata, handles);
guidata(hObject,handles);


% --- Executes on button press in selectLEDsEnable3.
function selectLEDsEnable3_Callback(hObject, eventdata, handles)
% If we were just in capture mode with different LEDs selected, then fix
% this before enabling anything here
if handles.settingsStruct.justFinishedCap == 1
    handles.settingsStruct.justFinishedCap = 0; % Important to disable this flag here or else it will go into a never-ending loop
    if handles.prevLEDsToEnable(1) ~= handles.capLEDsToEnable(1)
        % Force preview state for this button
        set(handles.selectLEDsEnable1,'Value',handles.prevLEDsToEnable(1));
        % Run callback for this LED's button & update handles
        selectLEDsEnable1_Callback(hObject, eventdata, handles);handles = guidata(hObject);
    end
    if handles.prevLEDsToEnable(2) ~= handles.capLEDsToEnable(2)
        % Force preview state for this button
        set(handles.selectLEDsEnable2,'Value',handles.prevLEDsToEnable(2));
        % Run callback for this LED's button & update handles
        selectLEDsEnable2_Callback(hObject, eventdata, handles);handles = guidata(hObject);
    end
    if handles.prevLEDsToEnable(3) ~= handles.capLEDsToEnable(3)
        % Get previous state
        previousState = get(handles.selectLEDsEnable3,'Value');
        % Force preview state for this button
        set(handles.selectLEDsEnable3,'Value',handles.prevLEDsToEnable(3));
        % Run callback for this LED's button & update handles
        selectLEDsEnable3_Callback(hObject, eventdata, handles);handles = guidata(hObject);
        % Reset Value to previous state-so the rest of the callback can do
        % its thing
        set(handles.selectLEDsEnable3,'Value',previousState);
    end
    if handles.prevLEDsToEnable(4) ~= handles.capLEDsToEnable(4)
        % Force preview state for this button
        set(handles.selectLEDsEnable4,'Value',handles.prevLEDsToEnable(4));
        % Run callback for this LED's button & update handles
        selectLEDsEnable4_Callback(hObject, eventdata, handles);handles = guidata(hObject);
    end
end
if (sum(handles.LEDsToEnable,2) == 1) && (get(handles.selectLEDsEnable3,'value') == 0)
    disp('Error: you cannot disable all LEDs.')
    set(handles.selectLEDsEnable3,'value',1);
    return
end
if (get(handles.selectLEDsEnable3,'Value') == 0) && (handles.settingsStruct.selectLEDsShow == 3)
    % if we de-selected this LED, but the show LED on big axis is supposed
    % to show this LED, fix it, and put the right data on the big axis
    % RELEVANT FOR 4->3 LED CHANNELS
    if sum(handles.LEDsToEnable,2) == 4 % if the sum here is 4 (was 4 before clicking), then we must have deselected this LED
        if handles.LEDsToEnable(1) == 1
            set(handles.selectLEDsShow,'Value',1);
            handles.settingsStruct.selectLEDsShow = 1;
            newFrameData = get(handles.imgHandLEDQuad1,'CData');
            newLims = get(handles.LEDQuad1Ax,'CLim');
        elseif handles.LEDsToEnable(2) == 1
            set(handles.selectLEDsShow,'Value',2);
            handles.settingsStruct.selectLEDsShow = 2;
            newFrameData = get(handles.imgHandLEDQuad2,'CData');
            newLims = get(handles.LEDQuad2Ax,'CLim');
        elseif handles.LEDsToEnable(4) == 1
            set(handles.selectLEDsShow,'Value',4);
            handles.settingsStruct.selectLEDsShow = 4;
            newFrameData = get(handles.imgHandLEDQuad4,'CData');
            newLims = get(handles.LEDQuad4Ax,'CLim');
        end
        set(handles.imgHandLED1,'CData',newFrameData);
        set(handles.LED1Ax,'CLim',newLims);
        handles.settingsStruct.blackLevelLED1= newLims(1);
        handles.settingsStruct.whiteLevelLED1 = newLims(2);
        set(handles.LED1BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLED1))]);
        set(handles.LED1WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLED1))]);
    else
        if handles.LEDsToEnable(1) == 1 % and these 3 options just change the selected LED to show on big axis (but nothing changes)
            set(handles.selectLEDsShow,'Value',1);
            handles.settingsStruct.selectLEDsShow = 1;
        elseif handles.LEDsToEnable(2) == 1
            set(handles.selectLEDsShow,'Value',2);
            handles.settingsStruct.selectLEDsShow = 2;
        elseif handles.LEDsToEnable(4) == 1
            set(handles.selectLEDsShow,'Value',4);
            handles.settingsStruct.selectLEDsShow = 4;
        end 
    end
end

% Determine if quad view was enabled before changing LEDs
prevQuad = handles.settingsStruct.selectLEDsQuadViewOn;
% Save the new setting for this LED
handles.settingsStruct.selectLEDsEnable3 = get(handles.selectLEDsEnable3,'value');
prevLEDsToEnable = handles.LEDsToEnable; % for switching image data around
handles.LEDsToEnable(3) = handles.settingsStruct.selectLEDsEnable3;
if handles.settingsStruct.inCapMode == 0
    handles.settingsStruct.prevLEDsEnable3 = handles.settingsStruct.selectLEDsEnable3;
    handles.prevLEDsToEnable(3) = handles.settingsStruct.selectLEDsEnable3;
    % If the capture mode LED choices are locked to preview mode, then
    % switch capture mode settings, gui values
    if handles.settingsStruct.selectLEDsLockCap == 1
        handles.settingsStruct.capLEDsEnable3 = handles.settingsStruct.selectLEDsEnable3;
        handles.capLEDsToEnable(3) = handles.prevLEDsToEnable(3);
        set(handles.capLEDsEnable3,'Value',handles.settingsStruct.capLEDsEnable3);
    end
end
% Confirm (on command line) the LED change made
if handles.settingsStruct.selectLEDsEnable3 == 1
    disp([handles.settingsStruct.constLED3CenterWavelength ' LED turned ON.']);
else
    disp([handles.settingsStruct.constLED3CenterWavelength ' LED turned OFF.']);
end

% Turn on quad-view setting/change the quad view enable mode
if sum(handles.LEDsToEnable,2) > 2
    handles.settingsStruct.selectLEDsQuadViewOn = 1;
else
    handles.settingsStruct.selectLEDsQuadViewOn = 0;
end

% Determine which image axes to show/hide
if handles.settingsStruct.selectLEDsQuadViewOn == 1
    if prevQuad == 0
        disp('Turning quad-channel view mode on')
        % We have crossed the threshold and need to switch some axes to
        % enable the quad-channel view
        handles.imgHandLED2.Visible = 'off';
        handles.LED1DisplayedValues.Visible = 'off';
        handles.LED1BlackValueIndicator.Visible = 'off';
        handles.LED1WhiteValueIndicator.Visible = 'off';
        handles.LED2DisplayedValues.Visible = 'off';
        handles.LED2BlackValueIndicator.Visible = 'off';
        handles.LED2WhiteValueIndicator.Visible = 'off';
        
        % Variable for switching frames
        switchFrames=ones(size(handles.imageMask,1),size(handles.imageMask,2),2,'uint16');
        switchCLim=zeros(2,2);
        switchFrames(:,:,1) = get(handles.imgHandLED1,'CData'); 
        switchFrames(:,:,2) = get(handles.imgHandLED2,'CData');
        switchCLim(:,1) = get(handles.LED1Ax,'CLim');
        switchCLim(:,2) = get(handles.LED2Ax,'CLim');
        quadIdx = 1;
        
        if handles.LEDsToEnable(1) == 1
            handles.imgHandLEDQuad1.Visible = 'on';
            handles.LEDQuad1DisplayedValues.Visible = 'on';
            handles.LEDQuad1BlackValueIndicator.Visible = 'on';
        	handles.LEDQuad1WhiteValueIndicator.Visible = 'on';
            if prevLEDsToEnable(1) == 1
                set(handles.imgHandLEDQuad1,'CData',switchFrames(:,:,quadIdx));
                set(handles.LEDQuad1Ax,'CLim',switchCLim(:,quadIdx));
                handles.settingsStruct.blackLevelLEDQuad1= switchCLim(1,quadIdx);
                handles.settingsStruct.whiteLevelLEDQuad1 = switchCLim(2,quadIdx);
                set(handles.LEDQuad1BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLEDQuad1))]);
                set(handles.LEDQuad1WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLEDQuad1))]);
                quadIdx = quadIdx + 1;
            end
        end
        if handles.LEDsToEnable(2) == 1
            handles.imgHandLEDQuad2.Visible = 'on';
            handles.LEDQuad2DisplayedValues.Visible = 'on';
            handles.LEDQuad2BlackValueIndicator.Visible = 'on';
            handles.LEDQuad2WhiteValueIndicator.Visible = 'on';
            if prevLEDsToEnable(2) == 1
                set(handles.imgHandLEDQuad2,'CData',switchFrames(:,:,quadIdx));
                set(handles.LEDQuad2Ax,'CLim',switchCLim(:,quadIdx));
                handles.settingsStruct.blackLevelLEDQuad2= switchCLim(1,quadIdx);
                handles.settingsStruct.whiteLevelLEDQuad2 = switchCLim(2,quadIdx);
                set(handles.LEDQuad2BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLEDQuad2))]);
                set(handles.LEDQuad2WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLEDQuad2))]);
                quadIdx = quadIdx + 1;
            end
        end
        
        %If we have transitions from quad off to on, then we MUST have enabled this channel
        handles.imgHandLEDQuad3.Visible = 'on'; 
        handles.LEDQuad3DisplayedValues.Visible = 'on';
        handles.LEDQuad3BlackValueIndicator.Visible = 'on';
        handles.LEDQuad3WhiteValueIndicator.Visible = 'on';
        % Also blank this frame axis (in case there is old imagery)
        set(handles.imgHandLEDQuad3,'CData',ones(size(handles.imageMask,1),'uint16'));
        blankLims = [0, (2^(handles.settingsStruct.constCameraBits)-1)];
        set(handles.LEDQuad3Ax,'CLim',blankLims);
        handles.settingsStruct.blackLevelLEDQuad3= blankLims(1);
        handles.settingsStruct.whiteLevelLEDQuad3 = blankLims(2);
        set(handles.LEDQuad3BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLEDQuad3))]);
        set(handles.LEDQuad3WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLEDQuad3))]);

        if handles.LEDsToEnable(4) == 1
            handles.imgHandLEDQuad4.Visible = 'on';
            handles.LEDQuad4DisplayedValues.Visible = 'on';
            handles.LEDQuad4BlackValueIndicator.Visible = 'on';
            handles.LEDQuad4WhiteValueIndicator.Visible = 'on';
            if prevLEDsToEnable(4) == 1
                set(handles.imgHandLEDQuad4,'CData',switchFrames(:,:,quadIdx));
                set(handles.LEDQuad4Ax,'CLim',switchCLim(:,quadIdx));
                handles.settingsStruct.blackLevelLEDQuad4= switchCLim(1,quadIdx);
                handles.settingsStruct.whiteLevelLEDQuad4 = switchCLim(2,quadIdx);
                set(handles.LEDQuad4BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLEDQuad4))]);
                set(handles.LEDQuad4WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLEDQuad4))]);
            end
        end
    else
        % If we were in quad mode and we still are, then there are two possibilities
        if handles.settingsStruct.selectLEDsEnable3 == 1
            handles.imgHandLEDQuad3.Visible = 'on';
            handles.LEDQuad3DisplayedValues.Visible = 'on';
            handles.LEDQuad3BlackValueIndicator.Visible = 'on';
            handles.LEDQuad3WhiteValueIndicator.Visible = 'on';
            set(handles.imgHandLEDQuad3,'CData',ones(size(handles.imageMask,1),'uint16')); % show blank frame
            blankLims = [0, (2^(handles.settingsStruct.constCameraBits)-1)];
            set(handles.LEDQuad3Ax,'CLim',blankLims);
            handles.settingsStruct.blackLevelLEDQuad3= blankLims(1);
            handles.settingsStruct.whiteLevelLEDQuad3 = blankLims(2);
            set(handles.LEDQuad3BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLEDQuad3))]);
            set(handles.LEDQuad3WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLEDQuad3))]);
        else
            handles.imgHandLEDQuad3.Visible = 'off';
            handles.LEDQuad3DisplayedValues.Visible = 'off';
            handles.LEDQuad3BlackValueIndicator.Visible = 'off';
            handles.LEDQuad3WhiteValueIndicator.Visible = 'off';
        end
    end
else % now we are NOT in quad mode
    if prevQuad == 1 % but if we just were in quad mode, then make sure to hide all those axis
        disp('Turning quad-channel view mode off')
        handles.imgHandLED2.Visible = 'on';
        handles.LED1DisplayedValues.Visible = 'on';
        handles.LED1BlackValueIndicator.Visible = 'on';
        handles.LED1WhiteValueIndicator.Visible = 'on';
        handles.LED2DisplayedValues.Visible = 'on';
        handles.LED2BlackValueIndicator.Visible = 'on';
        handles.LED2WhiteValueIndicator.Visible = 'on';
        handles.imgHandLEDQuad1.Visible = 'off';
        handles.imgHandLEDQuad2.Visible = 'off';
        handles.imgHandLEDQuad3.Visible = 'off';
        handles.imgHandLEDQuad4.Visible = 'off';
        handles.LEDQuad1DisplayedValues.Visible = 'off';
        handles.LEDQuad1BlackValueIndicator.Visible = 'off';
        handles.LEDQuad1WhiteValueIndicator.Visible = 'off';
        handles.LEDQuad2DisplayedValues.Visible = 'off';
        handles.LEDQuad2BlackValueIndicator.Visible = 'off';
        handles.LEDQuad2WhiteValueIndicator.Visible = 'off';
        handles.LEDQuad3DisplayedValues.Visible = 'off';
        handles.LEDQuad3BlackValueIndicator.Visible = 'off';
        handles.LEDQuad3WhiteValueIndicator.Visible = 'off';
        handles.LEDQuad4DisplayedValues.Visible = 'off';
        handles.LEDQuad4BlackValueIndicator.Visible = 'off';
        handles.LEDQuad4WhiteValueIndicator.Visible = 'off';
        % Determine which frames to put where--use LEDsToEnable to
        % determine which frame data to add to 2-image axes
        switchFrames=ones(size(handles.imageMask,1),size(handles.imageMask,2),2,'uint16');
        switchCLim = zeros(2,2);
        quadIdx = 1;
        if handles.LEDsToEnable(1) == 1
            switchFrames(:,:,quadIdx) = get(handles.imgHandLEDQuad1,'CData');
            switchCLim(:,quadIdx) = get(handles.LEDQuad1Ax,'CLim');
            quadIdx = quadIdx+1;
        end
        if handles.LEDsToEnable(2) == 1
            switchFrames(:,:,quadIdx) = get(handles.imgHandLEDQuad2,'CData');
            switchCLim(:,quadIdx) = get(handles.LEDQuad2Ax,'CLim');
            quadIdx = quadIdx+1;
        end
        if handles.LEDsToEnable(4) == 1
            switchFrames(:,:,quadIdx) = get(handles.imgHandLEDQuad4,'CData');
            switchCLim(:,quadIdx) = get(handles.LEDQuad4Ax,'CLim');
        end
        set(handles.imgHandLED1,'CData',switchFrames(:,:,1));
        set(handles.imgHandLED2,'CData',switchFrames(:,:,2));
        set(handles.LED1Ax,'CLim',switchCLim(:,1));
        set(handles.LED2Ax,'CLim',switchCLim(:,2));
        handles.settingsStruct.blackLevelLED1= switchCLim(1,1);
        handles.settingsStruct.whiteLevelLED1 = switchCLim(2,1);
        set(handles.LED1BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLED1))]);
        set(handles.LED1WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLED1))]);
        handles.settingsStruct.blackLevelLED2= switchCLim(1,2);
        handles.settingsStruct.whiteLevelLED2 = switchCLim(2,2);
        set(handles.LED2BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLED2))]);
        set(handles.LED2WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLED2))]);

    else % if we were not in quad mode and are still not in quad mode
        if handles.settingsStruct.selectLEDsEnable3 == 1
            handles.imgHandLED2.Visible = 'on';
            handles.LED2DisplayedValues.Visible = 'on';
            handles.LED2BlackValueIndicator.Visible = 'on';
            handles.LED2WhiteValueIndicator.Visible = 'on';
            set(handles.imgHandLED2,'CData',ones(size(handles.imageMask,1),'uint16')); % blank the second axis
            blankLims = [0, (2^(handles.settingsStruct.constCameraBits)-1)];
            set(handles.LED2Ax,'CLim',blankLims);
            handles.settingsStruct.blackLevelLED2= blankLims(1);
            handles.settingsStruct.whiteLevelLED2 = blankLims(2);
            set(handles.LED2BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLED2))]);
            set(handles.LED2WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLED2))]);
        else
            handles.imgHandLED2.Visible = 'off';
            handles.LED2DisplayedValues.Visible = 'off';
            handles.LED2BlackValueIndicator.Visible = 'off';
            handles.LED2WhiteValueIndicator.Visible = 'off';
            % Transfer image data from one frame to the other, if necessary
            countVect = 1:4;
            if 3 < countVect(logical(handles.LEDsToEnable))
                swapFrame = get(handles.imgHandLED2,'CData');
                swapCLim = get(handles.LED2Ax,'CLim');
                set(handles.imgHandLED1,'CData',swapFrame);
                set(handles.LED1Ax,'CLim',swapCLim);
                handles.settingsStruct.blackLevelLED1= swapCLim(1);
                handles.settingsStruct.whiteLevelLED1 = swapCLim(2);
                set(handles.LED1BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLED1))]);
                set(handles.LED1WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLED1))]);
            end
        end
    end
end

% Switch RT Histograms and RT Stats on/off
commRTStats_Callback(hObject, eventdata, handles);
commRTHistogram_Callback(hObject, eventdata, handles);
guidata(hObject,handles);


% --- Executes on button press in selectLEDsEnable4.
function selectLEDsEnable4_Callback(hObject, eventdata, handles)
% If we were just in capture mode with different LEDs selected, then fix
% this before enabling anything here
if handles.settingsStruct.justFinishedCap == 1
    handles.settingsStruct.justFinishedCap = 0; % Important to disable this flag here or else it will go into a never-ending loop
    if handles.prevLEDsToEnable(1) ~= handles.capLEDsToEnable(1)
        % Force preview state for this button
        set(handles.selectLEDsEnable1,'Value',handles.prevLEDsToEnable(1));
        % Run callback for this LED's button & update handles
        selectLEDsEnable1_Callback(hObject, eventdata, handles);handles = guidata(hObject);
    end
    if handles.prevLEDsToEnable(2) ~= handles.capLEDsToEnable(2)
        % Force preview state for this button
        set(handles.selectLEDsEnable2,'Value',handles.prevLEDsToEnable(2));
        % Run callback for this LED's button & update handles
        selectLEDsEnable2_Callback(hObject, eventdata, handles);handles = guidata(hObject);
    end
    if handles.prevLEDsToEnable(3) ~= handles.capLEDsToEnable(3)
        % Force preview state for this button
        set(handles.selectLEDsEnable3,'Value',handles.prevLEDsToEnable(3));
        % Run callback for this LED's button & update handles
        selectLEDsEnable3_Callback(hObject, eventdata, handles);handles = guidata(hObject);
    end
    if handles.prevLEDsToEnable(4) ~= handles.capLEDsToEnable(4)
        % Get previous state
        previousState = get(handles.selectLEDsEnable4,'Value');
        % Force preview state for this button
        set(handles.selectLEDsEnable4,'Value',handles.prevLEDsToEnable(4));
        % Run callback for this LED's button & update handles
        selectLEDsEnable4_Callback(hObject, eventdata, handles);handles = guidata(hObject);
        % Reset Value to previous state-so the rest of the callback can do
        % its thing
        set(handles.selectLEDsEnable4,'Value',previousState);
    end
end
% Determine whether <1 LED is trying to be set
if (sum(handles.LEDsToEnable,2) == 1) && (get(handles.selectLEDsEnable4,'value') == 0)
    disp('Error: you cannot disable all LEDs.')
    set(handles.selectLEDsEnable4,'value',1);
    return
end
if (get(handles.selectLEDsEnable4,'Value') == 0) && (handles.settingsStruct.selectLEDsShow == 4)
    % if we de-selected this LED, but the show LED on big axis is supposed
    % to show this LED, fix it, and put the right data on the big axis
    % RELEVANT FOR 4->3 LED CHANNELS
    if sum(handles.LEDsToEnable,2) == 4
        if handles.LEDsToEnable(1) == 1 % if the sum here is 4 (was 4 before clicking), then we must have deselected this LED
            set(handles.selectLEDsShow,'Value',1);
            handles.settingsStruct.selectLEDsShow = 1;
            newFrameData = get(handles.imgHandLEDQuad1,'CData');
            newLims = get(handles.LEDQuad1Ax,'CLim');
        elseif handles.LEDsToEnable(2) == 1
            set(handles.selectLEDsShow,'Value',2);
            handles.settingsStruct.selectLEDsShow = 2;
            newFrameData = get(handles.imgHandLEDQuad2,'CData');
            newLims = get(handles.LEDQuad2Ax,'CLim');
        elseif handles.LEDsToEnable(3) == 1
            set(handles.selectLEDsShow,'Value',3);
            handles.settingsStruct.selectLEDsShow = 3;
            newFrameData = get(handles.imgHandLEDQuad3,'CData');
            newLims = get(handles.LEDQuad3Ax,'CLim');
        end
        set(handles.imgHandLED1,'CData',newFrameData);
        set(handles.LED1Ax,'CLim',newLims);
        handles.settingsStruct.blackLevelLED1= newLims(1);
        handles.settingsStruct.whiteLevelLED1 = newLims(2);
        set(handles.LED1BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLED1))]);
        set(handles.LED1WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLED1))]);
    else
        if handles.LEDsToEnable(1) == 1 % and these 3 options just change the selected LED to show on big axis (but nothing changes)
            set(handles.selectLEDsShow,'Value',1);
            handles.settingsStruct.selectLEDsShow = 1;
        elseif handles.LEDsToEnable(2) == 1
            set(handles.selectLEDsShow,'Value',2);
            handles.settingsStruct.selectLEDsShow = 2;
        elseif handles.LEDsToEnable(3) == 1
            set(handles.selectLEDsShow,'Value',3);
            handles.settingsStruct.selectLEDsShow = 3;
        end 
    end
end
% Determine if quad view was enabled before changing LEDs
prevQuad = handles.settingsStruct.selectLEDsQuadViewOn;
% Save the new setting for this LED
handles.settingsStruct.selectLEDsEnable4 = get(handles.selectLEDsEnable4,'value');
prevLEDsToEnable = handles.LEDsToEnable; % for switching image data around
handles.LEDsToEnable(4) = handles.settingsStruct.selectLEDsEnable4;
if handles.settingsStruct.inCapMode == 0
    handles.settingsStruct.prevLEDsEnable4 = handles.settingsStruct.selectLEDsEnable4;
    handles.prevLEDsToEnable(4) = handles.settingsStruct.selectLEDsEnable4;
    % If the capture mode LED choices are locked to preview mode, then
    % switch capture mode settings, gui values
    if handles.settingsStruct.selectLEDsLockCap == 1
        handles.settingsStruct.capLEDsEnable4 = handles.settingsStruct.selectLEDsEnable4;
        handles.capLEDsToEnable(4) = handles.prevLEDsToEnable(4);
        set(handles.capLEDsEnable4,'Value',handles.settingsStruct.capLEDsEnable4);
    end
end
% Confirm (on command line) the LED change made
if handles.settingsStruct.selectLEDsEnable4 == 1
    disp([handles.settingsStruct.constLED4CenterWavelength ' LED turned ON.']);
else
    disp([handles.settingsStruct.constLED4CenterWavelength ' LED turned OFF.']);
end

% Turn on quad-view setting/change the quad view enable mode
if sum(handles.LEDsToEnable,2) > 2
    handles.settingsStruct.selectLEDsQuadViewOn = 1;
else
    handles.settingsStruct.selectLEDsQuadViewOn = 0;
end

% Determine which image axes to show/hide
if handles.settingsStruct.selectLEDsQuadViewOn == 1
    if prevQuad == 0
        disp('Turning quad-channel view mode on')
        % We have crossed the threshold and need to switch some axes to
        % enable the quad-channel view
        handles.imgHandLED2.Visible = 'off';
        handles.LED1DisplayedValues.Visible = 'off';
        handles.LED1BlackValueIndicator.Visible = 'off';
        handles.LED1WhiteValueIndicator.Visible = 'off';
        handles.LED2DisplayedValues.Visible = 'off';
        handles.LED2BlackValueIndicator.Visible = 'off';
        handles.LED2WhiteValueIndicator.Visible = 'off';
        
        % Variable for switching frames
        switchFrames=ones(size(handles.imageMask,1),size(handles.imageMask,2),2,'uint16');
        switchCLim=zeros(2,2);
        switchFrames(:,:,1) = get(handles.imgHandLED1,'CData'); 
        switchFrames(:,:,2) = get(handles.imgHandLED2,'CData');
        switchCLim(:,1) = get(handles.LED1Ax,'CLim');
        switchCLim(:,2) = get(handles.LED2Ax,'CLim');
        quadIdx = 1;
        
        if handles.LEDsToEnable(1) == 1
            handles.imgHandLEDQuad1.Visible = 'on';
            handles.LEDQuad1DisplayedValues.Visible = 'on';
            handles.LEDQuad1BlackValueIndicator.Visible = 'on';
            handles.LEDQuad1WhiteValueIndicator.Visible = 'on';
            if prevLEDsToEnable(1) == 1
                set(handles.imgHandLEDQuad1,'CData',switchFrames(:,:,quadIdx));
                set(handles.LEDQuad1Ax,'CLim',switchCLim(:,quadIdx));
                handles.settingsStruct.blackLevelLEDQuad1= switchCLim(1,quadIdx);
                handles.settingsStruct.whiteLevelLEDQuad1 = switchCLim(2,quadIdx);
                set(handles.LEDQuad1BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLEDQuad1))]);
                set(handles.LEDQuad1WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLEDQuad1))]);
                quadIdx = quadIdx + 1;
            end
        end
        if handles.LEDsToEnable(2) == 1
            handles.imgHandLEDQuad2.Visible = 'on';
            handles.LEDQuad2DisplayedValues.Visible = 'on';
            handles.LEDQuad2BlackValueIndicator.Visible = 'on';
        	handles.LEDQuad2WhiteValueIndicator.Visible = 'on';
            if prevLEDsToEnable(2) == 1
                set(handles.imgHandLEDQuad2,'CData',switchFrames(:,:,quadIdx));
                set(handles.LEDQuad2Ax,'CLim',switchCLim(:,quadIdx));
                handles.settingsStruct.blackLevelLEDQuad2= switchCLim(1,quadIdx);
                handles.settingsStruct.whiteLevelLEDQuad2 = switchCLim(2,quadIdx);
                set(handles.LEDQuad2BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLEDQuad2))]);
                set(handles.LEDQuad2WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLEDQuad2))]);
                quadIdx = quadIdx + 1;
            end
        end
        if handles.LEDsToEnable(3) == 1
            handles.imgHandLEDQuad3.Visible = 'on';
            handles.LEDQuad3DisplayedValues.Visible = 'on';
            handles.LEDQuad3BlackValueIndicator.Visible = 'on';
            handles.LEDQuad3WhiteValueIndicator.Visible = 'on';
            if prevLEDsToEnable(3) == 1
                set(handles.imgHandLEDQuad3,'CData',switchFrames(:,:,quadIdx));
                set(handles.LEDQuad3Ax,'CLim',switchCLim(:,quadIdx));
                handles.settingsStruct.blackLevelLEDQuad3= switchCLim(1,quadIdx);
                handles.settingsStruct.whiteLevelLEDQuad3 = switchCLim(2,quadIdx);
                set(handles.LEDQuad3BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLEDQuad4))]);
                set(handles.LEDQuad3WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLEDQuad4))]);
            end
        end
        
        %If we have transitions from quad off to on, then we MUST have enabled this channel
        handles.imgHandLEDQuad4.Visible = 'on'; 
        handles.LEDQuad4DisplayedValues.Visible = 'on';
        handles.LEDQuad4BlackValueIndicator.Visible = 'on';
        handles.LEDQuad4WhiteValueIndicator.Visible = 'on';
         % Also blank this frame axis (in case there is old imagery)
        set(handles.imgHandLEDQuad4,'CData',ones(size(handles.imageMask,1),'uint16'));
        blankLims = [0, (2^(handles.settingsStruct.constCameraBits)-1)];
        set(handles.LEDQuad4Ax,'CLim',blankLims);
        handles.settingsStruct.blackLevelLEDQuad4= blankLims(1);
        handles.settingsStruct.whiteLevelLEDQuad4 = blankLims(2);
        set(handles.LEDQuad4BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLEDQuad4))]);
        set(handles.LEDQuad4WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLEDQuad4))]);

    else
        % If we were in quad mode and we still are, then there are two possibilities
        if handles.settingsStruct.selectLEDsEnable4 == 1
            handles.imgHandLEDQuad4.Visible = 'on';
            handles.LEDQuad4DisplayedValues.Visible = 'on';
            handles.LEDQuad4BlackValueIndicator.Visible = 'on';
            handles.LEDQuad4WhiteValueIndicator.Visible = 'on';
            set(handles.imgHandLEDQuad4,'CData',ones(size(handles.imageMask,1),'uint16')); % show blank frame
            blankLims = [0, (2^(handles.settingsStruct.constCameraBits)-1)];
            set(handles.LEDQuad4Ax,'CLim',blankLims);
            handles.settingsStruct.blackLevelLEDQuad4= blankLims(1);
            handles.settingsStruct.whiteLevelLEDQuad4 = blankLims(2);
            set(handles.LEDQuad4BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLEDQuad4))]);
            set(handles.LEDQuad4WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLEDQuad4))]);
        else
            handles.imgHandLEDQuad4.Visible = 'off';
            handles.LEDQuad4DisplayedValues.Visible = 'off';
            handles.LEDQuad4BlackValueIndicator.Visible = 'off';
            handles.LEDQuad4WhiteValueIndicator.Visible = 'off';
        end
    end
else % now we are NOT in quad mode
    if prevQuad == 1 % but if we just were in quad mode, then make sure to hide all those axis
        disp('Turning quad-channel view mode off')
        handles.imgHandLED2.Visible = 'on';
        handles.LED1DisplayedValues.Visible = 'on';
        handles.LED1BlackValueIndicator.Visible = 'on';
        handles.LED1WhiteValueIndicator.Visible = 'on';
        handles.LED2DisplayedValues.Visible = 'on';
        handles.LED2BlackValueIndicator.Visible = 'on';
        handles.LED2WhiteValueIndicator.Visible = 'on';
        handles.imgHandLEDQuad1.Visible = 'off';
        handles.imgHandLEDQuad2.Visible = 'off';
        handles.imgHandLEDQuad3.Visible = 'off';
        handles.imgHandLEDQuad4.Visible = 'off';
        handles.LEDQuad1DisplayedValues.Visible = 'off';
        handles.LEDQuad1BlackValueIndicator.Visible = 'off';
        handles.LEDQuad1WhiteValueIndicator.Visible = 'off';
        handles.LEDQuad2DisplayedValues.Visible = 'off';
        handles.LEDQuad2BlackValueIndicator.Visible = 'off';
        handles.LEDQuad2WhiteValueIndicator.Visible = 'off';
        handles.LEDQuad3DisplayedValues.Visible = 'off';
        handles.LEDQuad3BlackValueIndicator.Visible = 'off';
        handles.LEDQuad3WhiteValueIndicator.Visible = 'off';
        handles.LEDQuad4DisplayedValues.Visible = 'off';
        handles.LEDQuad4BlackValueIndicator.Visible = 'off';
        handles.LEDQuad4WhiteValueIndicator.Visible = 'off';  
        % Determine which frames to put where--use LEDsToEnable to
        % determine which frame data to add to 2-image axes
        switchFrames=ones(size(handles.imageMask,1),size(handles.imageMask,2),2,'uint16');
        switchCLim = zeros(2,2);
        quadIdx = 1;
        if handles.LEDsToEnable(1) == 1
            switchFrames(:,:,quadIdx) = get(handles.imgHandLEDQuad1,'CData');
            switchCLim(:,quadIdx) = get(handles.LEDQuad1Ax,'CLim');
            quadIdx = quadIdx+1;
        end
        if handles.LEDsToEnable(2) == 1
            switchFrames(:,:,quadIdx) = get(handles.imgHandLEDQuad2,'CData');
            switchCLim(:,quadIdx) = get(handles.LEDQuad2Ax,'CLim');
            quadIdx = quadIdx+1;
        end
        if handles.LEDsToEnable(3) == 1
            switchFrames(:,:,quadIdx) = get(handles.imgHandLEDQuad3,'CData');
            switchCLim(:,quadIdx) = get(handles.LEDQuad3Ax,'CLim');
        end
        set(handles.imgHandLED1,'CData',switchFrames(:,:,1));
        set(handles.imgHandLED2,'CData',switchFrames(:,:,2));
        set(handles.LED1Ax,'CLim',switchCLim(:,1));
        set(handles.LED2Ax,'CLim',switchCLim(:,2));
        handles.settingsStruct.blackLevelLED1= switchCLim(1,1);
        handles.settingsStruct.whiteLevelLED1 = switchCLim(2,1);
        set(handles.LED1BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLED1))]);
        set(handles.LED1WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLED1))]);
        handles.settingsStruct.blackLevelLED2= switchCLim(1,2);
        handles.settingsStruct.whiteLevelLED2 = switchCLim(2,2);
        set(handles.LED2BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLED2))]);
        set(handles.LED2WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLED2))]);

    else % if we were not in quad mode and are still not in quad mode
        if handles.settingsStruct.selectLEDsEnable4 == 1
            handles.imgHandLED2.Visible = 'on';
            handles.LED2DisplayedValues.Visible = 'on';
            handles.LED2BlackValueIndicator.Visible = 'on';
            handles.LED2WhiteValueIndicator.Visible = 'on';
            set(handles.imgHandLED2,'CData',ones(size(handles.imageMask,1),'uint16')); % blank the second axis
            blankLims = [0, (2^(handles.settingsStruct.constCameraBits)-1)];
            set(handles.LED2Ax,'CLim',blankLims);
            handles.settingsStruct.blackLevelLED2= blankLims(1);
            handles.settingsStruct.whiteLevelLED2 = blankLims(2);
            set(handles.LED2BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLED2))]);
            set(handles.LED2WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLED2))]);
        else
            handles.imgHandLED2.Visible = 'off';
            handles.LED2DisplayedValues.Visible = 'off';
            handles.LED2BlackValueIndicator.Visible = 'off';
            handles.LED2WhiteValueIndicator.Visible = 'off';
            % Transfer image data here is not necessary since deselecting
            % the last LED will never mean any other LED needs to be moved
            % to big image axis 1
        end
    end
end

% Switch RT Histograms and RT Stats on/off
commRTStats_Callback(hObject, eventdata, handles);
commRTHistogram_Callback(hObject, eventdata, handles);
guidata(hObject,handles);


% --- Executes on selection change in selectLEDsShow.
function selectLEDsShow_Callback(hObject, eventdata, handles)
requestedBigFrame = get(handles.selectLEDsShow,'Value');
if handles.LEDsToEnable(requestedBigFrame) == 1
    handles.settingsStruct.selectLEDsShow = requestedBigFrame;
elseif handles.LEDsToEnable(1) == 1 % these are for cases where the requested LED is not active, so it corrects
    handles.settingsStruct.selectLEDsShow = 1;
    set(handles.selectLEDsShow,'Value',1);
elseif handles.LEDsToEnable(2) == 1
    handles.settingsStruct.selectLEDsShow = 2;
    set(handles.selectLEDsShow,'Value',2);
elseif handles.LEDsToEnable(3) == 1
    handles.settingsStruct.selectLEDsShow = 3;
    set(handles.selectLEDsShow,'Value',3);
else
    handles.settingsStruct.selectLEDsShow = 4;
    set(handles.selectLEDsShow,'Value',4);
end

% And if we're not in preview mode, then switch that frame's data to big
% axis, and adjust scales
if get(handles.prevStartButton,'Value') == 0
    if handles.settingsStruct.selectLEDsShow == 1
        newFrameData = get(handles.imgHandLEDQuad1,'CData');
        newLims = get(handles.LEDQuad1Ax,'CLim');
    elseif handles.settingsStruct.selectLEDsShow == 2
        newFrameData = get(handles.imgHandLEDQuad2,'CData');
        newLims = get(handles.LEDQuad2Ax,'CLim');
    elseif handles.settingsStruct.selectLEDsShow == 3
        newFrameData = get(handles.imgHandLEDQuad3,'CData');
        newLims = get(handles.LEDQuad3Ax,'CLim');
    elseif handles.settingsStruct.selectLEDsShow == 4
        newFrameData = get(handles.imgHandLEDQuad4,'CData');
        newLims = get(handles.LEDQuad4Ax,'CLim');
    end
    set(handles.imgHandLED1,'CData',newFrameData);
    set(handles.LED1Ax,'CLim',newLims);
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function selectLEDsShow_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in capLockSettings.
function capLockSettings_Callback(hObject, eventdata, handles)
% Set value in parameters struct
handles.settingsStruct.capLockSettings = get(handles.capLockSettings,'Value');
% if selected, change settings
if handles.settingsStruct.capLockSettings == 1
    % freeze (unenable those locked settings)
    set(handles.capExpTime,'Enable','off');
    set(handles.capBinSize,'Enable','off');
    set(handles.capPixClock,'Enable','off');
    set(handles.capGain,'Enable','off');
    % set the corresponding value from Preview mode's setting
    set(handles.capExpTime,'String',num2str(handles.settingsStruct.prevExpTime));
    set(handles.capBinSize,'Value',handles.settingsStruct.prevBinSize);
    set(handles.capPixClock,'Value',handles.settingsStruct.prevPixClock);
    set(handles.capGain,'Value',handles.settingsStruct.prevGain);
    % Over-write capture mode's settingsStruct values
    handles.settingsStruct.capExpTime= handles.settingsStruct.prevExpTime;
    handles.settingsStruct.capBinSize= handles.settingsStruct.prevBinSize;
    handles.settingsStruct.capPixClock= handles.settingsStruct.prevPixClock;
    handles.settingsStruct.capGain= handles.settingsStruct.prevGain;
else % otherwise re-enable those settings for arbitrary changes
    set(handles.capExpTime,'Enable','on');
    set(handles.capBinSize,'Enable','on');
    set(handles.capPixClock,'Enable','on');
    set(handles.capGain,'Enable','on');
end
handles = estimate_capture_time_data(handles);
guidata(hObject,handles);


% --- Executes on button press in commResetLevels.
function commResetLevels_Callback(hObject, eventdata, handles)
% Change all the settings struct values
white = 2^handles.settingsStruct.constCameraBits - 1;
handles.settingsStruct.blackLevelLED1 = 0;
handles.settingsStruct.whiteLevelLED1 = white;
handles.settingsStruct.blackLevelLED2 = 0; 
handles.settingsStruct.whiteLevelLED2 = white;
handles.settingsStruct.blackLevelLEDQuad1 = 0;
handles.settingsStruct.whiteLevelLEDQuad1 = white;
handles.settingsStruct.blackLevelLEDQuad2 = 0;
handles.settingsStruct.whiteLevelLEDQuad2 = white;
handles.settingsStruct.blackLevelLEDQuad3 = 0;
handles.settingsStruct.whiteLevelLEDQuad3 = white;
handles.settingsStruct.blackLevelLEDQuad4 = 0;
handles.settingsStruct.whiteLevelLEDQuad4 = white;
% Change CLim's
set(handles.LED1Ax,'CLim',[handles.settingsStruct.blackLevelLED1,handles.settingsStruct.whiteLevelLED1]);
set(handles.LED2Ax,'CLim',[handles.settingsStruct.blackLevelLED2,handles.settingsStruct.whiteLevelLED2]);
set(handles.LEDQuad1Ax,'CLim',[handles.settingsStruct.blackLevelLEDQuad1,handles.settingsStruct.whiteLevelLEDQuad1]);
set(handles.LEDQuad2Ax,'CLim',[handles.settingsStruct.blackLevelLEDQuad2,handles.settingsStruct.whiteLevelLEDQuad2]);
set(handles.LEDQuad3Ax,'CLim',[handles.settingsStruct.blackLevelLEDQuad3,handles.settingsStruct.whiteLevelLEDQuad3]);
set(handles.LEDQuad4Ax,'CLim',[handles.settingsStruct.blackLevelLEDQuad4,handles.settingsStruct.whiteLevelLEDQuad4]);
% Set the indicators of black vs white values correctly
set(handles.LED1BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLED1))]);
set(handles.LED1WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLED1))]);
set(handles.LED2BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLED2))]);
set(handles.LED2WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLED2))]);
set(handles.LEDQuad1BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLEDQuad1))]);
set(handles.LEDQuad1WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLEDQuad1))]);
set(handles.LEDQuad2BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLEDQuad2))]);
set(handles.LEDQuad2WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLEDQuad2))]);
set(handles.LEDQuad3BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLEDQuad3))]);
set(handles.LEDQuad3WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLEDQuad3))]);
set(handles.LEDQuad4BlackValueIndicator,'String',[ num2str(round(handles.settingsStruct.blackLevelLEDQuad4))]);
set(handles.LEDQuad4WhiteValueIndicator,'String',[ num2str(round(handles.settingsStruct.whiteLevelLEDQuad4))]);
% update GUI
guidata(hObject,handles);


% CAPTURE LEDs callbacks

% --- Executes on button press in capLEDsEnable1.
function capLEDsEnable1_Callback(hObject, eventdata, handles)
handles.settingsStruct.capLEDsEnable1 = get(handles.capLEDsEnable1,'Value');
handles.capLEDsToEnable(1) = handles.settingsStruct.capLEDsEnable1;
guidata(hObject,handles);

% --- Executes on button press in capLEDsEnable2.
function capLEDsEnable2_Callback(hObject, eventdata, handles)
handles.settingsStruct.capLEDsEnable2 = get(handles.capLEDsEnable2,'Value');
handles.capLEDsToEnable(2) = handles.settingsStruct.capLEDsEnable2;
guidata(hObject,handles);

% --- Executes on button press in capLEDsEnable3.
function capLEDsEnable3_Callback(hObject, eventdata, handles)
handles.settingsStruct.capLEDsEnable3 = get(handles.capLEDsEnable3,'Value');
handles.capLEDsToEnable(3) = handles.settingsStruct.capLEDsEnable3;
guidata(hObject,handles);

% --- Executes on button press in capLEDsEnable4.
function capLEDsEnable4_Callback(hObject, eventdata, handles)
handles.settingsStruct.capLEDsEnable4 = get(handles.capLEDsEnable4,'Value');
handles.capLEDsToEnable(4) = handles.settingsStruct.capLEDsEnable4;
guidata(hObject,handles);


% CLOSING FUNCTION - CLEANS UP CONNECTIONS (very important to get this
% right)
% --- Executes when user attempts to close the GUI.
function two_color_image_GUI_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to multicolor_imaging_GUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

disp('Closing Camera')
delete(handles.vidObj);
clear handles.vidObj
imaqreset

disp('Closing DAQ')
delete(handles.NIDaqSession);
daqreset

delete(hObject);



% CALLBACKS FOR ALL THE EDIT BLACK/WHITE LEVEL EDIT BOXES

function LED1BlackValueIndicator_Callback(hObject, eventdata, handles)
newBlackVal = round(str2double(get(handles.LED1BlackValueIndicator,'String')));
whiteVal = handles.settingsStruct.whiteLevelLED1;
% Check whether too low or too high
if newBlackVal < 0, newBlackVal = 0; end
if newBlackVal >= whiteVal, newBlackVal = whiteVal-1; end
% Put new val in edit box
set(handles.LED1BlackValueIndicator,'String',num2str(newBlackVal));
% Update this parameter in the settings struct
handles.settingsStruct.blackLevelLED1 = newBlackVal;
% Update the CLim
set(handles.LED1Ax,'CLim',[handles.settingsStruct.blackLevelLED1,handles.settingsStruct.whiteLevelLED1]);
guidata(hObject,handles);
   
function LED1WhiteValueIndicator_Callback(hObject, eventdata, handles)
newWhiteVal = round(str2double(get(handles.LED1WhiteValueIndicator,'String')));
blackVal = handles.settingsStruct.blackLevelLED1;
maxVal = 2^handles.settingsStruct.constCameraBits-1;
% Check whether too low or too high
if newWhiteVal > maxVal, newWhiteVal = maxVal; end
if newWhiteVal <= blackVal, newWhiteVal = blackVal+1; end
% Put new val in edit box
set(handles.LED1WhiteValueIndicator,'String',num2str(newWhiteVal));
% Update this parameter in the settings struct
handles.settingsStruct.whiteLevelLED1 = newWhiteVal;
% Update the CLim
set(handles.LED1Ax,'CLim',[handles.settingsStruct.blackLevelLED1,handles.settingsStruct.whiteLevelLED1]);
guidata(hObject,handles);

function LED2BlackValueIndicator_Callback(hObject, eventdata, handles)
newBlackVal = round(str2double(get(handles.LED2BlackValueIndicator,'String')));
whiteVal = handles.settingsStruct.whiteLevelLED2;
% Check whether too low or too high
if newBlackVal < 0, newBlackVal = 0; end
if newBlackVal >= whiteVal, newBlackVal = whiteVal-1; end
% Put new val in edit box
set(handles.LED2BlackValueIndicator,'String',num2str(newBlackVal));
% Update this parameter in the settings struct
handles.settingsStruct.blackLevelLED2 = newBlackVal;
% Update the CLim
set(handles.LED2Ax,'CLim',[handles.settingsStruct.blackLevelLED2,handles.settingsStruct.whiteLevelLED2]);
guidata(hObject,handles);

function LED2WhiteValueIndicator_Callback(hObject, eventdata, handles)
newWhiteVal = round(str2double(get(handles.LED2WhiteValueIndicator,'String')));
blackVal = handles.settingsStruct.blackLevelLED2;
maxVal = 2^handles.settingsStruct.constCameraBits-1;
% Check whether too low or too high
if newWhiteVal > maxVal, newWhiteVal = maxVal; end
if newWhiteVal <= blackVal, newWhiteVal = blackVal+1; end
% Put new val in edit box
set(handles.LED2WhiteValueIndicator,'String',num2str(newWhiteVal));
% Update this parameter in the settings struct
handles.settingsStruct.whiteLevelLED2 = newWhiteVal;
% Update the CLim
set(handles.LED2Ax,'CLim',[handles.settingsStruct.blackLevelLED2,handles.settingsStruct.whiteLevelLED2]);
guidata(hObject,handles);


function LEDQuad1BlackValueIndicator_Callback(hObject, eventdata, handles)
newBlackVal = round(str2double(get(handles.LEDQuad1BlackValueIndicator,'String')));
whiteVal = handles.settingsStruct.whiteLevelLEDQuad1;
% Check whether too low or too high
if newBlackVal < 0, newBlackVal = 0; end
if newBlackVal >= whiteVal, newBlackVal = whiteVal-1; end
% Put new val in edit box
set(handles.LEDQuad1BlackValueIndicator,'String',num2str(newBlackVal));
% Update this parameter in the settings struct
handles.settingsStruct.blackLevelLEDQuad1 = newBlackVal;
% Update the CLim
set(handles.LEDQuad1Ax,'CLim',[handles.settingsStruct.blackLevelLEDQuad1,handles.settingsStruct.whiteLevelLEDQuad1]);
guidata(hObject,handles);

function LEDQuad1WhiteValueIndicator_Callback(hObject, eventdata, handles)
newWhiteVal = round(str2double(get(handles.LEDQuad1WhiteValueIndicator,'String')));
blackVal = handles.settingsStruct.blackLevelLEDQuad1;
maxVal = 2^handles.settingsStruct.constCameraBits-1;
% Check whether too low or too high
if newWhiteVal > maxVal, newWhiteVal = maxVal; end
if newWhiteVal <= blackVal, newWhiteVal = blackVal+1; end
% Put new val in edit box
set(handles.LEDQuad1WhiteValueIndicator,'String',num2str(newWhiteVal));
% Update this parameter in the settings struct
handles.settingsStruct.whiteLevelLEDQuad1 = newWhiteVal;
% Update the CLim
set(handles.LEDQuad1Ax,'CLim',[handles.settingsStruct.blackLevelLEDQuad1,handles.settingsStruct.whiteLevelLEDQuad1]);
guidata(hObject,handles);

function LEDQuad2BlackValueIndicator_Callback(hObject, eventdata, handles)
newBlackVal = round(str2double(get(handles.LEDQuad2BlackValueIndicator,'String')));
whiteVal = handles.settingsStruct.whiteLevelLEDQuad2;
% Check whether too low or too high
if newBlackVal < 0, newBlackVal = 0; end
if newBlackVal >= whiteVal, newBlackVal = whiteVal-1; end
% Put new val in edit box
set(handles.LEDQuad2BlackValueIndicator,'String',num2str(newBlackVal));
% Update this parameter in the settings struct
handles.settingsStruct.blackLevelLEDQuad2 = newBlackVal;
% Update the CLim
set(handles.LEDQuad2Ax,'CLim',[handles.settingsStruct.blackLevelLEDQuad2,handles.settingsStruct.whiteLevelLEDQuad2]);
guidata(hObject,handles);

function LEDQuad2WhiteValueIndicator_Callback(hObject, eventdata, handles)
newWhiteVal = round(str2double(get(handles.LEDQuad2WhiteValueIndicator,'String')));
blackVal = handles.settingsStruct.blackLevelLEDQuad2;
maxVal = 2^handles.settingsStruct.constCameraBits-1;
% Check whether too low or too high
if newWhiteVal > maxVal, newWhiteVal = maxVal; end
if newWhiteVal <= blackVal, newWhiteVal = blackVal+1; end
% Put new val in edit box
set(handles.LEDQuad2WhiteValueIndicator,'String',num2str(newWhiteVal));
% Update this parameter in the settings struct
handles.settingsStruct.whiteLevelLEDQuad2 = newWhiteVal;
% Update the CLim
set(handles.LEDQuad2Ax,'CLim',[handles.settingsStruct.blackLevelLEDQuad2,handles.settingsStruct.whiteLevelLEDQuad2]);
guidata(hObject,handles);

function LEDQuad3BlackValueIndicator_Callback(hObject, eventdata, handles)
newBlackVal = round(str2double(get(handles.LEDQuad3BlackValueIndicator,'String')));
whiteVal = handles.settingsStruct.whiteLevelLEDQuad3;
% Check whether too low or too high
if newBlackVal < 0, newBlackVal = 0; end
if newBlackVal >= whiteVal, newBlackVal = whiteVal-1; end
% Put new val in edit box
set(handles.LEDQuad3BlackValueIndicator,'String',num2str(newBlackVal));
% Update this parameter in the settings struct
handles.settingsStruct.blackLevelLEDQuad3 = newBlackVal;
% Update the CLim
set(handles.LEDQuad3Ax,'CLim',[handles.settingsStruct.blackLevelLEDQuad3,handles.settingsStruct.whiteLevelLEDQuad3]);
guidata(hObject,handles);

function LEDQuad3WhiteValueIndicator_Callback(hObject, eventdata, handles)
newWhiteVal = round(str2double(get(handles.LEDQuad3WhiteValueIndicator,'String')));
blackVal = handles.settingsStruct.blackLevelLEDQuad3;
maxVal = 2^handles.settingsStruct.constCameraBits-1;
% Check whether too low or too high
if newWhiteVal > maxVal, newWhiteVal = maxVal; end
if newWhiteVal <= blackVal, newWhiteVal = blackVal+1; end
% Put new val in edit box
set(handles.LEDQuad3WhiteValueIndicator,'String',num2str(newWhiteVal));
% Update this parameter in the settings struct
handles.settingsStruct.whiteLevelLEDQuad3 = newWhiteVal;
% Update the CLim
set(handles.LEDQuad3Ax,'CLim',[handles.settingsStruct.blackLevelLEDQuad3,handles.settingsStruct.whiteLevelLEDQuad3]);
guidata(hObject,handles);

function LEDQuad4BlackValueIndicator_Callback(hObject, eventdata, handles)
newBlackVal = round(str2double(get(handles.LEDQuad4BlackValueIndicator,'String')));
whiteVal = handles.settingsStruct.whiteLevelLEDQuad4;
% Check whether too low or too high
if newBlackVal < 0, newBlackVal = 0; end
if newBlackVal >= whiteVal, newBlackVal = whiteVal-1; end
% Put new val in edit box
set(handles.LEDQuad4BlackValueIndicator,'String',num2str(newBlackVal));
% Update this parameter in the settings struct
handles.settingsStruct.blackLevelLEDQuad4 = newBlackVal;
% Update the CLim
set(handles.LEDQuad4Ax,'CLim',[handles.settingsStruct.blackLevelLEDQuad4,handles.settingsStruct.whiteLevelLEDQuad4]);
guidata(hObject,handles);

function LEDQuad4WhiteValueIndicator_Callback(hObject, eventdata, handles)
newWhiteVal = round(str2double(get(handles.LEDQuad4WhiteValueIndicator,'String')));
blackVal = handles.settingsStruct.blackLevelLEDQuad4;
maxVal = 2^handles.settingsStruct.constCameraBits-1;
% Check whether too low or too high
if newWhiteVal > maxVal, newWhiteVal = maxVal; end
if newWhiteVal <= blackVal, newWhiteVal = blackVal+1; end
% Put new val in edit box
set(handles.LEDQuad4WhiteValueIndicator,'String',num2str(newWhiteVal));
% Update this parameter in the settings struct
handles.settingsStruct.whiteLevelLEDQuad4 = newWhiteVal;
% Update the CLim
set(handles.LEDQuad4Ax,'CLim',[handles.settingsStruct.blackLevelLEDQuad4,handles.settingsStruct.whiteLevelLEDQuad4]);
guidata(hObject,handles);


% --- Executes on button press in selectLEDsLockCap.
function selectLEDsLockCap_Callback(hObject, eventdata, handles)
handles.settingsStruct.selectLEDsLockCap = get(handles.selectLEDsLockCap,'Value');
if handles.settingsStruct.selectLEDsLockCap == 1
    % if pressed on, then unenable all the capture mode selections
    set(handles.capLEDsEnable1,'Enable','off');
    set(handles.capLEDsEnable2,'Enable','off');
    set(handles.capLEDsEnable3,'Enable','off');
    set(handles.capLEDsEnable4,'Enable','off');
    
    % If capture mode was just run, we need to change axes displays
    if handles.settingsStruct.justFinishedCap == 1
        handles.settingsStruct.justFinishedCap = 0; % turn off this flag here or else it will affect callback fcns below

        if handles.prevLEDsToEnable(1) ~= handles.capLEDsToEnable(1)
            % Force current preview state on this button
            set(handles.selectLEDsEnable1,'Value',handles.prevLEDsToEnable(1));
            % Run callback for this LED's button
            selectLEDsEnable1_Callback(hObject, eventdata, handles)
            handles = guidata(hObject);
        end
        if handles.prevLEDsToEnable(2) ~= handles.capLEDsToEnable(2)
            % Force capture state for this button to capture state
            set(handles.selectLEDsEnable2,'Value',handles.prevLEDsToEnable(2));
            % Run callback for this LED's button
            selectLEDsEnable2_Callback(hObject, eventdata, handles)
            handles = guidata(hObject);
        end
        if handles.prevLEDsToEnable(3) ~= handles.capLEDsToEnable(3)
            % Force capture state for this button to capture state
            set(handles.selectLEDsEnable3,'Value',handles.prevLEDsToEnable(3));
            % Run callback for this LED's button
            selectLEDsEnable3_Callback(hObject, eventdata, handles)
            handles = guidata(hObject);
        end
        if handles.prevLEDsToEnable(4) ~= handles.capLEDsToEnable(4)
            % Force capture state for this button to capture state
            set(handles.selectLEDsEnable4,'Value',handles.prevLEDsToEnable(4));
            % Run callback for this LED's button
            selectLEDsEnable4_Callback(hObject, eventdata, handles)
            handles = guidata(hObject);
        end

    end
     
    % Get preview LED settings and over-ride capture LED settings with these 
    handles.settingsStruct.capLEDsEnable1 = handles.settingsStruct.prevLEDsEnable1;
    handles.settingsStruct.capLEDsEnable2 = handles.settingsStruct.prevLEDsEnable2;
    handles.settingsStruct.capLEDsEnable3 = handles.settingsStruct.prevLEDsEnable3;
    handles.settingsStruct.capLEDsEnable4 = handles.settingsStruct.prevLEDsEnable4;

    set(handles.capLEDsEnable1,'Value',handles.settingsStruct.capLEDsEnable1);
    set(handles.capLEDsEnable2,'Value',handles.settingsStruct.capLEDsEnable2);
    set(handles.capLEDsEnable3,'Value',handles.settingsStruct.capLEDsEnable3);
    set(handles.capLEDsEnable4,'Value',handles.settingsStruct.capLEDsEnable4);
    
    handles.capLEDsToEnable = handles.prevLEDsToEnable;
else 
    % if pressed off, then enable all the capture mode selections
    set(handles.capLEDsEnable1,'Enable','on');
    set(handles.capLEDsEnable2,'Enable','on');
    set(handles.capLEDsEnable3,'Enable','on');
    set(handles.capLEDsEnable4,'Enable','on');
end
guidata(hObject,handles);


% --- Executes on button press in fixationTarget.
function fixationTarget_Callback(hObject, eventdata, handles)
% Set the new value
handles.settingsStruct.fixationTarget = get(handles.fixationTarget,'Value');
% Toggle fixation target LED
handles.digitalOutputScan(6) = handles.settingsStruct.fixationTarget;
outputSingleScan(handles.NIDaqSession,handles.digitalOutputScan);
% Send along GUI data
guidata(hObject,handles);


% --- Executes on key press with focus on two_color_image_GUI and none of its controls.
function two_color_image_GUI_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to two_color_image_GUI (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

switch eventdata.Key
    case 'p' % Preview button
        if handles.enteringFilename == 1
            if strcmp(get(handles.saveBaseName,'Enable'),'on')
                handles.filenameChars = [handles.filenameChars eventdata.Key];
                set(handles.saveBaseName,'String',handles.filenameChars);
            end
        else
            if get(handles.prevStartButton,'Value') == 0
                set(handles.prevStartButton,'Value',1);
                prevStartButton_Callback(hObject, eventdata, handles);
            else
                set(handles.prevStartButton,'Value',0);
                prevStartButton_Callback(hObject, eventdata, handles);
            end
        end
    case 'c' % Capture button
        if handles.enteringFilename == 1
            if strcmp(get(handles.saveBaseName,'Enable'),'on')
                handles.filenameChars = [handles.filenameChars eventdata.Key];
                set(handles.saveBaseName,'String',handles.filenameChars);
            end
        else
            if get(handles.capStartButton,'Value') == 0
                set(handles.capStartButton,'Value',1);
                capStartButton_Callback(hObject, eventdata, handles);
            else
                set(handles.capStartButton,'Value',0);
                capStartButton_Callback(hObject, eventdata, handles);
            end
        end
    % Preview & capture LED channels 1-4
    case '1'
        if handles.enteringFilename == 1
            if strcmp(get(handles.saveBaseName,'Enable'),'on')
                handles.filenameChars = [handles.filenameChars eventdata.Key];
                set(handles.saveBaseName,'String',handles.filenameChars);
            end
        else
            if (~isempty(eventdata.Modifier)) && strcmp(eventdata.Modifier,'shift') % if the shift key is held down during press
                if get(handles.capLEDsEnable1,'Value') == 0
                    if strcmp(handles.capLEDsEnable1.Enable,'on')
                        set(handles.capLEDsEnable1,'Value',1)
                        capLEDsEnable1_Callback(hObject, eventdata, handles);
                    end
                else
                    if strcmp(handles.capLEDsEnable1.Enable,'on')
                        set(handles.capLEDsEnable1,'Value',0)
                        capLEDsEnable1_Callback(hObject, eventdata, handles);
                    end
                end
            else
                if get(handles.selectLEDsEnable1,'Value') == 0
                    if strcmp(handles.selectLEDsEnable1.Enable,'on')
                        set(handles.selectLEDsEnable1,'Value',1);
                        selectLEDsEnable1_Callback(hObject, eventdata, handles);
                    end
                else
                    if strcmp(handles.selectLEDsEnable1.Enable,'on')
                        set(handles.selectLEDsEnable1,'Value',0)
                        selectLEDsEnable1_Callback(hObject, eventdata, handles);
                    end
                end
            end
        end
    case '2'
        if handles.enteringFilename == 1
            if strcmp(get(handles.saveBaseName,'Enable'),'on')
                handles.filenameChars = [handles.filenameChars eventdata.Key];
                set(handles.saveBaseName,'String',handles.filenameChars);
            end
        else
            if (~isempty(eventdata.Modifier)) && strcmp(eventdata.Modifier,'shift') % if the shift key is held down during press
                if get(handles.capLEDsEnable2,'Value') == 0
                    if strcmp(handles.capLEDsEnable2.Enable,'on')
                        set(handles.capLEDsEnable2,'Value',1)
                        capLEDsEnable2_Callback(hObject, eventdata, handles);
                    end
                else
                    if strcmp(handles.capLEDsEnable2.Enable,'on')
                        set(handles.capLEDsEnable2,'Value',0)
                        capLEDsEnable2_Callback(hObject, eventdata, handles);
                    end
                end
            else
                if get(handles.selectLEDsEnable2,'Value') == 0
                    if strcmp(handles.selectLEDsEnable2.Enable,'on')
                        set(handles.selectLEDsEnable2,'Value',1);
                        selectLEDsEnable2_Callback(hObject, eventdata, handles);
                    end
                else
                    if strcmp(handles.selectLEDsEnable2.Enable,'on')
                        set(handles.selectLEDsEnable2,'Value',0)
                        selectLEDsEnable2_Callback(hObject, eventdata, handles);
                    end
                end
            end
        end
    case '3'
        if handles.enteringFilename == 1
            if strcmp(get(handles.saveBaseName,'Enable'),'on')
                handles.filenameChars = [handles.filenameChars eventdata.Key];
                set(handles.saveBaseName,'String',handles.filenameChars);
            end
        else
            if (~isempty(eventdata.Modifier)) && strcmp(eventdata.Modifier,'shift') % if the shift key is held down during press
                if get(handles.capLEDsEnable3,'Value') == 0
                    if strcmp(handles.capLEDsEnable3.Enable,'on')
                        set(handles.capLEDsEnable3,'Value',1)
                        capLEDsEnable3_Callback(hObject, eventdata, handles);
                    end
                else
                    if strcmp(handles.capLEDsEnable3.Enable,'on')
                        set(handles.capLEDsEnable3,'Value',0)
                        capLEDsEnable3_Callback(hObject, eventdata, handles);
                    end
                end
            else
                if get(handles.selectLEDsEnable3,'Value') == 0
                    if strcmp(handles.selectLEDsEnable3.Enable,'on')
                        set(handles.selectLEDsEnable3,'Value',1);
                        selectLEDsEnable3_Callback(hObject, eventdata, handles);
                    end
                else
                    if strcmp(handles.selectLEDsEnable3.Enable,'on')
                        set(handles.selectLEDsEnable3,'Value',0)
                        selectLEDsEnable3_Callback(hObject, eventdata, handles);
                    end
                end
            end
        end
    case '4'
        if handles.enteringFilename == 1
            if strcmp(get(handles.saveBaseName,'Enable'),'on')
                handles.filenameChars = [handles.filenameChars eventdata.Key];
                set(handles.saveBaseName,'String',handles.filenameChars);
            end
        else
            if (~isempty(eventdata.Modifier)) && strcmp(eventdata.Modifier,'shift') % if the shift key is held down during press
                if get(handles.capLEDsEnable4,'Value') == 0
                    if strcmp(handles.capLEDsEnable4.Enable,'on')
                        set(handles.capLEDsEnable4,'Value',1)
                        capLEDsEnable4_Callback(hObject, eventdata, handles);
                    end
                else
                    if strcmp(handles.capLEDsEnable4.Enable,'on')
                        set(handles.capLEDsEnable4,'Value',0')
                        capLEDsEnable4_Callback(hObject, eventdata, handles);
                    end
                end
            else
                if get(handles.selectLEDsEnable4,'Value') == 0
                    if strcmp(handles.selectLEDsEnable4.Enable,'on')
                        set(handles.selectLEDsEnable4,'Value',1);
                        selectLEDsEnable4_Callback(hObject, eventdata, handles);
                    end
                else
                    if strcmp(handles.selectLEDsEnable4.Enable,'on')
                        set(handles.selectLEDsEnable4,'Value',0)
                        selectLEDsEnable4_Callback(hObject, eventdata, handles);
                    end
                end
            end
        end
    case 'shift'
        handles.shiftHit = 1;
        guidata(hObject,handles);
    % Preview & Capture Exposure Time
    case {'numpad0','numpad1','numpad2','numpad3','numpad4','numpad5','numpad6','numpad7','numpad8','numpad9'}
        numNumpad = eventdata.Key(7);
        if handles.shiftHit == 1
            if strcmp(handles.capInputExpNumbers,'-')
                if strcmp(get(handles.capExpTime,'Enable'),'on')
                    handles.capInputExpNumbers = numNumpad;
                    set(handles.capExpTime,'String', handles.capInputExpNumbers);
                end
            else
                if strcmp(get(handles.capExpTime,'Enable'),'on')
                    handles.capInputExpNumbers = [handles.capInputExpNumbers numNumpad];
                    set(handles.capExpTime,'String', handles.capInputExpNumbers);
                end
            end
        else
            if strcmp(handles.inputExpNumbers,'-')
                handles.inputExpNumbers = numNumpad;
                set(handles.prevExpTime,'String', handles.inputExpNumbers);
            else
                handles.inputExpNumbers = [handles.inputExpNumbers numNumpad];
                set(handles.prevExpTime,'String', handles.inputExpNumbers);
            end
        end
        guidata(hObject,handles);
    case 'return' % actually set this value/subject name that was entered
        if handles.enteringFilename == 1
            handles.enteringFilename = 0;
            handles.filenameChars = '';
            saveBaseName_Callback(hObject, eventdata, handles)
        else
            if handles.shiftHit == 1
                if ~strcmp(handles.capInputExpNumbers,'-') % if it's not unused
                    % take the temp number string, convert to double
                    expNum = str2double(handles.capInputExpNumbers);
                    if expNum <1, expNum = 1; end
                    if expNum > handles.settingsStruct.constMaxExpTimeMs, expNum = handles.settingsStruct.constMaxExpTimeMs; end
                    % set the new exposure time, and run callback
                    set(handles.capExpTime,'String',num2str(expNum));
                    handles.capInputExpNumbers = '-'; % blanking the key tracker variable for next use
                    handles.shiftHit = 0;
                    capExpTime_Callback(hObject, eventdata, handles)
                end
            else
                if ~strcmp(handles.inputExpNumbers,'-') % if it's not unused
                    % take the temp number string, convert to double
                    expNum = str2double(handles.inputExpNumbers);
                    if expNum <1, expNum = 1; end
                    if expNum > handles.settingsStruct.constMaxExpTimeMs, expNum = handles.settingsStruct.constMaxExpTimeMs; end
                    % set the new exposure time, and run callback
                    set(handles.prevExpTime,'String',num2str(expNum));
                    handles.inputExpNumbers = '-'; % blanking the key tracker variable for next use
                    handles.shiftHit = 0;
                    prevExpTime_Callback(hObject, eventdata, handles);
                end
            end
        end
    case 'rightarrow'
        if (~isempty(eventdata.Modifier)) && strcmp(eventdata.Modifier,'shift') % if the shift key is held down during press
            if strcmp(get(handles.capExpTime,'Enable'),'on'); %If allowed.. 
                % get old exposure time
                oldExp = str2double(get(handles.capExpTime,'String'));
                newExp = oldExp + handles.settingsStruct.constExpIncrementMs;
                % Check number
                if newExp < 1, newExp = 1; end
                if newExp > handles.settingsStruct.constMaxExpTimeMs, newExp = handles.settingsStruct.constMaxExpTimeMs; end
                % set it in exposure box and run callback
                set(handles.capExpTime,'String',num2str(newExp));
                capExpTime_Callback(hObject, eventdata, handles);
            end
        else
            % get old exposure time
            oldExp = str2double(get(handles.prevExpTime,'String'));
            newExp = oldExp + handles.settingsStruct.constExpIncrementMs;
            % Check number
            if newExp < 1, newExp = 1; end
            if newExp > handles.settingsStruct.constMaxExpTimeMs, newExp = handles.settingsStruct.constMaxExpTimeMs; end
            % Set it in exposure box and run callback
            set(handles.prevExpTime,'String',num2str(newExp));
            prevExpTime_Callback(hObject, eventdata, handles);
        end
    case 'leftarrow'
        if (~isempty(eventdata.Modifier)) && strcmp(eventdata.Modifier,'shift') % if the shift key is held down during press
            if strcmp(get(handles.capExpTime,'Enable'),'on'); %If allowed.. 
                % get old exposure time
                oldExp = str2double(get(handles.capExpTime,'String'));
                newExp = oldExp - handles.settingsStruct.constExpIncrementMs;
                % Check number
                if newExp < 1, newExp = 1; end
                if newExp > handles.settingsStruct.constMaxExpTimeMs, newExp = handles.settingsStruct.constMaxExpTimeMs; end
                % set it in exposure box and run callback
                set(handles.capExpTime,'String',num2str(newExp));
                capExpTime_Callback(hObject, eventdata, handles);
            end
        else
            % get old exposure time
            oldExp = str2double(get(handles.prevExpTime,'String'));
            newExp = oldExp - handles.settingsStruct.constExpIncrementMs;
            % Check number
            if newExp < 1, newExp = 1; end
            if newExp > handles.settingsStruct.constMaxExpTimeMs, newExp = handles.settingsStruct.constMaxExpTimeMs; end
            % Set it in exposure box and run callback
            set(handles.prevExpTime,'String',num2str(newExp));
            prevExpTime_Callback(hObject, eventdata, handles);
        end
    case 'a' % to autoscale levels
        if handles.enteringFilename == 1
            if strcmp(get(handles.saveBaseName,'Enable'),'on')
                handles.filenameChars = [handles.filenameChars eventdata.Key];
                set(handles.saveBaseName,'String',handles.filenameChars);
            end
        else
            commAutoScale_Callback(hObject, eventdata, handles);
        end
    case 'r' % reset levels
        if handles.enteringFilename == 1
            if strcmp(get(handles.saveBaseName,'Enable'),'on')
                handles.filenameChars = [handles.filenameChars eventdata.Key];
                set(handles.saveBaseName,'String',handles.filenameChars);
            end
        else
            commResetLevels_Callback(hObject, eventdata, handles);
        end
        
    case 'l' % lock LEDs
        if handles.enteringFilename == 1
            if strcmp(get(handles.saveBaseName,'Enable'),'on')
                handles.filenameChars = [handles.filenameChars eventdata.Key];
                set(handles.saveBaseName,'String',handles.filenameChars);
            end
        else
            oldVal = get(handles.selectLEDsLockCap,'Value');
            set(handles.selectLEDsLockCap,'Value',~oldVal);
            selectLEDsLockCap_Callback(hObject, eventdata, handles);
        end
        
    case 's' % lock capture settings (to preview)
        if handles.enteringFilename == 1
            if strcmp(get(handles.saveBaseName,'Enable'),'on')
                handles.filenameChars = [handles.filenameChars eventdata.Key];
                set(handles.saveBaseName,'String',handles.filenameChars);
            end
        else
            oldVal = get(handles.capLockSettings,'Value');
            set(handles.capLockSettings,'Value',~oldVal);
            capLockSettings_Callback(hObject, eventdata, handles);
        end
        
    case 'm' % Real-time stats button
        if handles.enteringFilename == 1
            if strcmp(get(handles.saveBaseName,'Enable'),'on')
                handles.filenameChars = [handles.filenameChars eventdata.Key];
                set(handles.saveBaseName,'String',handles.filenameChars);
            end
        else
            oldVal = get(handles.commRTStats,'Value');
            set(handles.commRTStats,'Value',~oldVal);
            commRTStats_Callback(hObject, eventdata, handles);
        end
        
    case 'h' % Real time histogram button
        if handles.enteringFilename == 1
            if strcmp(get(handles.saveBaseName,'Enable'),'on')
                handles.filenameChars = [handles.filenameChars eventdata.Key];
                set(handles.saveBaseName,'String',handles.filenameChars);guidata(hObject,handles);
            end
        else
            oldVal = get(handles.commRTHistogram,'Value');
            set(handles.commRTHistogram,'Value',~oldVal);
            commRTHistogram_Callback(hObject, eventdata, handles);
        end
        
    case 'n' % Changing the subject name
        if handles.enteringFilename == 1
            if strcmp(get(handles.saveBaseName,'Enable'),'on')
                handles.filenameChars = [handles.filenameChars eventdata.Key];
                set(handles.saveBaseName,'String',handles.filenameChars);guidata(hObject,handles);
            end
        else
            handles.enteringFilename = 1;
            guidata(hObject,handles);    
        end
        
    case 'f' % Toggling realtime image flattening
        if handles.enteringFilename == 1
            if strcmp(get(handles.saveBaseName,'Enable'),'on')
                handles.filenameChars = [handles.filenameChars eventdata.Key];
                set(handles.saveBaseName,'String',handles.filenameChars);guidata(hObject,handles);
            end
        else
            oldVal = get(handles.RTFlattening,'Value');
            set(handles.RTFlattening,'Value',~oldVal);
            RTFlattening_Callback(hObject, eventdata, handles);
        end
        
        case 't' % Toggling fixation target
        if handles.enteringFilename == 1
            if strcmp(get(handles.saveBaseName,'Enable'),'on')
                handles.filenameChars = [handles.filenameChars eventdata.Key];
                set(handles.saveBaseName,'String',handles.filenameChars);guidata(hObject,handles);
            end
        else
            oldVal = get(handles.fixationTarget,'Value');
            set(handles.fixationTarget,'Value',~oldVal);
            fixationTarget_Callback(hObject, eventdata, handles);
        end
        
        case 'o' % Turn on preview mode with just the first channel selected
        if handles.enteringFilename == 1
            if strcmp(get(handles.saveBaseName,'Enable'),'on')
                handles.filenameChars = [handles.filenameChars eventdata.Key];
                set(handles.saveBaseName,'String',handles.filenameChars);guidata(hObject,handles);
            end
        else
            % If the preview mode button has already been pressed, then
            % don't do anything
            if get(handles.prevStartButton,'Value') == 1
                % nada
            else
                % Cycle through each LED channel and set to desired values and
                % run callbacks (desired is 1st LED channel only)
                if handles.prevLEDsToEnable(1) ~= 1
                    set(handles.selectLEDsEnable1,'Value',1);
                    selectLEDsEnable1_Callback(hObject, eventdata, handles);
                    handles = guidata(hObject);
                end
                if handles.prevLEDsToEnable(2) ~= 0
                    set(handles.selectLEDsEnable2,'Value',0);
                    selectLEDsEnable2_Callback(hObject, eventdata, handles);
                    handles = guidata(hObject);
                end
                if handles.prevLEDsToEnable(3) ~= 0
                    set(handles.selectLEDsEnable3,'Value',0);
                    selectLEDsEnable3_Callback(hObject, eventdata, handles);
                    handles = guidata(hObject);
                end
                if handles.prevLEDsToEnable(4) ~= 0
                    set(handles.selectLEDsEnable4,'Value',0);
                    selectLEDsEnable4_Callback(hObject, eventdata, handles);
                    handles = guidata(hObject);
                end

                % Initial a preview
                set(handles.prevStartButton,'Value',1)
                prevStartButton_Callback(hObject, eventdata, handles);
            end
        end
        
    case {'5','6','7','8','9','0','hyphen','q','w','e','y','u','i','d','g','j','k','z','x','v','b'}
        if handles.enteringFilename == 1
            if strcmp(get(handles.saveBaseName,'Enable'),'on')
                if strcmp(eventdata.Key,'hyphen')
                    eventdata.Key = '-';
                end
                handles.filenameChars = [handles.filenameChars eventdata.Key];
                set(handles.saveBaseName,'String',handles.filenameChars);
                guidata(hObject,handles);   
            end
        end
        
end
% next line for debugging
%disp(eventdata.Key)






% All the following are shells to run the key press callback above (just
% for different buttons in "focus")
function prevStartButton_KeyPressFcn(hObject, eventdata, handles)
two_color_image_GUI_KeyPressFcn(hObject, eventdata, handles)

function capStartButton_KeyPressFcn(hObject, eventdata, handles)
two_color_image_GUI_KeyPressFcn(hObject, eventdata, handles)

function prevBinSize_KeyPressFcn(hObject, eventdata, handles)
two_color_image_GUI_KeyPressFcn(hObject, eventdata, handles)

function prevPixClock_KeyPressFcn(hObject, eventdata, handles)
two_color_image_GUI_KeyPressFcn(hObject, eventdata, handles)

function prevGain_KeyPressFcn(hObject, eventdata, handles)
two_color_image_GUI_KeyPressFcn(hObject, eventdata, handles)

function capBinSize_KeyPressFcn(hObject, eventdata, handles)
two_color_image_GUI_KeyPressFcn(hObject, eventdata, handles)

function capPixClock_KeyPressFcn(hObject, eventdata, handles)
two_color_image_GUI_KeyPressFcn(hObject, eventdata, handles)

function capGain_KeyPressFcn(hObject, eventdata, handles)
two_color_image_GUI_KeyPressFcn(hObject, eventdata, handles)

function saveSettings_KeyPressFcn(hObject, eventdata, handles)
two_color_image_GUI_KeyPressFcn(hObject, eventdata, handles)

function saveFrameTimes_KeyPressFcn(hObject, eventdata, handles)
two_color_image_GUI_KeyPressFcn(hObject, eventdata, handles)

function capLockSettings_KeyPressFcn(hObject, eventdata, handles)
two_color_image_GUI_KeyPressFcn(hObject, eventdata, handles)

function commIRMode_KeyPressFcn(hObject, eventdata, handles)
two_color_image_GUI_KeyPressFcn(hObject, eventdata, handles)

function commAutoScale_KeyPressFcn(hObject, eventdata, handles)
two_color_image_GUI_KeyPressFcn(hObject, eventdata, handles)

function commResetLevels_KeyPressFcn(hObject, eventdata, handles)
two_color_image_GUI_KeyPressFcn(hObject, eventdata, handles)

function commRTStats_KeyPressFcn(hObject, eventdata, handles)
two_color_image_GUI_KeyPressFcn(hObject, eventdata, handles)

function commRTHistogram_KeyPressFcn(hObject, eventdata, handles)
two_color_image_GUI_KeyPressFcn(hObject, eventdata, handles)

function RTFlattening_KeyPressFcn(hObject, eventdata, handles)
two_color_image_GUI_KeyPressFcn(hObject, eventdata, handles)

function selectLEDsShow_KeyPressFcn(hObject, eventdata, handles)
two_color_image_GUI_KeyPressFcn(hObject, eventdata, handles)

function selectLEDsLockCap_KeyPressFcn(hObject, eventdata, handles)
two_color_image_GUI_KeyPressFcn(hObject, eventdata, handles)

function selectLEDsEnable1_KeyPressFcn(hObject, eventdata, handles)
two_color_image_GUI_KeyPressFcn(hObject, eventdata, handles)

function selectLEDsEnable2_KeyPressFcn(hObject, eventdata, handles)
two_color_image_GUI_KeyPressFcn(hObject, eventdata, handles)

function selectLEDsEnable3_KeyPressFcn(hObject, eventdata, handles)
two_color_image_GUI_KeyPressFcn(hObject, eventdata, handles)

function selectLEDsEnable4_KeyPressFcn(hObject, eventdata, handles)
two_color_image_GUI_KeyPressFcn(hObject, eventdata, handles)

function capLEDsEnable1_KeyPressFcn(hObject, eventdata, handles)
two_color_image_GUI_KeyPressFcn(hObject, eventdata, handles)

function capLEDsEnable2_KeyPressFcn(hObject, eventdata, handles)
two_color_image_GUI_KeyPressFcn(hObject, eventdata, handles)

function capLEDsEnable3_KeyPressFcn(hObject, eventdata, handles)
two_color_image_GUI_KeyPressFcn(hObject, eventdata, handles)

function capLEDsEnable4_KeyPressFcn(hObject, eventdata, handles)
two_color_image_GUI_KeyPressFcn(hObject, eventdata, handles)

function fixationTarget_KeyPressFcn(hObject, eventdata, handles)
two_color_image_GUI_KeyPressFcn(hObject, eventdata, handles)

