function select_channel(hObject,handles)

% Get target channel
targetSelectChannel = get(hObject,'Value');

% Check whether this channel is enabled
if handles.settings.channelsEnable(targetSelectChannel) == 1
    % then we're all good, it's a valid choice
else % if not enabled, change to first enabled channel
    idx = 1:6;
    enabledChannels = idx(logical(handles.settings.channelsEnable));
    targetSelectChannel = enabledChannels(1);
    set(hObject,'Value',targetSelectChannel);
end

% Take note of the selected channel
handles.settings.selectChannel = targetSelectChannel;

% Pass data back to the GUI
guidata(hObject,handles);