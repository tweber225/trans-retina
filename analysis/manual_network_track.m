% Script to manually track entire vessel network
%
% Vessels typically are picked up near the optic disc and run radially out
% Main vessels are given ID's 1,2,3, etc
% Vessel branches are ID'ed by their parent vessel and -1,-2,-3, etc
% Sub-sub-vessels are X-X-X, etc


% Assumes an image exists named "fundus"
[xPoints,yPoints] = manual_segment_track(fundus);

% Save points for first vessel segment
lastSegment = 1;
currentOrder = 1;
segments(lastSegment).ID = '1';
segments(lastSegment).xPoints = xPoints;
segments(lastSegment).yPoints = yPoints;

while true
    figure;
    imshow(norm_contrast(fundus)); hold on;
    title(['Last segment ID: ' segments(lastSegment).ID])
    line(segments(lastSegment).xPoints,segments(lastSegment).yPoints,'Color','red')
    for segmentIdx = 1:(lastSegment-1)
        lines(segments(segmentIdx).xPoints,segments(segmentIdx).yPoints,'Color','cyan')
    end

    prompt = ['Another segment of the same order (' currentOrder ') or sub-order or done with this branch? (same/sub/done) '];
    promptAnswer = input(prompt,'s');
    
    if strcmp(promptAnswer,'same')
        % Order does not change
        
    elseif strcmp(promptAnswer,'sub')
        % Order is incremented
        currentOrder = currentOrder+1;
        
    elseif strcmp(promptAnswer,'done')
        % Order is decremented
        currentOrder = currentOrder-1;
        if currentOrder == 0
            % Then we are finished with the network
            break
        end
    end
    
    
    
end



% Save segment data in text file
save_vessel_network(segments)