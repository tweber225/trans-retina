function [corrImgStk, hPixX, hPixY, hPixDeltaInt] = hot_pixel_correction(rawImgStk,medFiltRad,probCutOff)
% Function that detects, corrects, and reports hot pixels (pixels in an
% imaging array that are high or low outliers (some leakage voltage
% affecting the pixel or the pixel is dead, RIP). Usually their locations
% are random, but constant across several frames. We use that knowledge to
% differentiate them from accurate pixels. 2D linear interpolation is used
% to calculate a replacement value for the pixel at that location.

% Determine size of input image stack
[numYPix, numXPix, numFrames] = size(rawImgStk);

% If we have a stack rather than a single frame do a z projection and take
% the mean value
if numFrames >1
    disp('Mean projecting')
    meanStk = mean(rawImgStk,3);
else
    meanStk = rawImgStk;
end

% Median filter the mean image to filter out hot pixels
disp('Running median filtration')
medImg = medfilt2(meanStk,[medFiltRad medFiltRad],'symmetric');

% Subtracting the mean image from median image should reveal hot pixels
% with high contrast
diffImg = meanStk - medImg;

% Cropping to middle third of image for error statistics estimate
diffImgCrop = diffImg(round(numYPix/3):round(2*numYPix/3),round(numXPix/3):round(2*numXPix/3));

% Sort image and throw out top and bottom 0.5%'s (keep 99% of data to
% estimate a normal distribution without the outliers)
sortData = sort(diffImgCrop(:));
diffImgData = sortData(round(numel(sortData)*.005):round(numel(sortData)*.995));

% Fit all the difference values to a normal distribution that primarily
% describes residual error statistics. Hot pixels are defined by pixels
% with probability of being from the distribution < variable: probCutOff
disp('Fitting Data')
diffProbDist = fitdist(diffImgData,'Normal');
hPixMap = pdf(diffProbDist,diffImg) < probCutOff;
numHPix = sum(hPixMap(:));
disp(['Found ' num2str(numHPix) ' hot pixels'])

% Map out the coordinates
hPixX = hPixMap.*repmat(1:numXPix,[numYPix 1]);
hPixX = hPixX(hPixX>0);
hPixY = hPixMap.*repmat((1:numYPix)',[1 numXPix]);
hPixY = hPixY(hPixY>0);

% Allocate some image data for corrected stack
corrImgStk = rawImgStk;

disp('Correcting detected hot pixels in frames')
% Loop through all the frames and interpolate (linear) for new values at those hot pixels
% hPixMapComp = ~hPixMap;
% hPixCompX = hPixMapComp.*repmat(1:numXPix,[numYPix 1]);
% hPixCompX = hPixCompX(hPixCompX>0);
% hPixCompY = hPixMapComp.*repmat((1:numYPix)',[1 numXPix]);
% hPixCompY = hPixCompY(hPixCompY>0);
for frameIdx = 1:numFrames
    if mod(frameIdx,10) == 0
        disp(['Correcting frame #' num2str(frameIdx) ' of ' num2str(numFrames)]);
    end
    % pull out current frame and replace hot pixels with NaN
    currentFrame = rawImgStk(:,:,frameIdx);
    currentFrame(hPixMap) = NaN;
    filteredFrame = nanconv(currentFrame,ones(3)./9);
    correctedFrame = currentFrame;
    correctedFrame(hPixMap) = filteredFrame(hPixMap);
    corrImgStk(:,:,frameIdx) = correctedFrame;
end

hPixDeltaInt = 1;



