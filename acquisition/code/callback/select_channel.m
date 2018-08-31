function handles = select_channel(hObject,handles)

targetSelectChannel = get(hObject,'Value');

% Check whether this channel is enabled
if handles.settings.channelsEnable(targetSelectChannel) == 1
    % then we're all good
else % if not, change to first enabled channel
    idx = 1:6;
    enabledChannels = idx(logical(handles.settings.channelsEnable));
    targetSelectChannel = enabledChannels(1);
    set(hObject,'Value',targetSelectChannel);
    
end

handles.settings.selectChannel = targetSelectChannel;