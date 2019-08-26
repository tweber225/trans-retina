% Load image and add subfolders
fundusImg = single(x568);
addpath(genpath('file_IO'));
addpath(genpath('subcode'));

% Parameters
startSearchRad = 2;
searchRad = 2.5;
maxTracePoints = 1000;
numDirectionsToAverage = 10;
seedSpacing = 10;

% Manually define where the optic disc is located in the image
[ODXCenter,ODYCenter,ODRad,ODXPoints,ODYPoints] = label_optic_disc(fundusImg);

% Manually define where the fovea is (to avoid)
[fovXCenter,fovYCenter,fovRad,fovXPoints,fovYPoints] = label_optic_disc(fundusImg);

% Automatically detect edge of image
[imgXCenter,imgYCenter,imgRad,imgXPoints,imgYPoints] = label_image_edge(fundusImg);

%% Image preprocessing
[xGr,yGr] = meshgrid(1:size(fundusImg,1),1:size(fundusImg,2));
ODMask = ( (xGr-ODXCenter).^2 + (yGr-ODYCenter).^2 < (ODRad*1.33)^2 );

% interpolate optic disc area
fundusInterp = regionfill(fundusImg,ODMask);

% median filter
fundusFilt = medfilt2(fundusInterp,[30 30]);
fundusFilt = imgaussfilt(fundusFilt);

% flattened image
fundusFlat = fundusImg./fundusFilt;
imshow(norm_contrast(fundusImg./fundusFilt,[.99 .001]))


%% Tracing
tic
% Show the image
imshow(norm_contrast(fundusImg,[.995 .1]));hold on;

% label optic disc and fovea locations
line(ODXPoints,ODYPoints,'Color','g');
line(fovXPoints,fovYPoints,'Color','r');

% label image edge
line(imgXPoints,imgYPoints,'Color','r');

% Make interpolation handle
imgInterpHand = griddedInterpolant(fundusImg,'nearest');

% Make non-random starting points
[xStartGr,yStartGr] = meshgrid(1:seedSpacing:size(fundusImg,2),1:seedSpacing:size(fundusImg,1));

% Make space to hold tracks
tracks = zeros(maxTracePoints,2,numel(xStartGr),'single');

typicalAngleRange = linspace(-pi/3,pi/3,8);
parfor repIdx = 1:numel(xStartGr)
    %disp(repIdx)
    % Find starting point
    xStart = xStartGr(repIdx);
    yStart = yStartGr(repIdx);
    if (xStart-imgXCenter)^2 + (yStart-imgYCenter)^2 > imgRad^2
        continue % we skip this iteration
    end
    
    % Determine direction towards optic disc
    towardsOD = atan2(yStart-ODYCenter,xStart-ODXCenter);

    % Interpolate circular arc around the selected point in direction of OD
    searchDirs =  towardsOD + linspace(-pi/2,pi/2,36);
    searchPointsX = xStart + startSearchRad*cos(searchDirs);
    searchPointsY = yStart + startSearchRad*sin(searchDirs);
    forwardArcProfile = imgInterpHand(searchPointsX,searchPointsY);

    % Find minimum along the circular path
    [~,minIdx] = min(forwardArcProfile);
    minPointX = searchPointsX(minIdx);
    minPointY = searchPointsY(minIdx);

    % Repeat
    searchPointsX = minPointX + searchRad*cos(searchDirs);
    searchPointsY = minPointY + searchRad*sin(searchDirs);
    forwardArcProfile = interp2(fundusImg,searchPointsX,searchPointsY);
    [minValue,minIdx] = min(forwardArcProfile);
    newMinPointX = searchPointsX(minIdx);
    newMinPointY = searchPointsY(minIdx);
    direction = atan2(newMinPointY-minPointY,newMinPointX-minPointX);

    % make the new points the "old" points
    minPointX = newMinPointX;
    minPointY = newMinPointY;

    % Make an "average" direction vector
    directionVector = zeros(numDirectionsToAverage,1);
    directionVector(1) = direction;

    trackX = zeros(maxTracePoints,1);
    trackY = zeros(maxTracePoints,1);
    for trackIdx = 1:maxTracePoints
        averageDirection = mean(directionVector(directionVector~=0));

        % Based on rolling average direction, compute new search directions
        searchDirs = averageDirection + typicalAngleRange;
        searchPointsX = minPointX + searchRad*cos(searchDirs);
        searchPointsY = minPointY + searchRad*sin(searchDirs);

        penaltyProfile = (minValue/100)*typicalAngleRange.^2;

        forwardArcProfile = interp2(fundusImg,searchPointsX,searchPointsY) + penaltyProfile;

        [minValue,minIdx] = min(forwardArcProfile);
        newMinPointX = searchPointsX(minIdx);
        newMinPointY = searchPointsY(minIdx);

        % Check whether the new point is inside OD zone or outside image
        if (newMinPointX-ODXCenter)^2 + (newMinPointY-ODYCenter)^2 < ODRad^2
            % Then we've reached the optic disc, save and exit
            tracks(:,:,repIdx) = [trackX,trackY];
            break
        end
        % Check whether we're still in valid image
        if (newMinPointX-imgXCenter)^2 + (newMinPointY-imgYCenter)^2 > imgRad^2
            break
        end
        % Check that we're not in fovea
        if (newMinPointX-fovXCenter)^2 + (newMinPointY-fovYCenter)^2 < fovRad^2
            break
        end

        directionVector = circshift(directionVector,1);
        directionVector(1) = atan2(newMinPointY-minPointY,newMinPointX-minPointX);
        minPointX = newMinPointX;
        trackX(trackIdx) = minPointX;
        minPointY = newMinPointY;
        trackY(trackIdx) = minPointY;
        
    end % individual segment tracing

end % repeated segment tracing
toc
%% Take the tracks and make binary images from them
% Remove all zero rows
validTracks = tracks(:,:,tracks(20,1,:)~=0); % skip tracks shorter than than 20
numValidTracks = size(validTracks,3);
binaryTracks = zeros(size(fundusImg,1),size(fundusImg,2),numValidTracks,'logical');
se=strel(strel('disk',1,4));
for repIdx = 1:numValidTracks
    
    xTrack = validTracks(:,1,repIdx); xTrack = xTrack(xTrack~=0);
    yTrack = validTracks(:,2,repIdx); yTrack = yTrack(yTrack~=0);
    
    interpX = interp1(xTrack,1:.25:numel(xTrack));
    interpY = interp1(yTrack,1:.25:numel(yTrack));
    
    for interpPointIdx = 1:numel(interpX)
        binaryTracks(round(interpY(interpPointIdx)),round(interpX(interpPointIdx)),repIdx) = 1;
    end
    binaryTracks(:,:,repIdx) = imdilate(binaryTracks(:,:,repIdx),se);
end

cumulativeBinaryTracks = uint8(sum(binaryTracks,3));
imshow(10*(cumulativeBinaryTracks-10))

%% Reorder tracks
% So intersection with optic disc is first point

for repIdx = 1:numValidTracks
    % Count the number of 0's left
    numZeros = sum(validTracks(:,1,repIdx) == 0);
    
    % Shift this ammount and flip the array, now we start at OD 
    validTracks(:,:,repIdx) = flipud(circshift(validTracks(:,:,repIdx),numZeros));
    
end

%% Trace out all the tracks
maxUniqueSegments = 256;
maxSegmentCopies = 32;
maxStartDist = 9;
maxSegmentDistance = 25;
searchAheadBehind = 25;
%trackOrder = randperm(numValidTracks);
% Make list to hold final segments first starting track
avgSegmentList = zeros(size(validTracks,1),2,maxUniqueSegments,'single');
segmentData = zeros(size(validTracks,1),2,maxUniqueSegments,maxSegmentCopies,'single');
segmentStartPoints = ones(maxUniqueSegments,1);
splitFromList = zeros(maxUniqueSegments,1);
avgSegmentList(:,:,1) = validTracks(:,:,trackOrder(1));
segmentData(:,:,1,1) = validTracks(:,:,trackOrder(1));
segmentIDList = (1:maxUniqueSegments)';
segmentStartPoints(1) = 1;
foundSegments = 1;

% Loop through rest of the tracks
for trackIdx = 2:numValidTracks
    
    % How far from starting point of other segments?
    startDist = sqrt(sum(squeeze((avgSegmentList(1,:,:) - validTracks(1,:,trackOrder(trackIdx))).^2)));
    possibleSegments = (startDist < maxStartDist)';
    
    if sum(possibleSegments) == 0 % If no others are close then it's a new segment
        avgSegmentList(:,:,(foundSegments+1)) = validTracks(:,:,trackOrder(trackIdx));
        segmentData(:,:,(foundSegments+1),1) = validTracks(:,:,trackOrder(trackIdx));
        segmentStartPoints(foundSegments+1) = 1;
        foundSegments = foundSegments+1;
        continue
    end
    
    % Loop through points in track
    minTracker = zeros(maxTracePoints,1,sum(possibleSegments),'single');
    for pointIdx = 1:maxTracePoints
    	% Compute distance from point to all possible segments
        pointsUnderConsideration = max(pointIdx-searchAheadBehind,1):min(pointIdx+searchAheadBehind,maxTracePoints);
        consideredCoords = (avgSegmentList(pointsUnderConsideration,:,possibleSegments));
        thisCoord = (validTracks(pointIdx,:,trackOrder(trackIdx)));
        thisCoordRep = repmat(thisCoord,[size(consideredCoords,1),1,sum(possibleSegments)]);
        distancesToPoint = sqrt(sum( (consideredCoords - thisCoordRep).^2, 2));
        
        % Find min distance
        minTracker(pointIdx,:,:) = min(distancesToPoint);
        
        % If the distance gets beyond a threshold, then eliminate
        % possibility 
        beyondThreshold = squeeze( minTracker(pointIdx,:,:) > maxSegmentDistance );
        if sum(beyondThreshold) > 0 % if we have hit that threshold

            if sum(possibleSegments)-sum(beyondThreshold) == 0 % If we're down to last possible segment
                % If we have just separated from 2(or more) possible
                % segments (at once), prioritize first one
                if sum(beyondThreshold) > 1
                    possibleSegments = possibleSegments & (cumsum(possibleSegments) == 1);
                    minTracker = minTracker(:,:,1);
                end
                
                % separate known part of segment from new part
                minTrackerNonZero = minTracker(minTracker~=0);
                leadingZeros = sum(cumsum(minTracker) == 0);
                intPnt = leadingZeros + floor(fit_piecewise_lines(double(minTrackerNonZero))); % everything up to this is known
                
                % Recursively put parts of the "known" segment into prior
                % segment entries
                parentSegment = segmentIDList(possibleSegments);
                parentEnd = intPnt;
                while parentSegment ~= 0
                    % Check how many copies of parent segment exist
                    parentCopyNum = sum( squeeze(segmentData(segmentStartPoints(parentSegment),1,parentSegment,:))~=0);
                    
                    % Check where the parent starts
                    parentStart = segmentStartPoints(parentSegment);

                    % Put part of the track into parent segment, recompute
                    segmentData(parentStart:parentEnd,:,parentSegment,parentCopyNum+1) = validTracks(parentStart:parentEnd,:,trackOrder(trackIdx));
                    dataToAvg = segmentData(parentStart:parentEnd,:,parentSegment,1:(parentCopyNum+1));
                    % Take median at every point, avoid 0's
                    newAvg = zeros(size(dataToAvg,1),2);
                    for pIdx = 1:size(dataToAvg,1)
                        newAvg(pIdx,:) = median(dataToAvg(pIdx,:,:,dataToAvg(pIdx,1,:,:)~=0),4);
                    end
                    avgSegmentList(parentStart:parentEnd,:,parentSegment) = newAvg;
                    
                    % Find the parent to this parent
                    parentSegment = splitFromList(parentSegment);
                    
                    % Designate next parent's end as this parent's start-1
                    parentEnd = parentStart-1;
                    
                    % Update possibleSegments variable for next parent
                    %possibleSegments = parentSegment==segmentIDList;
                end
                
                % Put the remainder into a new segment entry
                segmentData((intPnt+1):end,:,foundSegments+1,1) = validTracks((intPnt+1):end,:,trackOrder(trackIdx));
                segmentStartPoints(foundSegments+1) = intPnt+1;
                splitFromList(foundSegments+1) = segmentIDList(possibleSegments);
                avgSegmentList((intPnt+1):end,:,foundSegments+1) = validTracks((intPnt+1):end,:,trackOrder(trackIdx));
        
                foundSegments = foundSegments+1;
                break
            end %end last segment procedure
            oldPossibleSegments = possibleSegments;
            possibleSegments(possibleSegments) = ~beyondThreshold; % Remove the possible segment
            if sum(possibleSegments) < size(minTracker,3) % Maintain min tracker
                cumulativeOldPossSegs = cumsum(oldPossibleSegments);
                minTracker = minTracker(:,cumulativeOldPossSegs(possibleSegments));
            end

        end %end beyond a threshold in min tracker
        
        % Also check whether in range of another segment start point
        allSegmentsStart = zeros(maxUniqueSegments,2);
        for sIdx = 1:maxUniqueSegments
            allSegmentsStart(sIdx,:) = avgSegmentList(segmentStartPoints(sIdx),:,sIdx);
        end
        distanceToOtherStarts = sqrt(sum((allSegmentsStart - repmat(thisCoord,[size(allSegmentsStart,1) 1])).^2 ,2));
        startsInRange = distanceToOtherStarts < maxStartDist; % These are new starts
        oldPossibleSegments = possibleSegments;
        possibleSegments = possibleSegments | startsInRange;
        
        % Maintain min tracker
        if sum(possibleSegments) > size(minTracker,3)
            % Expand the min tracker, assure all the rows are saved&correct
            oldMinTracker = minTracker;
            minTracker = zeros(maxTracePoints,1,sum(possibleSegments),'single');
            cumulativePossSegs = cumsum(possibleSegments);
            minTracker(:,cumulativePossSegs(oldPossibleSegments)) = oldMinTracker;
        end
        
    end %end loop of points
    
    % Debuggin -- show as the 1st segment evolves
    imshow(norm_contrast(fundusImg,[.995 .1]));hold on;
    line(squeeze(avgSegmentList(:,1,1:4)),squeeze(avgSegmentList(:,2,1:4)));hold off
    drawnow
    
    if foundSegments == maxUniqueSegments
        break
    end
end

% Determine segments with high copy numbers
imagesc(squeeze(sum(segmentData(:,1,:,:) ~=0, 4)))

