function handles = allocate_series_buffer(handles)

% Get size of single image buffer in bytes and total size in MB
[rc,imageSizeBytes] = AT_GetInt(handles.camHandle,'ImageSizeBytes');
AT_CheckWarning(rc);
handles.settings.imageSizeBytes = imageSizeBytes;
SDKBufferSize = handles.settings.numBufferFrames*imageSizeBytes/(2^20); % in MB

% Get size of MATLAB acquisiton buffer (allocated in MATLAB rather than SDK)
numChannelsEnabled = sum(handles.settings.channelsEnable,2);
handles.settings.totalFrames = handles.settings.framesetsToCapture*numChannelsEnabled;
MATLABBufferSize = handles.settings.totalFrames*imageSizeBytes/(2^20); % in MB

% Check that the memory required by buffers does not exceed max allocation
% size setting
handles.settings.totalBufferSize = SDKBufferSize + MATLABBufferSize;
if handles.settings.totalBufferSize > handles.settings.maxAllocationSize
    % Correct this by reducing acquisition length
    excessMB = handles.settings.totalBufferSize - handles.settings.maxAllocationSize;
    excessFramesets = ceil(excessMB/(numChannelsEnabled*imageSizeBytes/(2^20)));
    handles.settings.framesetsToCapture = handles.settings.framesetsToCapture - excessFramesets;
    
    % Display the updated framesets to capture
    set(handles.framesetsToCapture,'String',num2str(handles.settings.framesetsToCapture));
    
    % Now redo a few calculations
    handles.settings.totalFrames = handles.settings.framesetsToCapture*numChannelsEnabled;
    MATLABBufferSize = handles.settings.totalFrames*imageSizeBytes/(2^20); % in MB
    handles.settings.totalBufferSize = SDKBufferSize + MATLABBufferSize;
end


% Allocate a fixed number of frames for circular buffering (by requeue
% after reading into MATLAB's memory)
for bufferIdx = 1:handles.settings.numBufferFrames;
    rc = AT_QueueBuffer(handles.camHandle,imageSizeBytes);
    AT_CheckWarning(rc);
end


