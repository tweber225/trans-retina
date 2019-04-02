% Script to manually track entire vessel network
%
% Vessels typically are picked up near the optic disc and run radially out
% Main vessels are given ID's 1,2,3, etc
% Vessel branches are ID'ed by their parent vessel and -1,-2,-3, etc
% Sub-sub-vessels are X-X-X, etc

clear segments

% Assumes an image exists named "fundus"
[xPoints,yPoints] = manual_segment_track(fundus,'new_window');

% Save points for first vessel segment
lastSegment = 1;
currentOrder = 1;
segments(lastSegment).ID = '1';
segments(lastSegment).xPoints = xPoints;
segments(lastSegment).yPoints = yPoints;

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
    lastSegmentIDArray = segment_ID_to_array(segments(lastSegment).ID);

    % Ask what next segment type to track
    prompt = ['Another segment of the same order (' num2str(currentOrder) ') or sub-order or done with this branch? (same/sub/done) '];
    promptAnswer = input(prompt,'s');
    if strcmp(promptAnswer,'same')
        % Order does not change
        nextSegmentIDArray = lastSegmentIDArray(end) + 1;
    elseif strcmp(promptAnswer,'sub')
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
        nextSegmentIDArray = lastSegmentIDArray(1:(end-1));
        nextSegmentIDArray(end) = nextSegmentIDArray(end) + 1;
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
filePathName = 'network.txt';
save_vessel_network(segments,filePathName)


