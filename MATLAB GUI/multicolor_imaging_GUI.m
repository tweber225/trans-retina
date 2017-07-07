function varargout = multicolor_imaging_GUI(varargin)
% MULTICOLOR_IMAGING_GUI MATLAB code for multicolor_imaging_GUI.fig
%      MULTICOLOR_IMAGING_GUI, by itself, creates a new MULTICOLOR_IMAGING_GUI or raises the existing
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

% Last Modified by GUIDE v2.5 05-Jul-2017 16:36:31

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
handles.settingsStruct = load_default_program_settings;

% Make digital channels to send enable signal to Arduino with correct
% configuration of LEDs
handles.LEDsToEnable = [handles.settingsStruct.selectLEDsEnable1 handles.settingsStruct.selectLEDsEnable2 handles.settingsStruct.selectLEDsEnable3 handles.settingsStruct.selectLEDsEnable4];
disp('Starting DAQ System')
handles.NIDaqSession = daq.createSession('ni');
addDigitalChannel(handles.NIDaqSession,'dev1','Port0/Line0:4','OutputOnly');
% Make sure the port is set to low so we can trigger the Aruindo later
outputSingleScan(handles.NIDaqSession,[0 handles.LEDsToEnable]);

% Open the camera adapters
disp('Starting Camera')
handles.vidObj = videoinput('pcocameraadaptor', 0); % vid input object
handles.srcObj = getselectedsource(handles.vidObj); % adapter source

%Set logging to memory
handles.vidObj.LoggingMode = 'memory';

% FOR DEBUGGING/TESTING FRAME NUMBERS
handles.srcObj.TMTimestampMode = 'BinaryAndAscii';

% Update GUI settings, set up default camera parameters
handles = update_all_settings_on_GUI(handles);
handles.srcObj = set_all_camera_settings(handles.srcObj,handles.settingsStruct);

% Update Handles for GUI data tracking
guidata(hObject, handles);

% Black out all image frames - and generate handles for image data
handles = reset_GUI_displays_update_resolution(handles,handles.settingsStruct.derivePrevNumPixPerDim);

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
guidata(hObject, handles);
disp(['Capture exposure time set to ' num2str(newExpTime) ' ms']);


% --- Executes during object creation, after setting all properties.
function capExpTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to capExpTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
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
guidata(hObject, handles);
disp(['Preview exposure time set to ' num2str(newExpTime) ' ms']);


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
guidata(hObject, handles);
disp(['Preview bin size set to ' dispSize ]);


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
guidata(hObject, handles);
disp(['Preview gain set to ' dispGain]);

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
% hObject    handle to capStartButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.capStartButton,'Value') == 1
    % Output TTL HIGH to Arduino to signal the start of an acquisition and
    % arm the arduino's toggling
    outputSingleScan(handles.NIDaqSession,1);
    
    % Set total number of frames (2x the number of frame pairs)
    numFramesTotal = 2*handles.settingsStruct.capNumFrames;

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
    LED1Frames = zeros([handles.settingsStruct.numPixPerDim, handles.settingsStruct.numPixPerDim, handles.settingsStruct.capNumFrames],'uint16');
    LED2Frames = LED1Frames;
    timesList = zeros([handles.settingsStruct.capNumFrames 2]);
    
    % Set up camera for preview with the latest settings
    handles = set_preview_or_capture_settings(handles,'capture');
    
    timeDataLastPair = 0; % (for FPS calculation)
    start(handles.vidObj);
    
    guidata(hObject,handles);
    
    pairIdx = 0; % Counter to track number of frames and stop the loop when done
    while (pairIdx < numFramesTotal) && (get(handles.capStartButton,'Value') == 1) % While we haven't acquire all the frames yet AND the toggle button is still DOWN
        % Don't get new GUI info here (as opposed to as is done in Preview)
        % because Capture Mode isn't supposed to be changed on the fly
        
        if handles.vidObj.FramesAvailable > 2 % Try to make up for dropped frames
            disp('Warning! Program is struggling to keep up')
            %droppedFrameData = getdata(handles.vidObj, 1); % try to recover, b/c if we lose a frame, we would be out of sync with the LEDs and GUI displays
            %pairIdx=pairIdx+1;
        end
        
        if handles.vidObj.FramesAvailable > 1 % when 2 frames are available put them up on the GUI displays
            [currentFramePair,timeDataNow] = getdata(handles.vidObj,handles.vidObj.FramesAvailable);
            LED1Frames(:,:,1+pairIdx/2) = currentFramePair(:,(1+handles.settingsStruct.commXShift):(handles.settingsStruct.numPixPerDim+handles.settingsStruct.commXShift),1,1);
            LED2Frames(:,:,1+pairIdx/2) = currentFramePair(:,(1+handles.settingsStruct.commXShift):(handles.settingsStruct.numPixPerDim+handles.settingsStruct.commXShift),1,2);
            timesList(1+pairIdx/2,1) = timeDataNow(1);
            timesList(1+pairIdx/2,2) = timeDataNow(2);
            
            % LED1DisplayedValues the current data shifted in X
            set(handles.imgHandLED1, 'CData', LED1Frames(:,:,1+pairIdx/2));
            set(handles.imgHandLED2, 'CData', LED2Frames(:,:,1+pairIdx/2));
            
            set(handles.capFPSIndicator,'String',[num2str(1/(timeDataNow(1)-timeDataLastPair),4) ' fpps']); % calculate FPS
            drawnow; % Must drawnow to show new frame data
            timeDataLastPair = timeDataNow(1); % Record this pair's time for next FPS calculation
            pairIdx=pairIdx+2; % increment the pair counter
            
            % update the button with progress
            set(handles.capStartButton,'String',['Abort ' num2str(pairIdx/2) '/' num2str(numFramesTotal/2)]);
        end
        
    end
    stop(handles.vidObj)
    handles = re_enable_preview_or_capture_settings(handles,'capture');
    disp('Capture ended')
   
    % Save the files as tiffs
    disp('Saving...')
    
    % First check whether a folder exists to save in
    dateDir = ['data' filesep datestr(now,'yymmdd')];
    if ~exist(dateDir,'dir')
        mkdir(dateDir);
    end
    
    fileName = [datestr(now,'yymmdd') '_' handles.settingsStruct.saveBaseName '_capture' sprintf('%.3d',handles.settingsStruct.saveCapNum)];
    dateAndCapDir = [dateDir filesep fileName];
    if exist(dateAndCapDir,'dir')
        disp('WARNING: OVERWRITING DATA');
    else
        mkdir(dateAndCapDir);
    end
    
    saveastiff(LED1Frames,[dateAndCapDir filesep fileName '_1.tiff']);
    saveastiff(LED2Frames,[dateAndCapDir filesep fileName '_2.tiff']);
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
    outputSingleScan(handles.NIDaqSession,0);
    
    guidata(hObject, handles);
else
    disp('Aborting Capture!')
    set(handles.capStartButton,'String','Start Capture');
end


% !!! Starts PREVIEW Button 
% --- Executes on button press in prevStartButton.
function prevStartButton_Callback(hObject, eventdata, handles)
if get(handles.prevStartButton,'Value') == 1
    % Output TTL HIGH to Arduino to signal the start of an acquisition and
    % indicate active LEDs
    outputSingleScan(handles.NIDaqSession,[1 handles.LEDsToEnable]);
    
    disp('Starting Preview')      
    % Check whether the current image data displayed on GUI matches the
    % desired capture resolutionn (numPixPerDim is always the currently
    % displayed image dimension, while the others are for desired
    % dimensions, which may or may not be active now)
    if handles.settingsStruct.numPixPerDim ~= handles.settingsStruct.derivePrevNumPixPerDim
        handles = reset_GUI_displays_update_resolution(handles,handles.settingsStruct.derivePrevNumPixPerDim);
    end
    
    % Set up camera for preview with the latest settings &gray out settings
    % that should not be changed
    handles = set_preview_or_capture_settings(handles,'preview');
    
    timeDataLastPair = 0; % for frame sets per second (FSPS) calculation
    start(handles.vidObj);
    
    guidata(hObject,handles);
    while get(handles.prevStartButton,'Value') == 1 % While the toggle button is DOWN
        % Get current GUI UI data (for update-able properties)
        handles = guidata(hObject);
        numLEDsEnabled = sum(handles.LEDsToEnable,2);
        
        if handles.vidObj.FramesAvailable > (numLEDsEnabled-1) % when >= number of frames requested are available, gather data and show them
            [currentFrameSet,timeDataNow] = getdata(handles.vidObj,handles.vidObj.FramesAvailable);
            if length(timeDataNow) > numLEDsEnabled
                currentFrameSet = currentFrameSet(:,:,:,(end-numLEDsEnabled+1):end);
                timeDataNow = timeDataNow((end-numLEDsEnabled+1):end);
                disp('WARNING: DETECTED DROPPED FRAMES')
            end
            % Gather data and crop to square (shifted in x)
            croppedFrames = squeeze(currentFrameSet(:,(1+handles.settingsStruct.commXShift):(handles.settingsStruct.numPixPerDim+handles.settingsStruct.commXShift),1,:));
            
            % LED1DisplayedValues data - dependent on whether "quad-channel view"
            % (quadview) is on
            if handles.settingsStruct.selectLEDsQuadViewOn == 1
                % Show all the individual images in smaller "thumbnails",
                % and determine which frame in buffer belongs in each image
                % spot on GUI
                frameIdx = 1;
                bigFrameToShow = -1;
                bigFrameRequest = get(handles.selectLEDsShow,'Value');
                if handles.settingsStruct.selectLEDsEnable1 == 1
                    set(handles.imgHandLEDQuad1, 'CData', croppedFrames(:,:,frameIdx));
                    if bigFrameRequest == 1;
                        bigFrameToShow = frameIdx;
                    end
                    frameIdx = frameIdx+1;
                end
                if handles.settingsStruct.selectLEDsEnable2 == 1
                    set(handles.imgHandLEDQuad2, 'CData', croppedFrames(:,:,frameIdx));
                    if bigFrameRequest == 2;
                        bigFrameToShow = frameIdx;
                    end
                    frameIdx = frameIdx+1;
                end
                if handles.settingsStruct.selectLEDsEnable3 == 1
                    set(handles.imgHandLEDQuad3, 'CData', croppedFrames(:,:,frameIdx));
                    if bigFrameRequest == 3;
                        bigFrameToShow = frameIdx;
                    end
                    frameIdx = frameIdx+1;
                end
                if handles.settingsStruct.selectLEDsEnable4 == 1
                    set(handles.imgHandLEDQuad4, 'CData', croppedFrames(:,:,frameIdx));
                    if bigFrameRequest == 4;
                        bigFrameToShow = frameIdx;
                    end
                end
                
                % Show one of these (specified in select LEDs panel) in
                % large LED1Ax frame
                set(handles.imgHandLED1, 'CData', croppedFrames(:,:,bigFrameToShow));
                
            else % if not in quad mode, we can just put the frames into each standard axis
                if numLEDsEnabled == 1
                    set(handles.imgHandLED1, 'CData', croppedFrames(:,:,1));
                else
                    set(handles.imgHandLED1, 'CData', croppedFrames(:,:,1));
                    set(handles.imgHandLED2, 'CData', croppedFrames(:,:,2));
                end
            end
                        
            % Do computations on the masked images only
            maskedCroppedFrames = zeros(sum(handles.imageMask(:)),numLEDsEnabled);
            for frameIdx = 1:numLEDsEnabled
                maskedImage = croppedFrames(:,:,frameIdx).*handles.imageMask;
                maskedCroppedFrames(:,frameIdx) = maskedImage(maskedImage>0);
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
            timeDataLastPair = timeDataNow(1); % Record this pair's time for next FPS calculation
        end
        
    end
    stop(handles.vidObj)
    handles = re_enable_preview_or_capture_settings(handles,'preview');
    
    % Send TTL LOW to Arduino to signal end of this acquisition event and
    % reset its LED toggle
    outputSingleScan(handles.NIDaqSession,[0 handles.LEDsToEnable]);
    
    guidata(hObject, handles);
else
    disp('Ending Preview')
end


function capNumFrames_Callback(hObject, eventdata, handles)
handles.settingsStruct.capNumFrames = str2double(get(handles.capNumFrames,'String'));
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
if QVals(1) == QVals(2)
    QVals(2) = QVals(2)+1;
end
handles.settingsStruct.blackLevelLED1 = QVals(1);
handles.settingsStruct.whiteLevelLED1 = QVals(2);
QVals = quantile(double(maskedLED2Data(maskedLED2Data>0)),[handles.settingsStruct.analysisAutoScaleLowQuantile,handles.settingsStruct.analysisAutoScaleHighQuantile]);
if QVals(1) == QVals(2)
    QVals(2) = QVals(2)+1;
end
handles.settingsStruct.blackLevelLED2 = QVals(1);
handles.settingsStruct.whiteLevelLED2 = QVals(2);
QVals = quantile(double(maskedLEDQuad1Data(maskedLEDQuad1Data>0)),[handles.settingsStruct.analysisAutoScaleLowQuantile,handles.settingsStruct.analysisAutoScaleHighQuantile]);
if QVals(1) == QVals(2)
    QVals(2) = QVals(2)+1;
end
handles.settingsStruct.blackLevelLEDQuad1 = QVals(1);
handles.settingsStruct.whiteLevelLEDQuad1 = QVals(2);
QVals = quantile(double(maskedLEDQuad2Data(maskedLEDQuad2Data>0)),[handles.settingsStruct.analysisAutoScaleLowQuantile,handles.settingsStruct.analysisAutoScaleHighQuantile]);
if QVals(1) == QVals(2)
    QVals(2) = QVals(2)+1;
end
handles.settingsStruct.blackLevelLEDQuad2 = QVals(1);
handles.settingsStruct.whiteLevelLEDQuad2 = QVals(2);
QVals = quantile(double(maskedLEDQuad3Data(maskedLEDQuad3Data>0)),[handles.settingsStruct.analysisAutoScaleLowQuantile,handles.settingsStruct.analysisAutoScaleHighQuantile]);
if QVals(1) == QVals(2)
    QVals(2) = QVals(2)+1;
end
handles.settingsStruct.blackLevelLEDQuad3 = QVals(1);
handles.settingsStruct.whiteLevelLEDQuad3 = QVals(2);
QVals = quantile(double(maskedLEDQuad4Data(maskedLEDQuad4Data>0)),[handles.settingsStruct.analysisAutoScaleLowQuantile,handles.settingsStruct.analysisAutoScaleHighQuantile]);
if QVals(1) == QVals(2)
    QVals(2) = QVals(2)+1;
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
set(handles.LED1BlackValueIndicator,'String',['Black: ' num2str(round(handles.settingsStruct.blackLevelLED1))]);
set(handles.LED1WhiteValueIndicator,'String',['White: ' num2str(round(handles.settingsStruct.whiteLevelLED1))]);
set(handles.LED2BlackValueIndicator,'String',['Black: ' num2str(round(handles.settingsStruct.blackLevelLED2))]);
set(handles.LED2WhiteValueIndicator,'String',['White: ' num2str(round(handles.settingsStruct.whiteLevelLED2))]);
set(handles.LEDQuad1BlackValueIndicator,'String',['Black: ' num2str(round(handles.settingsStruct.blackLevelLEDQuad1))]);
set(handles.LEDQuad1WhiteValueIndicator,'String',['White: ' num2str(round(handles.settingsStruct.whiteLevelLEDQuad1))]);
set(handles.LEDQuad2BlackValueIndicator,'String',['Black: ' num2str(round(handles.settingsStruct.blackLevelLEDQuad2))]);
set(handles.LEDQuad2WhiteValueIndicator,'String',['White: ' num2str(round(handles.settingsStruct.whiteLevelLEDQuad2))]);
set(handles.LEDQuad3BlackValueIndicator,'String',['Black: ' num2str(round(handles.settingsStruct.blackLevelLEDQuad3))]);
set(handles.LEDQuad3WhiteValueIndicator,'String',['White: ' num2str(round(handles.settingsStruct.whiteLevelLEDQuad3))]);
set(handles.LEDQuad4BlackValueIndicator,'String',['Black: ' num2str(round(handles.settingsStruct.blackLevelLEDQuad4))]);
set(handles.LEDQuad4WhiteValueIndicator,'String',['White: ' num2str(round(handles.settingsStruct.whiteLevelLEDQuad4))]);

guidata(hObject, handles);

% --- Executes on button press in commRTStats.
function commRTStats_Callback(hObject, eventdata, handles)
% Get the new state of RT (=real time) Statistics button
handles.settingsStruct.commRTStats = get(handles.commRTStats,'Value');
% if the button is now checked, we need to enable several stat indicators
if handles.settingsStruct.commRTStats == 1
    % check which viewing mode
    if handles.settingsStruct.selectLEDsQuadViewOn == 1
        if handles.LEDsToEnable(1) == 1
            handles.LEDQuad1StatsIndicator.Visible = 'on';
        else
            handles.LEDQuad1StatsIndicator.Visible = 'off';
        end
        if handles.LEDsToEnable(2) == 1
            handles.LEDQuad2StatsIndicator.Visible = 'on';
        else
            handles.LEDQuad2StatsIndicator.Visible = 'off';
        end
        if handles.LEDsToEnable(3) == 1
            handles.LEDQuad3StatsIndicator.Visible = 'on';
        else
            handles.LEDQuad3StatsIndicator.Visible = 'off';
        end
        if handles.LEDsToEnable(4) == 1
            handles.LEDQuad4StatsIndicator.Visible = 'on';
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
        % Show/hide indicator fields
        handles.LED1ColorIndicator.Visible = 'on';
        handles.LED1MinIndicator.Visible = 'on';
        handles.LED1MaxIndicator.Visible = 'on';
        handles.LED1MeanIndicator.Visible = 'on';
        handles.LED1MedianIndicator.Visible = 'on';
        handles.LED1PercentSaturatedIndicator.Visible = 'on';
        if sum(handles.LEDsToEnable,2) == 2
            handles.LED2ColorIndicator.Visible = 'on';
            handles.LED2MinIndicator.Visible = 'on';
            handles.LED2MaxIndicator.Visible = 'on';
            handles.LED2MeanIndicator.Visible = 'on';
            handles.LED2MedianIndicator.Visible = 'on';
            handles.LED2PercentSaturatedIndicator.Visible = 'on';
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
if handles.settingsStruct.commRTHistogram == 1 % If it is now on, check whether...
    %... we are in quad mode
    if handles.settingsStruct.selectLEDsQuadViewOn == 1
        % then we need to show all the quad view histogram axes that are
        % required
        if handles.LEDsToEnable(1) == 1
            handles.histHandLEDQuad1.Visible = 'on';
            handles.LEDQuad1Hist.Visible = 'on';
        else
            handles.histHandLEDQuad1.Visible = 'off';
            handles.LEDQuad1Hist.Visible = 'off';
        end
        if handles.LEDsToEnable(2) == 1
            handles.histHandLEDQuad2.Visible = 'on';
            handles.LEDQuad2Hist.Visible = 'on';
        else
            handles.histHandLEDQuad2.Visible = 'off';
            handles.LEDQuad2Hist.Visible = 'off';
        end
        if handles.LEDsToEnable(3) == 1
            handles.histHandLEDQuad3.Visible = 'on';
            handles.LEDQuad3Hist.Visible = 'on';
        else
            handles.histHandLEDQuad3.Visible = 'off';
            handles.LEDQuad3Hist.Visible = 'off';
        end
        if handles.LEDsToEnable(4) == 1
            handles.histHandLEDQuad4.Visible = 'on';
            handles.LEDQuad4Hist.Visible = 'on';
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
        if sum(handles.LEDsToEnable,2) == 2
            handles.histHandLED2.Visible = 'on';
            handles.LED2Hist.Visible = 'on';
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
guidata(hObject, handles);
disp(['Preview pixel read set to ' dispPixClock]);

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

% --- Executes on button press in commStatHistInCenter.
function commStatHistInCenter_Callback(hObject, eventdata, handles)
handles.settingsStruct.commStatHistInCenter = get(handles.commStatHistInCenter,'Value');

% Update image mask
pixDim = handles.settingsStruct.numPixPerDim;
if handles.settingsStruct.analysisReduceNumPixels == 1
    imageMaskMask = mod(bsxfun(@plus,uint16(1:pixDim),uint16((1:pixDim)')),2);
else
    imageMaskMask = ones(pixDim,'uint16');
end
if handles.settingsStruct.commStatHistInCenter == 1
    selectRad = 0.5*pixDim*handles.settingsStruct.analysisSelectCenterRadPercent;
    [x, y] = meshgrid(1:pixDim, 1:pixDim);
    handles.imageMask = uint16((x-.5*pixDim-1).^2+(y-.5*pixDim-1).^2 <= selectRad^2).*imageMaskMask;
else
    handles.imageMask = ones(pixDim,'uint16').*imageMaskMask;
end

guidata(hObject,handles);



% --- Executes on button press in selectLEDsEnable1.
function selectLEDsEnable1_Callback(hObject, eventdata, handles)
if (sum(handles.LEDsToEnable,2) == 1) && (get(handles.selectLEDsEnable1,'value') == 0)
    disp('Error: you cannot disable all LEDs.')
    set(handles.selectLEDsEnable1,'value',1);
    return
end
% Determine if quad view was enabled before changing LEDs
prevQuad = handles.settingsStruct.selectLEDsQuadViewOn;
% Save the new setting for this LED
handles.settingsStruct.selectLEDsEnable1 = get(handles.selectLEDsEnable1,'value');
handles.LEDsToEnable(1) = handles.settingsStruct.selectLEDsEnable1;
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

% Switch RT Histograms and RT Stats on/off
commRTStats_Callback(hObject, eventdata, handles);
commRTHistogram_Callback(hObject, eventdata, handles);
guidata(hObject, handles);

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
        handles.imgHandLEDQuad1.Visible = 'on'; %If we have transitions from quad off to on, then we MUST have enabled this channel
        handles.LEDQuad1DisplayedValues.Visible = 'on';
        handles.LEDQuad1BlackValueIndicator.Visible = 'on';
        handles.LEDQuad1WhiteValueIndicator.Visible = 'on';
        if handles.LEDsToEnable(2) == 1
            handles.imgHandLEDQuad2.Visible = 'on';
            handles.LEDQuad2DisplayedValues.Visible = 'on';
            handles.LEDQuad2BlackValueIndicator.Visible = 'on';
        	handles.LEDQuad2WhiteValueIndicator.Visible = 'on';
        end
        if handles.LEDsToEnable(3) == 1
            handles.imgHandLEDQuad3.Visible = 'on';
            handles.LEDQuad3DisplayedValues.Visible = 'on';
            handles.LEDQuad3BlackValueIndicator.Visible = 'on';
            handles.LEDQuad3WhiteValueIndicator.Visible = 'on';
        end
        if handles.LEDsToEnable(4) == 1
            handles.imgHandLEDQuad4.Visible = 'on';
            handles.LEDQuad4DisplayedValues.Visible = 'on';
            handles.LEDQuad4BlackValueIndicator.Visible = 'on';
            handles.LEDQuad4WhiteValueIndicator.Visible = 'on';
        end
    else
        % If we were in quad mode and we still are, then there are two possibilities
        if handles.settingsStruct.selectLEDsEnable1 == 1
            handles.imgHandLEDQuad1.Visible = 'on';
            handles.LEDQuad1DisplayedValues.Visible = 'on';
            handles.LEDQuad1BlackValueIndicator.Visible = 'on';
            handles.LEDQuad1WhiteValueIndicator.Visible = 'on';
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
    else % if we were not in quad mode and are still not in quad mode
        if handles.settingsStruct.selectLEDsEnable1 == 1
            handles.imgHandLED2.Visible = 'on';
            handles.LED2DisplayedValues.Visible = 'on';
            handles.LED2BlackValueIndicator.Visible = 'on';
            handles.LED2WhiteValueIndicator.Visible = 'on';
        else
            handles.imgHandLED2.Visible = 'off';
            handles.LED2DisplayedValues.Visible = 'off';
            handles.LED2BlackValueIndicator.Visible = 'off';
            handles.LED2WhiteValueIndicator.Visible = 'off';
        end
    end
end
guidata(hObject,handles);


% --- Executes on button press in selectLEDsEnable2.
function selectLEDsEnable2_Callback(hObject, eventdata, handles)
if (sum(handles.LEDsToEnable,2) == 1) && (get(handles.selectLEDsEnable2,'value') == 0)
    disp('Error: you cannot disable all LEDs.')
    set(handles.selectLEDsEnable2,'value',1);
    return
end
% Determine if quad view was enabled before changing LEDs
prevQuad = handles.settingsStruct.selectLEDsQuadViewOn;
% Save the new setting for this LED
handles.settingsStruct.selectLEDsEnable2 = get(handles.selectLEDsEnable2,'value');
handles.LEDsToEnable(2) = handles.settingsStruct.selectLEDsEnable2;
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

% Switch RT Histograms and RT Stats on/off
commRTStats_Callback(hObject, eventdata, handles);
commRTHistogram_Callback(hObject, eventdata, handles);
guidata(hObject, handles);

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
        handles.imgHandLEDQuad2.Visible = 'on'; %If we have transitions from quad off to on, then we MUST have enabled this channel
        handles.LEDQuad2DisplayedValues.Visible = 'on';
        handles.LEDQuad2BlackValueIndicator.Visible = 'on';
        handles.LEDQuad2WhiteValueIndicator.Visible = 'on';
        if handles.LEDsToEnable(1) == 1
            handles.imgHandLEDQuad1.Visible = 'on';
            handles.LEDQuad1DisplayedValues.Visible = 'on';
            handles.LEDQuad1BlackValueIndicator.Visible = 'on';
        	handles.LEDQuad1WhiteValueIndicator.Visible = 'on';
        end
        if handles.LEDsToEnable(3) == 1
            handles.imgHandLEDQuad3.Visible = 'on';
            handles.LEDQuad3DisplayedValues.Visible = 'on';
            handles.LEDQuad3BlackValueIndicator.Visible = 'on';
            handles.LEDQuad3WhiteValueIndicator.Visible = 'on';
        end
        if handles.LEDsToEnable(4) == 1
            handles.imgHandLEDQuad4.Visible = 'on';
            handles.LEDQuad4DisplayedValues.Visible = 'on';
            handles.LEDQuad4BlackValueIndicator.Visible = 'on';
            handles.LEDQuad4WhiteValueIndicator.Visible = 'on';
        end
    else
        % If we were in quad mode and we still are, then there are two possibilities
        if handles.settingsStruct.selectLEDsEnable2 == 1
            handles.imgHandLEDQuad2.Visible = 'on';
            handles.LEDQuad2DisplayedValues.Visible = 'on';
            handles.LEDQuad2BlackValueIndicator.Visible = 'on';
            handles.LEDQuad2WhiteValueIndicator.Visible = 'on';
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
    else % if we were not in quad mode and are still not in quad mode
        if handles.settingsStruct.selectLEDsEnable2 == 1
            handles.imgHandLED2.Visible = 'on';
        else
            handles.imgHandLED2.Visible = 'off';
        end
    end
end
guidata(hObject,handles);


% --- Executes on button press in selectLEDsEnable3.
function selectLEDsEnable3_Callback(hObject, eventdata, handles)
if (sum(handles.LEDsToEnable,2) == 1) && (get(handles.selectLEDsEnable3,'value') == 0)
    disp('Error: you cannot disable all LEDs.')
    set(handles.selectLEDsEnable3,'value',1);
    return
end
% Determine if quad view was enabled before changing LEDs
prevQuad = handles.settingsStruct.selectLEDsQuadViewOn;
% Save the new setting for this LED
handles.settingsStruct.selectLEDsEnable3 = get(handles.selectLEDsEnable3,'value');
handles.LEDsToEnable(3) = handles.settingsStruct.selectLEDsEnable3;
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

% Switch RT Histograms and RT Stats on/off
commRTStats_Callback(hObject, eventdata, handles);
commRTHistogram_Callback(hObject, eventdata, handles);
guidata(hObject, handles);

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
        handles.imgHandLEDQuad3.Visible = 'on'; %If we have transitions from quad off to on, then we MUST have enabled this channel
        handles.LEDQuad3DisplayedValues.Visible = 'on';
        handles.LEDQuad3BlackValueIndicator.Visible = 'on';
        handles.LEDQuad3WhiteValueIndicator.Visible = 'on';
        if handles.LEDsToEnable(1) == 1
            handles.imgHandLEDQuad1.Visible = 'on';
            handles.LEDQuad1DisplayedValues.Visible = 'on';
            handles.LEDQuad1BlackValueIndicator.Visible = 'on';
        	handles.LEDQuad1WhiteValueIndicator.Visible = 'on';
        end
        if handles.LEDsToEnable(2) == 1
            handles.imgHandLEDQuad2.Visible = 'on';
            handles.LEDQuad2DisplayedValues.Visible = 'on';
            handles.LEDQuad2BlackValueIndicator.Visible = 'on';
            handles.LEDQuad2WhiteValueIndicator.Visible = 'on';
        end
        if handles.LEDsToEnable(4) == 1
            handles.imgHandLEDQuad4.Visible = 'on';
            handles.LEDQuad4DisplayedValues.Visible = 'on';
            handles.LEDQuad4BlackValueIndicator.Visible = 'on';
            handles.LEDQuad4WhiteValueIndicator.Visible = 'on';
        end
    else
        % If we were in quad mode and we still are, then there are two possibilities
        if handles.settingsStruct.selectLEDsEnable3 == 1
            handles.imgHandLEDQuad3.Visible = 'on';
            handles.LEDQuad3DisplayedValues.Visible = 'on';
            handles.LEDQuad3BlackValueIndicator.Visible = 'on';
            handles.LEDQuad3WhiteValueIndicator.Visible = 'on';
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
    else % if we were not in quad mode and are still not in quad mode
        if handles.settingsStruct.selectLEDsEnable3 == 1
            handles.imgHandLED2.Visible = 'on';
            handles.LED2DisplayedValues.Visible = 'on';
            handles.LED2BlackValueIndicator.Visible = 'on';
            handles.LED2WhiteValueIndicator.Visible = 'on';
        else
            handles.imgHandLED2.Visible = 'off';
            handles.LED2DisplayedValues.Visible = 'off';
            handles.LED2BlackValueIndicator.Visible = 'off';
            handles.LED2WhiteValueIndicator.Visible = 'off';
        end
    end
end
guidata(hObject,handles);


% --- Executes on button press in selectLEDsEnable4.
function selectLEDsEnable4_Callback(hObject, eventdata, handles)
% Determine whether <1 LED is trying to be set
if (sum(handles.LEDsToEnable,2) == 1) && (get(handles.selectLEDsEnable4,'value') == 0)
    disp('Error: you cannot disable all LEDs.')
    set(handles.selectLEDsEnable4,'value',1);
    return
end
% Determine if quad view was enabled before changing LEDs
prevQuad = handles.settingsStruct.selectLEDsQuadViewOn;
% Save the new setting for this LED
handles.settingsStruct.selectLEDsEnable4 = get(handles.selectLEDsEnable4,'value');
handles.LEDsToEnable(4) = handles.settingsStruct.selectLEDsEnable4;
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

% Switch RT Histograms and RT Stats on/off
commRTStats_Callback(hObject, eventdata, handles);
commRTHistogram_Callback(hObject, eventdata, handles);
guidata(hObject, handles);

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
        handles.imgHandLEDQuad4.Visible = 'on'; %If we have transitions from quad off to on, then we MUST have enabled this channel
        handles.LEDQuad4DisplayedValues.Visible = 'on';
        handles.LEDQuad4BlackValueIndicator.Visible = 'on';
        handles.LEDQuad4WhiteValueIndicator.Visible = 'on';
        if handles.LEDsToEnable(1) == 1
            handles.imgHandLEDQuad1.Visible = 'on';
            handles.LEDQuad1DisplayedValues.Visible = 'on';
            handles.LEDQuad1BlackValueIndicator.Visible = 'on';
            handles.LEDQuad1WhiteValueIndicator.Visible = 'on';
        end
        if handles.LEDsToEnable(2) == 1
            handles.imgHandLEDQuad2.Visible = 'on';
            handles.LEDQuad2DisplayedValues.Visible = 'on';
            handles.LEDQuad2BlackValueIndicator.Visible = 'on';
        	handles.LEDQuad2WhiteValueIndicator.Visible = 'on';
        end
        if handles.LEDsToEnable(3) == 1
            handles.imgHandLEDQuad3.Visible = 'on';
            handles.LEDQuad3DisplayedValues.Visible = 'on';
            handles.LEDQuad3BlackValueIndicator.Visible = 'on';
            handles.LEDQuad3WhiteValueIndicator.Visible = 'on';
        end
    else
        % If we were in quad mode and we still are, then there are two possibilities
        if handles.settingsStruct.selectLEDsEnable4 == 1
            handles.imgHandLEDQuad4.Visible = 'on';
            handles.LEDQuad4DisplayedValues.Visible = 'on';
            handles.LEDQuad4BlackValueIndicator.Visible = 'on';
            handles.LEDQuad4WhiteValueIndicator.Visible = 'on';
        else
            handles.imgHandLEDQuad4.Visible = 'off';
            handles.LEDQuad4DisplayedValues.Visible = 'off';
            handles.LEDQuad4BlackValueIndicator.Visible = 'off';
            handles.LEDQuad4WhiteValueIndicator.Visible = 'off';
        end
    end
else % now we are not in quad mode
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
    else % if we were not in quad mode and are still not in quad mode
        if handles.settingsStruct.selectLEDsEnable4 == 1
            handles.imgHandLED2.Visible = 'on';
            handles.LED2DisplayedValues.Visible = 'on';
            handles.LED2BlackValueIndicator.Visible = 'on';
            handles.LED2WhiteValueIndicator.Visible = 'on';
        else
            handles.imgHandLED2.Visible = 'off';
            handles.LED2DisplayedValues.Visible = 'off';
            handles.LED2BlackValueIndicator.Visible = 'off';
            handles.LED2WhiteValueIndicator.Visible = 'off';
        end
    end
end
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
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function selectLEDsShow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selectLEDsShow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



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
