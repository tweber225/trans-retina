function manual_network_track(capturePathName,channelNumber)
% Function to manually track entire vessel network
%
% Vessels typically are picked up near the optic disc and run radially out
% Main vessels are given ID's 1,2,3, etc
% Vessel branches are ID'ed by their parent vessel and -1,-2,-3, etc
% Sub-sub-vessels are X-X-X, etc
addpath(genpath('file_IO'));
addpath(genpath('subcode'));
finishedASegment = 0; % a flag

% Open image file
fileName = ['channel' num2str(channelNumber) 'averaged.tif'];
imagePathFileName = [capturePathName filesep 'analysis' filesep fileName];
fundus = single(loadtiff(imagePathFileName));

% Double-check that networks for this capture does not exist
if isfile([capturePathName filesep 'analysis' filesep 'network.txt'])
    disp('Record of vessel network already exists for this.')
    
    usersAnswer = input('Would you like to append segments to the existing network? (y/n)','s');
    if usersAnswer == 'y'
        % Then we need to open the old file, read the segment data
        segments = load_vessel_network([capturePathName filesep 'analysis' filesep 'network.txt']);
        
        % Set some tracking parameters
        lastSegment = numel(segments);
        currentOrder = numel(segment_ID_to_array(segments(lastSegment).ID));
    else
        error('Record of vessel network already exists for this. Exiting program.')
    end
    
else
   % Track the first vessel
    [xPoints,yPoints] = manual_segment_track(fundus,'new_window');

    % Save points for first vessel segment
    lastSegment = 1;
    currentOrder = 1;
    segments(lastSegment).ID = '1';
    segments(lastSegment).xPoints = xPoints;
    segments(lastSegment).yPoints = yPoints; 
end



while true
    
    % Show the last vessel segment in red & other selected segments in cyan
    figure;
    imshow(norm_contrast(fundus)); hold on;
    title(['Last segment ID: ' segments(lastSegment).ID])
    line(segments(lastSegment).xPoints,segments(lastSegment).yPoints,'Color','red')
    for segmentIdx = 1:(lastSegment-1)
        line(segments(segmentIdx).xPoints,segments(segmentIdx).yPoints,'Color','cyan')
    end
    
    % Compute the numeric array of last vessel ID
    if finishedASegment ~= 0
        lastSegmentIDArray = segment_ID_to_array(segments(lastSegment).ID);
        lastSegmentIDArray = lastSegmentIDArray(1:end-finishedASegment);
    else
        lastSegmentIDArray = segment_ID_to_array(segments(lastSegment).ID);
    end

    % Ask what next segment type to track
    prompt = ['Another segment of the same order (' num2str(currentOrder) ') or sub-order or done with this branch? (same/sub/done) '];
    promptAnswer = input(prompt,'s');
    if strcmp(promptAnswer,'same')
        finishedASegment = 0;
        % order # does not change, just increment the last digit in ID
        nextSegmentIDArray = lastSegmentIDArray;
        nextSegmentIDArray(end) = lastSegmentIDArray(end) + 1;
    elseif strcmp(promptAnswer,'sub')
        finishedASegment = 0;
        % Order is incremented
        currentOrder = currentOrder+1;
        nextSegmentIDArray = [lastSegmentIDArray,1];
    elseif strcmp(promptAnswer,'done')
        % Order is decremented
        currentOrder = currentOrder-1;
        if currentOrder == 0
            % Then we are finished with the network
            break
        end
        finishedASegment = finishedASegment+1;
        continue
    end
    
    % Start tracking next segment - use the last figure window as
    [xPoints,yPoints] = manual_segment_track(fundus,'hold window');
    
    % Save these points and note the segment ID
    lastSegment = lastSegment+1;
    segments(lastSegment).ID = segment_array_to_ID(nextSegmentIDArray);
    segments(lastSegment).xPoints = xPoints;
    segments(lastSegment).yPoints = yPoints;
    
end

% Save segment data in text file
networkPathName = [capturePathName filesep 'analysis' filesep 'network.txt'];
save_vessel_network(segments,networkPathName)


