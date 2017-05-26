function varargout = two_color_image_GUI(varargin)
% TWO_COLOR_IMAGE_GUI MATLAB code for two_color_image_GUI.fig
%      TWO_COLOR_IMAGE_GUI, by itself, creates a new TWO_COLOR_IMAGE_GUI or raises the existing
%      singleton*.
%
%      H = TWO_COLOR_IMAGE_GUI returns the handle to a new TWO_COLOR_IMAGE_GUI or the handle to
%      the existing singleton*.
%
%      TWO_COLOR_IMAGE_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TWO_COLOR_IMAGE_GUI.M with the given input arguments.
%
%      TWO_COLOR_IMAGE_GUI('Property','Value',...) creates a new TWO_COLOR_IMAGE_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before two_color_image_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to two_color_image_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help two_color_image_GUI

% Last Modified by GUIDE v2.5 24-May-2017 21:47:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @two_color_image_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @two_color_image_GUI_OutputFcn, ...
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


% --- Executes just before two_color_image_GUI is made visible.
function two_color_image_GUI_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for two_color_image_GUI
handles.output = hObject;

% Update handles structure- not sure why this is needed here? won't hurt
guidata(hObject, handles);

% START TDW EDIT
% Make digital channel to enable the Arduino LED-toggler
disp('Starting DAQ System')
handles.NIDaqSession = daq.createSession('ni');
addDigitalChannel(handles.NIDaqSession,'dev1','Port0/Line1','OutputOnly');
% Make sure the port is set to low so we can trigger the Aruindo later
outputSingleScan(handles.NIDaqSession,0);

% Open the camera adapters
disp('Starting Camera')
handles.vidObj = videoinput('pcocameraadaptor', 0); % vid input object
handles.srcObj = getselectedsource(handles.vidObj); % adapter source

%Set logging to memory
handles.vidObj.LoggingMode = 'memory';

% FOR DEBUGGING/TESTING FRAME NUMBERS
handles.srcObj.TMTimestampMode = 'BinaryAndAscii';

% Load and set default parameters
handles.settingsStruct = load_default_program_settings;
handles = update_all_settings_on_GUI(handles);
handles.srcObj = set_all_camera_settings(handles.srcObj,handles.settingsStruct);

% Update Handles for GUI data tracking
guidata(hObject, handles);

% Black out both image frames - and generate handles for image data
handles = reset_GUI_displays_update_resolution(handles,handles.settingsStruct.derivePrevNumPixPerDim);

guidata(hObject, handles);


% END TDW EDIT


% UNNEEDED --- Outputs from this function are returned to the command line.
function varargout = two_color_image_GUI_OutputFcn(hObject, eventdata, handles) 
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
            
            % Display the current data shifted in X
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
    % Output TTL HIGH to Arduino to signal the start of an acquisition
    outputSingleScan(handles.NIDaqSession,1);
    
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
    
    timeDataLastPair = 0; % (for FPS calculation)
    start(handles.vidObj);
    
    guidata(hObject,handles);
    while get(handles.prevStartButton,'Value') == 1 % While the toggle button is DOWN
        % Get current GUI UI data (for update-able properties)
        handles = guidata(hObject);
        
        if handles.vidObj.FramesAvailable > 2 % If we have more than 2 frames in buffer, read 2 frames and discard them
            disp('!! DROPPED FRAME(S) !! Attempting to recover order')
            droppedFrameData = getdata(handles.vidObj, 2); % don't do anything with this data, this might pick up streaming slack
        end
        
        if handles.vidObj.FramesAvailable > 1 % when 2 frames are available put them up on the GUI displays
            [currentFramePair,timeDataNow] = getdata(handles.vidObj,handles.vidObj.FramesAvailable);
            
            % Display current data (shifted in X)
            frame1 = currentFramePair(:,(1+handles.settingsStruct.commXShift):(handles.settingsStruct.numPixPerDim+handles.settingsStruct.commXShift),1,1);
            frame2 = currentFramePair(:,(1+handles.settingsStruct.commXShift):(handles.settingsStruct.numPixPerDim+handles.settingsStruct.commXShift),1,2);
            set(handles.imgHandLED1, 'CData', frame1);
            set(handles.imgHandLED2, 'CData', frame2);
            
            % Do computations on the masked images only
            frame1 = frame1.*handles.imageMask;
            frame2 = frame2.*handles.imageMask;
            frame1 = frame1(frame1>0);
            frame2 = frame2(frame2>0);
            
            % If requested, recompute histogram
            if handles.settingsStruct.commRTHistogram == 1
                handles.histHandLED1.Data = frame1;
                handles.histHandLED2.Data = frame2;
            end
            
            % If requested, recompute statistics
            if handles.settingsStruct.commRTStats == 1
                set(handles.LED1MaxIndicator,'String',['Max: ' num2str(max(frame1(:)))]);
                set(handles.LED1MinIndicator,'String',['Min: ' num2str(min(frame1(:)))]);
                set(handles.LED1MeanIndicator,'String',['Mean: ' num2str(mean(frame1(:)),4)]);
                set(handles.LED1MedianIndicator,'String',['Median: ' num2str(median(frame1(:)),4)]);
                percentSat = 100*sum(frame1(:) == (2^handles.settingsStruct.constCameraBits-1))/numel(frame1(:));
                set(handles.LED1PercentSaturatedIndicator,'String',['% Saturated: ' num2str(percentSat,3) '%']);
                
                set(handles.LED2MaxIndicator,'String',['Max: ' num2str(max(frame2(:)))]);
                set(handles.LED2MinIndicator,'String',['Min: ' num2str(min(frame2(:)))]);
                set(handles.LED2MeanIndicator,'String',['Mean: ' num2str(mean(frame2(:)),4)]);
                set(handles.LED2MedianIndicator,'String',['Median: ' num2str(median(frame2(:)),4)]);
                percentSat = 100*sum(frame1(:) == (2^handles.settingsStruct.constCameraBits-1))/numel(frame2(:));
                set(handles.LED2PercentSaturatedIndicator,'String',['% Saturated: ' num2str(percentSat,3) '%']);
            end
            
            % Update Frame Pairs Per Second Indicator
            set(handles.prevFPSIndicator,'String',[num2str(1/(timeDataNow(1)-timeDataLastPair),4) ' fpps']); % calculate FPS
            
            drawnow; % Must drawnow to show new frame data
            timeDataLastPair = timeDataNow(1); % Record this pair's time for next FPS calculation
        end
        
    end
    stop(handles.vidObj)
    handles = re_enable_preview_or_capture_settings(handles,'preview');
    
    % Send TTL LOW to Arduino to signal end of this acquisition event and
    % reset its LED toggle
    outputSingleScan(handles.NIDaqSession,0);
    
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
% Get the two current frame's data
LED1Data = get(handles.imgHandLED1, 'CData');
LED2Data = get(handles.imgHandLED2, 'CData');
maskedLED1Data = LED1Data.*handles.imageMask;
maskedLED2Data = LED2Data.*handles.imageMask;

% find min and max for each within central circular region
led1Vals = quantile(double(maskedLED1Data(maskedLED1Data>0)),[handles.settingsStruct.analysisAutoScaleLowQuantile,handles.settingsStruct.analysisAutoScaleHighQuantile]);
handles.settingsStruct.blackLevelLED1 = led1Vals(1);
handles.settingsStruct.whiteLevelLED1 = led1Vals(2);
led2Vals = quantile(double(maskedLED2Data(maskedLED2Data>0)),[handles.settingsStruct.analysisAutoScaleLowQuantile,handles.settingsStruct.analysisAutoScaleHighQuantile]);
handles.settingsStruct.blackLevelLED2 = led2Vals(1);
handles.settingsStruct.whiteLevelLED2 = led2Vals(2);

% replace GUI frames with new scaled versions
imshow(LED1Data, [handles.settingsStruct.blackLevelLED1,handles.settingsStruct.whiteLevelLED1], 'Parent', handles.LED1Ax)
handles.imgHandLED1 = get(handles.LED1Ax,'Children');
imshow(LED2Data, [handles.settingsStruct.blackLevelLED2,handles.settingsStruct.whiteLevelLED2], 'Parent', handles.LED2Ax)
handles.imgHandLED2 = get(handles.LED2Ax,'Children');

% Set the indicators of black vs white values correctly
set(handles.LED1BlackValueIndicator,'String',['Black: ' num2str(round(handles.settingsStruct.blackLevelLED1))]);
set(handles.LED1WhiteValueIndicator,'String',['White: ' num2str(round(handles.settingsStruct.whiteLevelLED1))]);
set(handles.LED2BlackValueIndicator,'String',['Black: ' num2str(round(handles.settingsStruct.blackLevelLED2))]);
set(handles.LED2WhiteValueIndicator,'String',['White: ' num2str(round(handles.settingsStruct.whiteLevelLED2))]);

guidata(hObject, handles);

% --- Executes on button press in commRTStats.
function commRTStats_Callback(hObject, eventdata, handles)
handles.settingsStruct.commRTStats = get(handles.commRTStats,'Value');
if handles.settingsStruct.commRTStats == 0
    set(handles.LED1MaxIndicator,'String','Max: ');
    set(handles.LED1MinIndicator,'String','Min: ');
    set(handles.LED1MeanIndicator,'String','Mean: ');
    set(handles.LED1MedianIndicator,'String','Median: ');
    set(handles.LED1PercentSaturatedIndicator,'String','% Saturated: ');

    set(handles.LED2MaxIndicator,'String','Max: ');
    set(handles.LED2MinIndicator,'String','Min: ');
    set(handles.LED2MeanIndicator,'String','Mean: ');
    set(handles.LED2MedianIndicator,'String','Median: ');
    set(handles.LED2PercentSaturatedIndicator,'String','% Saturated: ');
end
guidata(hObject, handles);


% --- Executes on button press in commRTHistogram.
function commRTHistogram_Callback(hObject, eventdata, handles)
handles.settingsStruct.commRTHistogram = get(handles.commRTHistogram,'Value');
if handles.settingsStruct.commRTHistogram == 1
    if ~any(strcmp('histHandLED1',handles))
        frame1Data = get(handles.imgHandLED1, 'CData');
        handles.histHandLED1 = histogram(frame1Data,handles.histogramBinEdges,'Parent', handles.LED1Hist);
        handles.LED1Hist.XLim = [handles.histogramBinEdges(1) handles.histogramBinEdges(end)];
        handles.LED1Hist.YScale = 'log';
        frame2Data = get(handles.imgHandLED2, 'CData');
        handles.histHandLED2 = histogram(frame2Data,handles.histogramBinEdges,'Parent', handles.LED2Hist);
        handles.LED2Hist.XLim = [handles.histogramBinEdges(1) handles.histogramBinEdges(end)];
        handles.LED2Hist.YScale = 'log';
    end
else
    handles.LED1Hist.Visible = 'off';
    handles.LED2Hist.Visible = 'off';
    delete(handles.histHandLED1);
    delete(handles.histHandLED2);
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
if handles.settingsStruct.commStatHistInCenter == 1
    pixDim = handles.settingsStruct.numPixPerDim;
    selectRad = 0.5*pixDim*handles.settingsStruct.analysisSelectCenterRadPercent;
    [x, y] = meshgrid(1:pixDim, 1:pixDim);
    handles.imageMask = uint16((x-.5*pixDim-1).^2+(y-.5*pixDim-1).^2 <= selectRad^2);
else
    handles.imageMask = ones(handles.settingsStruct.numPixPerDim,'uint16');
end

guidata(hObject,handles);

% CLOSING FUNCTION - CLEANS UP CONNECTIONS (very important to get this
% right)
% --- Executes when user attempts to close the GUI.
function two_color_image_GUI_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to two_color_image_GUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
disp('Closing Camera')
delete(handles.vidObj);
clear handles.vidObj
imaqreset

disp('Closing DAQ')
delete(handles.NIDaqSession);
daqreset

delete(hObject);

% drop mic

