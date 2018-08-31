function [sequenceList,memoryIDList] = allocate_sequence(camHandle,settings,constants)

%numXPixels = constants.sensorXPixels;
%numYPixels = settings.numLines;
numChans = sum(settings.channelsEnable);

extraFrames = numChans*ceil(settings.framerate*constants.secondsOfExtraFramesAtEndOfSequence/numChans);

numFrames = settings.framesetsToCapture*sum(numChans) + extraFrames;

memoryIDList = zeros([numFrames, 1],'int32');

for frameIdx = 1:numFrames
    [~,memoryIDList(frameIdx)] = camHandle.Memory.Allocate(true);
end

camHandle.Memory.Sequence.Add(memoryIDList);
[~,sequenceList] = camHandle.Memory.Sequence.GetList;