function [sequenceList,memoryIDList] = reallocate_sequence(camHandle,settings,constants,oldMemoryIDList)

numChans = sum(settings.channelsEnable);


numOldFrames = numel(oldMemoryIDList);
for freeIdx = 1:numOldFrames
    camHandle.Memory.Free(oldMemoryIDList(freeIdx));
end

extraFrames = numChans*ceil(settings.framerate*constants.secondsOfExtraFramesAtEndOfSequence/numChans);

numFrames = settings.framesetsToCapture*numChans + extraFrames;

memoryIDList = zeros([numFrames, 1],'int32');

for frameIdx = 1:numFrames
    [~,memoryIDList(frameIdx)] = camHandle.Memory.Allocate(true);
end

camHandle.Memory.Sequence.Clear;
camHandle.Memory.Sequence.Add(memoryIDList);
[~,sequenceList] = camHandle.Memory.Sequence.GetList;