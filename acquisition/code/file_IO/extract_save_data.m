function handles = extract_save_data(handles,targetFramesToAcquire)

% display saving status on button
set(handles.uiButtonCapture,'Enable','off');drawnow
set(handles.uiButtonCapture,'String','Saving Data');drawnow

% get the sequence list
[~,seqIDList] = handles.camHandle.Memory.Sequence.GetList;
seqIDList = int32(seqIDList);

% get frame size and bitdepth
frameWidth = handles.constants.sensorXPixels;
frameHeight = handles.settings.numberLines;
numChannels = sum(handles.settings.channelsEnable);
channelIdx = 1:numel(handles.settings.channelsEnable);
if handles.settings.bitdepth == 8
    dataType = 'uint8';
else
    dataType = 'uint16';
end

% saving options
% options.append = true;
% if handles.settings.allocationSize/numChannels >= (4*2^10) % if individual channel req's >4GB then use 64bit addressing
%     options.big = true;
% end
options.message = false;

% Loop through all the frames
for frameIdx = 1:targetFramesToAcquire
    set(handles.uiButtonCapture,'String',['Saving Data (' num2str(frameIdx) '/' num2str(targetFramesToAcquire) ')']);drawnow
    % Convert to memory IDs
    [~,memID] = handles.camHandle.Memory.Sequence.ToMemoryID(seqIDList(frameIdx));
    
    % Copy the frame out of the API-either 8b or 16b data if in 10b ADC mode
    [~,rawFrameData] = handles.camHandle.Memory.CopyToArray(memID,handles.colorMode);
    frameData = cast(rawFrameData,dataType);
    
    % Reshape Frame
    currentFrame = reshape(frameData,[frameWidth frameHeight])';
    
    % Determine channel make filename
    channelNumberInSeq = mod(frameIdx-1,numChannels)+1;
    channelNumberOverall = min(channelIdx(cumsum(handles.settings.channelsEnable) == channelNumberInSeq));
    %saveFilename = ['channel' num2str(channelNumberOverall) '.tif'];
    saveFilename = ['channel' num2str(channelNumberOverall) filesep 'frame' num2str(ceil(frameIdx/numChannels),'%04d') '.tif'];
    savePath = [handles.settings.capturePath filesep saveFilename];
    
    % Put into the right file (for its channel)
    saveastiff(currentFrame,savePath,options);
end
set(handles.uiButtonCapture,'Enable','on')


