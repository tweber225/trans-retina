% Load image and add subfolders
fundusImg = single(x568);
addpath(genpath('file_IO'));
addpath(genpath('subcode'));

% Parameters
startSearchRad = 5;
searchRad = 2;
maxTracePoints = 150;
seedSpacing = 30;

% Manually define where the optic disc is located in the image
[ODXCenter,ODYCenter,ODRad,ODXPoints,ODYPoints] = label_optic_disc(fundusImg);

% Manually define where the fovea is (to avoid)
[fovXCenter,fovYCenter,fovRad,fovXPoints,fovYPoints] = label_optic_disc(fundusImg);

% Automatically detect edge of image
[imgXCenter,imgYCenter,imgRad,imgXPoints,imgYPoints] = label_image_edge(fundusImg);


%% Tracing
% Show the image
imshow(norm_contrast(fundusImg));hold on;

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
for repIdx = 1:numel(xStartGr)
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
    directionVector = zeros(8,1);
    directionVector(1) = direction;

    traceX = zeros(maxTracePoints,1);
    traceY = zeros(maxTracePoints,1);
    for traceIdx = 1:maxTracePoints
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
        if (newMinPointX-xOD)^2 + (newMinPointY-yOD)^2 < ODRad^2
            % Then we've reached the optic disc, plot and exit
            line(traceX(traceX~=0),traceY(traceY~=0))
            plot(traceX(1),traceY(1),'go')
            tracks(:,:,repIdx) = [traceX,traceY];
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
        traceX(traceIdx) = minPointX;
        minPointY = newMinPointY;
        traceY(traceIdx) = minPointY;
        
    end % individual segment tracing
    if traceIdx == maxTracePoints
        line(traceX(traceX~=0),traceY(traceY~=0))
        plot(traceX(1),traceY(1),'go')
        tracks(:,:,repIdx) = [traceX,traceY];
    end
    drawnow
end % repeated segment tracing

% Take the tracks and make binary images from them