function handles = channel_enable_disable(hObject,handles,channelNumber)

% determine if enabling or disabling a channel
enableLED = get(hObject,'Value');

% Compute the target number of channels
newNumChannels = sum(handles.settings.channelsEnable) + (enableLED-.5)*2;

% Estimate the allocation size
bytesPerPixel = ceil(handles.settings.bitdepth/8);
bytesPerFrame = double(handles.settings.numberLines)*handles.constants.sensorXPixels*bytesPerPixel;
estimatedAllocationSizeMB = bytesPerFrame*handles.settings.framesetsToCapture*newNumChannels/2^20;

% if disabling the LED make sure we still have one channel left
if (enableLED == 0) && (sum(handles.settings.channelsEnable) == 1)
    % Deny the change
    set(hObject,'Value',~enableLED);

% also check that we're not exceeding max allocation size
elseif estimatedAllocationSizeMB > handles.settings.maxAllocationSize
    set(hObject,'Value',~enableLED); % deny the change
    disp('Tried to allocate more memory than max allowable!');  % update GUI and get out

% Otherwise, the change is valid
else
    % update settings
    handles.settings.channelsEnable(channelNumber) = enableLED;

    % toggle digital out pin
    digitalOutputScan = [0 handles.settings.channelsEnable];
    outputSingleScan(handles.daqHandle,digitalOutputScan);

    % adjust memory sequence
    [handles.sequenceList,handles.memoryIDList] = adjust_sequence_allocation(handles.camHandle,handles.settings,handles.constants,handles.memoryIDList);

end

% Update the timing and memory display
handles = update_timing_memory(handles);

