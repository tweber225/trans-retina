function fusedList = fuse_reg_paths(hyperList,regOpt)

% Convert the registration data lists to matrices
rotHList = [hyperList.rotHList];

numFrames = size(rotHList,1);
numChannels = size(rotHList,2);

transHList = reshape([hyperList.transHList],[numFrames,2,numChannels]);
rotPeakHList = [hyperList.rotPeakHList];
transPeakHList = [hyperList.transPeakHList];

% If there's just one channel then use this rot/trans list
if size(rotHList,2) == 1
    fusedRotList = squeeze(rotHList);
    fusedTransList = squeeze(transHList);
    
else % Otherwise, we need to do some interpolation to match channels
    
    baseFrameNumbers = 0:(numFrames-1);
    
    % Interpolate each channel's registration into Channel 1's frame times
    transInterp = zeros(numFrames-1,2,numChannels);
    rotInterp = zeros(numFrames-1,numChannels);
    for cIdx = 1:numChannels
        channelFrameNumbers = baseFrameNumbers + (cIdx-1)/numChannels;
        transInterp(:,:,cIdx) = interp1(channelFrameNumbers,transHList(:,:,cIdx),baseFrameNumbers(2:end));
        rotInterp(:,cIdx) = interp1(channelFrameNumbers,rotHList(:,cIdx),baseFrameNumbers(2:end));
    end
    
    % Compute channel offsets in each registration coordinate
    rotOffset = mean(rotInterp - rotHList(2:end,ones(1,numChannels)));
    transOffset = mean(transInterp - transHList(2:end,:,ones(1,numChannels)));
    correctedRotList = rotHList - rotOffset(ones(1,numFrames),:);
    correctedTransList = transHList - transOffset(ones(1,numFrames),:,:);
        
    % Try filtering results
    rotFullList = reshape(permute(correctedRotList,[2 1]),[numFrames*numChannels,1]);
    transFullList = reshape(permute(correctedTransList,[3 1 2]),[numFrames*numChannels,2]);
    spanRangeRot = regOpt.rotRegSmoothSpan/(numFrames*numChannels);
    spanRangeTrans = regOpt.transRegSmoothSpan/(numFrames*numChannels);
    smoothRot = smooth(rotFullList,spanRangeRot,'loess');
    smoothX = smooth(transFullList(:,1),spanRangeTrans,'loess');
    smoothY = smooth(transFullList(:,2),spanRangeTrans,'loess');
    fullFrameList = 0:(1/numChannels):(numFrames-.01);
    
    % plot some of the results
    figure; hold on;
    plot(fullFrameList,smoothX,'k');
    plot(fullFrameList,smoothY,'k');
    for cIdx = 1:numChannels
        plot(baseFrameNumbers+(cIdx-1)/numChannels,correctedTransList(:,:,cIdx),'.'); 
    end
    hold off
    
    figure; hold on;
    plot(fullFrameList,smoothRot,'k');
    for cIdx = 1:numChannels
        plot(baseFrameNumbers+(cIdx-1)/numChannels,correctedRotList(:,cIdx),'.'); 
    end
    hold off
    
    % Reorder filtered list 
    fusedRotList = permute(reshape(smoothRot,[numChannels numFrames]),[2 1]);
    fusedTransList = permute(reshape([smoothX,smoothY],[numChannels numFrames 2]),[2 3 1]);
    
end

fusedList.rot = fusedRotList;
fusedList.trans = fusedTransList;