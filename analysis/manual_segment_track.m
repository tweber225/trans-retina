function [xPoints,yPoints] = manual_segment_track(img,specialFlag)
% Function takes in an image and prompts user to manually track the center
% of a vessel. Outputs a Nx2 list (x and y coordinates) of user-selected
% points
scaleFactor = 6;
zoomWidth = 128;
blurFactor = 12;

% Normalize the image contrast
img = single(img);
normImg = norm_contrast(img);

% Zoom into area of interest first
if ~strcmp(specialFlag, 'hold window')
    imshow(normImg)
end
[x,y] = getpts; 
close
xCenter = round(x); 
yCenter = round(y);

% Crop the image to zoomed area
cropImg = crop_image(normImg,xCenter,yCenter,zoomWidth);

% Zoom image and flatten contrast for best visibilty
zoomedImg = imresize(cropImg,scaleFactor,'nearest');
blurredImg = imgaussfilt(zoomedImg,scaleFactor*blurFactor);
flattenImg = zoomedImg./blurredImg;
flattenNormImg = norm_contrast(flattenImg);

% Display the zoomed image and collect points
imshow(flattenNormImg)
[xi,yi] = getpts;
numPoints = length(xi);
close

% Calculate the collected points in original (non-upsampled) coordinates
xPoints = x + (xi-scaleFactor*zoomWidth/2)/scaleFactor;
yPoints = y + (yi-scaleFactor*zoomWidth/2)/scaleFactor;

while true
    % Ask user if more points are desired
    prompt = 'Gather more points for this segment? (y/n)';
    promptAnswer = input(prompt,'s');
    if promptAnswer == 'n'
        % Done, pass on the data
        break
    elseif promptAnswer == 'y'
        % Repeat the process above, with the zoomed region centered on last
        % point
        xCenterNew = round(xPoints(end));
        yCenterNew = round(yPoints(end));    

        % Crop the image to zoomed area
        cropImg = crop_image(normImg,xCenterNew,yCenterNew,zoomWidth);

        % Zoom image and flatten contrast for best visibilty
        zoomedImg = imresize(cropImg,scaleFactor,'nearest');
        blurredImg = imgaussfilt(zoomedImg,scaleFactor*blurFactor);
        flattenImg = zoomedImg./blurredImg;
        flattenNormImg = norm_contrast(flattenImg);

        % Calculate where the last point is in the new zoom frame (should be
        % near the center
        lastPointsX = (xPoints-xCenterNew)*scaleFactor + scaleFactor*zoomWidth/2;
        lastPointsY = (yPoints-yCenterNew)*scaleFactor + scaleFactor*zoomWidth/2;

        % Display the zoomed image (with old points) and collect more points
        imshow(flattenNormImg); hold on;
        line(lastPointsX,lastPointsY)
        [xiNew,yiNew] = getpts;
        close
        
        % Convert the new points to the original coordinate system
        xNewPoints = xCenterNew + (xiNew-scaleFactor*zoomWidth/2)/scaleFactor;
        yNewPoints = yCenterNew + (yiNew-scaleFactor*zoomWidth/2)/scaleFactor;
        
        % Add them to the list
        xPoints = [xPoints;xNewPoints];
        yPoints = [yPoints;yNewPoints];
    else
        % What?
        disp('Wrong answer!')
    end
end

