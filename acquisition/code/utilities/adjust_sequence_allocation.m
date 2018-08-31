function [sequenceList,memoryIDList] = adjust_sequence_allocation(camHandle,settings,constants,oldMemoryIDList)
% To add or remove image memories to a sequence when total number of frames
% needed to changed and number of lines and bit depth are unchanged

% Determine number of frames to add/remove
oldNumFrames = numel(oldMemoryIDList);
numChans = sum(settings.channelsEnable);
extraFrames = numChans*ceil(settings.framerate*constants.secondsOfExtraFramesAtEndOfSequence/numChans);
newNumFrames = settings.framesetsToCapture*numChans + extraFrames;
frameDifference = newNumFrames - oldNumFrames;

% Clear sequence list
camHandle.Memory.Sequence.Clear;

if frameDifference < 0
    for freeIdx = -1:-1:frameDifference
        camHandle.Memory.Free(oldMemoryIDList(end+1+freeIdx)); % work backwards freeing memories at end of memory list
    end
    memoryIDList = oldMemoryIDList(1:(end+frameDifference)); % and pass along the rest to new list
    
elseif frameDifference >0
    memoryIDList = zeros([newNumFrames, 1],'int32');
    memoryIDList(1:oldNumFrames) = oldMemoryIDList; % pass along old list as start to new memory ID list
    for addIdx = 1:frameDifference
        [~,memoryIDList(oldNumFrames+addIdx)] = camHandle.Memory.Allocate(true);
    end

else
    memoryIDList = oldMemoryIDList;
    
end

% In either case update the new sequence list
camHandle.Memory.Sequence.Clear;
camHandle.Memory.Sequence.Add(memoryIDList);
[~,sequenceList] = camHandle.Memory.Sequence.GetList;