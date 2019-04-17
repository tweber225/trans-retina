function cropImg = crop_image(originalImg,xCenter,yCenter,zoomWidth)


% Find the x/y indicies to begin/end crop
xMin = xCenter - zoomWidth/2+1; 
xMax = xCenter + zoomWidth/2;
yMin = yCenter - zoomWidth/2+1; 
yMax = yCenter + zoomWidth/2;

% Crop image and export
cropImg = originalImg(yMin:yMax,xMin:xMax);


