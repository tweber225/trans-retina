function [frameHyperStack,settingsStruct] = load_tiff_sequence(capturePath)

% Load settings
settingsStruct = load_settings(capturePath);

% Get number of channels available
numChannels = sum(settingsStruct.channelsEnable);
channelOrder = (1:6);
channelOrder = channelOrder(logical(settingsStruct.channelsEnable));

% Get number of frames (per channel) available
numFrames = settingsStruct.framesetsToCapture;

% Get frame size
% load first frame to check number of cols, bit of a hack bc not saved
% in metadata
chanName = ['channel' num2str(channelOrder(1))];
firstFrameName = fullfile(capturePath,chanName,['frame' num2str(1,'%04d') '.tif']);
firstFrameSize = size(loadtiff(firstFrameName));
numCols = firstFrameSize(2);
numLines = firstFrameSize(1);
if settingsStruct.bitdepth <= 8
    pixDataType = 'uint8';
else
    pixDataType = 'uint16';
end

% Allocate space
frameHyperStack = zeros([numLines,numCols,numFrames,numChannels],pixDataType);

% Loop channels
for chanIdx = 1:numChannels
    chanName = ['channel' num2str(channelOrder(chanIdx))];
    disp(['Loading ' chanName])
    % Loop frames
    for frameIdx = 1:numFrames
        frameHyperStack(:,:,frameIdx,chanIdx) = loadtiff(fullfile(capturePath,chanName,['frame' num2str(frameIdx,'%04d') '.tif']));
    end
end
