function flattenedImageOutput = realtime_image_flattening(rawImage,imageMask,filterKernel,maxCamValue)
imgSize = size(rawImage,1);

% use image mask to get average value
meanValue = mean(rawImage(logical(imageMask)));

% paste average value into frame (same size as image)
meanValueImage = ones(imgSize).*meanValue;

% paste (simply add BG-subtracked image data) masked image data onto
% average frame
meanValueImage = meanValueImage + (rawImage-meanValue).*imageMask;

% Do low pass filtering
lpImage = filter2(filterKernel,meanValueImage,'same');

% Divide out original data by this low pass version
flattenedImage = meanValueImage./lpImage;

% scale appropriately to whole camera's dynamic range
minVal = min(flattenedImage(:));
maxVal = max(flattenedImage(:));
flattenedImageOutput = (flattenedImage-minVal).*(maxCamValue/(maxVal - minVal));