function handles = channel_enable_disable(hObject,handles,channelNumber)

% determine if enabling or disabling a channel
enableLED = get(hObject,'Value');

% if disabling the LED make sure we still have one channel left
if (enableLED == 0) && (sum(handles.settings.channelsEnable) == 1)
    % Deny the change
    set(hObject,'Value',~enableLED);
else
    % update settings
    handles.settings.channelsEnable(channelNumber) = enableLED;

    % toggle digital out pin
    digitalOutputScan = [0 handles.settings.channelsEnable];
    outputSingleScan(handles.daqHandle,digitalOutputScan);

    % adjust memory sequence
    [handles.sequenceList,handles.memoryIDList] = adjust_sequence_allocation(handles.camHandle,handles.settings,handles.constants,handles.memoryIDList);

end

handles = update_timing_memory(handles); % Update displays

