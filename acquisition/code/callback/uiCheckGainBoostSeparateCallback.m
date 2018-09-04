function uiCheckGainBoostSeparateCallback(hObject,handles)

% Gather the target gain boost state
targetGainBoost = logical(get(hObject,'Value'));

% try setting the gain state, return actual set state
actualGainBoost = set_gainboost(handles.camHandle,targetGainBoost);

% Take note of gain boost state in the settings structures
handles.settings.gainBoost = actualGainBoost;

% Show the actual gain state on GUI UI checkbox
set(handles.uiCheckGainBoost,'Value',actualGainBoost);

% Pass data along to GUI
guidata(hObject,handles);