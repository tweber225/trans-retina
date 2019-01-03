function handles = channel_enable_disable(hObject,handles,channelNumber)

% determine if enabling or disabling a channel
enableLED = get(hObject,'Value');

% Compute the target number of channels
newNumChannels = sum(handles.settings.channelsEnable) + (enableLED-.5)*2;

% if disabling the LED make sure we still have one channel left
if (enableLED == 0) && (sum(handles.settings.channelsEnable) == 1)
    % Deny the change
    set(hObject,'Value',~enableLED);

% Otherwise, the change is valid
else
    % update settings
    handles.settings.channelsEnable(channelNumber) = enableLED;
    
    % Adjust buffer for channel add/delete
    handles = reallocate_series_buffer(handles);

    % toggle digital out pin
    digitalOutputScan = [0, handles.settings.flash, handles.settings.channelsEnable(2:end)];
    outputSingleScan(handles.daqHandle,digitalOutputScan);

end

% Update the timing and memory display
handles = update_timing_memory(handles);

