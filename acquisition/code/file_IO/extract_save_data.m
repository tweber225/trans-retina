function handles = extract_save_data(handles,rawBuffer,targetFramesToAcquire)

% Prohibit starting another capture, display saving status
set(handles.uiButtonCapture,'Enable','off');drawnow
set(handles.uiButtonCapture,'String','Saving Data');drawnow

% Get full frame and sequence info
frameWidth = handles.settings.numCols;
frameHeight = handles.settings.numRows;
numChannels = int32(sum(handles.settings.channelsEnable));
pixelEncoding = handles.settings.pixelEncoding;
channelIdx = 1:numel(handles.settings.channelsEnable);
[rc,frameStride] = AT_GetInt(handles.camHandle,'AOIStride'); 
AT_CheckWarning(rc);
dataType = 'uint16';

% saving options
options.message = false;

% Loop through all the frames
for frameIdx = 1:targetFramesToAcquire %note that frameIdx is 1-based
    % Display status
    set(handles.uiButtonCapture,'String',['Saving Data (' num2str(frameIdx) '/' num2str(targetFramesToAcquire) ')']);drawnow
    
    % Convert buffer into matrix
    if strcmp(pixelEncoding,'Mono12Packed')
        [rc,frameMatrixRotated] = AT_ConvertMono12PackedToMatrix(rawBuffer(:,frameIdx),frameHeight,frameWidth,frameStride);
    else
        [rc,frameMatrixRotated] = AT_ConvertMono16ToMatrix(rawBuffer(:,frameIdx),frameHeight,frameWidth,frameStride);
    end
    AT_CheckWarning(rc);

    % Rotate the frame
    currentFrame = rot90(uint16(frameMatrixRotated));
    
    % Determine channel, make filename
    channelNumberInSeq = mod(frameIdx-1,numChannels)+1;
    channelNumberOverall = min(channelIdx(cumsum(handles.settings.channelsEnable) == channelNumberInSeq));
    saveFilename = ['channel' num2str(channelNumberOverall) filesep 'frame' num2str(ceil(frameIdx/numChannels),'%04d') '.tif'];
    savePath = [handles.settings.capturePath filesep saveFilename];
    
    % Save this frame
    saveastiff(currentFrame,savePath,options);
end

% Finally re-enable capture button
set(handles.uiButtonCapture,'Enable','on')


