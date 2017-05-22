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

% Last Modified by GUIDE v2.5 20-May-2017 21:59:28

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
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to two_color_image_GUI (see VARARGIN)

% Choose default command line output for two_color_image_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% START TDW EDIT
% Black out both image frames - and generate handles for image data
blankFrame = zeros(520);
imshow(blankFrame, 'Parent', handles.LED1Ax)
handles.imgHandLED1 = get(handles.LED1Ax,'Children');
imshow(blankFrame, 'Parent', handles.LED2Ax)
handles.imgHandLED2 = get(handles.LED2Ax,'Children');
guidata(hObject, handles);

% Open the camera adapters
disp('Starting Camera')
handles.vidObj = videoinput('pcocameraadaptor', 0); % vid input object
handles.srcObj = getselectedsource(handles.vidObj); % adapter source

%Set logging to memory
handles.vidObj.LoggingMode = 'memory';

% FOR DEBUGGING/TESTING FRAME NUMBERS
handles.srcObj.TMTimestampMode = 'BinaryAndAscii';

% Set default parameters

% Update Handles for GUI data tracking
guidata(hObject, handles);
END TDW EDIT


% --- Outputs from this function are returned to the command line.
function varargout = two_color_image_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function capExpTime_Callback(hObject, eventdata, handles)
% hObject    handle to capExpTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of capExpTime as text
%        str2double(get(hObject,'String')) returns contents of capExpTime as a double


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
% hObject    handle to capBinSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns capBinSize contents as cell array
%        contents{get(hObject,'Value')} returns selected item from capBinSize


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
% hObject    handle to capGain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns capGain contents as cell array
%        contents{get(hObject,'Value')} returns selected item from capGain


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



function prevExpTime_Callback(hObject, eventdata, handles)
% hObject    handle to prevExpTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of prevExpTime as text
%        str2double(get(hObject,'String')) returns contents of prevExpTime as a double


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
% hObject    handle to prevBinSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns prevBinSize contents as cell array
%        contents{get(hObject,'Value')} returns selected item from prevBinSize


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
% hObject    handle to prevGain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns prevGain contents as cell array
%        contents{get(hObject,'Value')} returns selected item from prevGain


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


% --- Executes on button press in capStartButton.
function capStartButton_Callback(hObject, eventdata, handles)
% hObject    handle to capStartButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.imgHandLED1 ,'CData',.5*ones(520));
drawnow;

% --- Executes on button press in prevStartButton.
function prevStartButton_Callback(hObject, eventdata, handles)
% hObject    handle to prevStartButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function capNumFrames_Callback(hObject, eventdata, handles)
% hObject    handle to capNumFrames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of capNumFrames as text
%        str2double(get(hObject,'String')) returns contents of capNumFrames as a double


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
% hObject    handle to saveBaseName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of saveBaseName as text
%        str2double(get(hObject,'String')) returns contents of saveBaseName as a double


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


% --- Executes on selection change in popupmenu13.
function popupmenu13_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu13 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu13


% --- Executes during object creation, after setting all properties.
function popupmenu13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu14.
function popupmenu14_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu14 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu14


% --- Executes during object creation, after setting all properties.
function popupmenu14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in commIRMode.
function commIRMode_Callback(hObject, eventdata, handles)
% hObject    handle to commIRMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of commIRMode


% --- Executes on button press in commAutoScale.
function commAutoScale_Callback(hObject, eventdata, handles)
% hObject    handle to commAutoScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of commAutoScale


% --- Executes on button press in commRTStats.
function commRTStats_Callback(hObject, eventdata, handles)
% hObject    handle to commRTStats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of commRTStats


% --- Executes on button press in commRTHistogram.
function commRTHistogram_Callback(hObject, eventdata, handles)
% hObject    handle to commRTHistogram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of commRTHistogram



function commXShift_Callback(hObject, eventdata, handles)
% hObject    handle to commXShift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of commXShift as text
%        str2double(get(hObject,'String')) returns contents of commXShift as a double


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


% --- Executes on button press in saveSettings.
function saveSettings_Callback(hObject, eventdata, handles)
% hObject    handle to saveSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of saveSettings


% --- Executes on selection change in capPixClock.
function capPixClock_Callback(hObject, eventdata, handles)
% hObject    handle to capPixClock (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns capPixClock contents as cell array
%        contents{get(hObject,'Value')} returns selected item from capPixClock


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
% hObject    handle to prevPixClock (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns prevPixClock contents as cell array
%        contents{get(hObject,'Value')} returns selected item from prevPixClock


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


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
disp('Closing Camera')
delete(handles.vidObj);
clear handles.vidObj
delete(hObject);
