greenImg = double(x568);
% First define where the optic disc is located in the image
imshow(norm_contrast(greenImg))
[xOD,yOD] = getpts;
ODRad = 70;
ODPointsX = xOD + ODRad*cos(linspace(0,2*pi,36));
ODPointsY = yOD + ODRad*sin(linspace(0,2*pi,36));
close


% Get 2 starting points: first point is the actual
% starting point and second indicates direction to proceed
imshow(norm_contrast(greenImg))
[xPts,yPts] = getpts;

% Calculate starting direction
firstXPt = xPts(1); firstYPt = yPts(1);
startingDirection = atan2(yPts(2)-yPts(1),xPts(2)-xPts(1));


% Interpolate circular stretch around the selected point
searchRad = 2;
searchDirs = startingDirection + linspace(-pi/3,pi/3,36);
searchPointsX = firstXPt + searchRad*cos(searchDirs);
searchPointsY = firstYPt + searchRad*sin(searchDirs);

forwardArcProfile = interp2(greenImg,searchPointsX,searchPointsY);

% Find minimum along the circular path
[~,minIdx] = min(forwardArcProfile);
minPointX = searchPointsX(minIdx);
minPointY = searchPointsY(minIdx);

% Repeat
searchPointsX = minPointX + searchRad*cos(searchDirs);
searchPointsY = minPointY + searchRad*sin(searchDirs);
forwardArcProfile = interp2(greenImg,searchPointsX,searchPointsY);
[minValue,minIdx] = min(forwardArcProfile);
newMinPointX = searchPointsX(minIdx);
newMinPointY = searchPointsY(minIdx);
direction = atan2(newMinPointY-minPointY,newMinPointX-minPointX);
line([newMinPointX,minPointX],[newMinPointY,minPointY]);hold on;

% make the new points the "old" points
minPointX = newMinPointX;
minPointY = newMinPointY;

% Make an "average" direction vector
directionVector = zeros(10,1);
directionVector(:) = direction;

% Show the optic disc zone
line(ODPointsX,ODPointsY,'Color','g');

for repIdx = 1:1000
    averageDirection = mean(directionVector);
    
    % Based on rolling average direction, compute new search directions
    searchDirs = averageDirection + linspace(-pi/3,pi/3,36);
    searchPointsX = minPointX + searchRad*cos(searchDirs);
    searchPointsY = minPointY + searchRad*sin(searchDirs);
    %line(searchPointsX,searchPointsY,'Color','r')
    
    penaltyProfile = (minValue/100)*linspace(-pi/3,pi/3,36).^2;
    
    forwardArcProfile = interp2(greenImg,searchPointsX,searchPointsY)+penaltyProfile;
    
    [minValue,minIdx] = min(forwardArcProfile);
    newMinPointX = searchPointsX(minIdx);
    newMinPointY = searchPointsY(minIdx);
    
    % Check whether the new point is inside OD zone
    if (newMinPointX-xOD)^2 + (newMinPointY-yOD)^2 < ODRad^2
        break
    end
    
    directionVector = circshift(directionVector,1);
    directionVector(1) = atan2(newMinPointY-minPointY,newMinPointX-minPointX);
    line([newMinPointX,minPointX],[newMinPointY,minPointY])
    minPointX = newMinPointX;
    minPointY = newMinPointY;
    
    drawnow
end