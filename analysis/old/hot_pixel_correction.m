function [corrImgStk, hPixX, hPixY] = hot_pixel_correction(rawImgStk,medFiltRad,probCutOff,showAnalysis)
% Function that detects, corrects, and reports hot pixels (pixels in an
% imaging array that are high or low outliers (some leakage voltage
% affecting the pixel or the pixel is dead, RIP). Usually their locations
% are random, but constant across several frames. We use that knowledge to
% differentiate them from accurate pixels. 2D linear interpolation is used
% to calculate a replacement value for the pixel at that location.

disp('CORRECTING HOT PIXELS')
% Determine size of input image stack
[numYPix, numXPix, numFrames] = size(rawImgStk);

% If we have a stack rather than a single frame do a z projection and take
% the mean value
if numFrames >1
    meanStk = mean(double(rawImgStk),3);
else
    meanStk = rawImgStk;
end

% Median filter the mean-projected image to filter OUT hot pixels
disp('Running median filtration')
medImg = medfilt2(meanStk,[medFiltRad medFiltRad],'symmetric');

% Subtracting the mean image from median image should reveal hot pixels
% with high contrast
diffImg = meanStk - medImg;

% Cropping to middle third of image for error statistics estimate
diffImgCrop = diffImg(round(numYPix/3):round(2*numYPix/3),round(numXPix/3):round(2*numXPix/3));

% Sort image and throw out top and bottom 0.05%'s (keep 99.9% of data to
% estimate a normal distribution without the outliers)
sortData = sort(diffImgCrop(:));
diffImgData = sortData(round(numel(sortData)*.0005):round(numel(sortData)*.9995));

% Fit all the difference values to a normal distribution that primarily
% describes residual error statistics. Hot pixels are defined by pixels
% with probability of being from the distribution < variable: probCutOff
% Also prohibit hotpixels from being within medFiltRad away from image
% edge using a binary mask.
disp('Fitting Data')
binMask = padarray(ones(size(diffImg)-2*medFiltRad),[medFiltRad medFiltRad],0,'both');
diffProbDist = fitdist(diffImgData,'Normal');
hPixMap = (pdf(diffProbDist,diffImg) < probCutOff).*binMask;
numHPix = sum(hPixMap(:));
disp(['Found ' num2str(numHPix) ' hot pixels'])

% Map out the coordinates
hPixX = hPixMap.*repmat(1:numXPix,[numYPix 1]);
hPixX = hPixX(hPixX>0);
hPixY = hPixMap.*repmat((1:numYPix)',[1 numXPix]);
hPixY = hPixY(hPixY>0);

%% HOT PIXEL CORRECTION
disp('Correcting detected hot pixels in frames')

% Copy image data for corrected stack
corrImgStk = rawImgStk; % 16-bits images

%Make indexing coordinates
leftIdx = hPixX-1;
rightIdx = hPixX+1;
topIdx = hPixY-1;
bottomIdx = hPixY+1;

% Make bilinear weighting matrix
bilinWeights = ones(3);
bilinWeights([1 1 3 3],[1 3 1 3]) = 1/sqrt(2);

% Loop through all the frames and all hotpixels and interpolate (bilinear) for new values at those hot pixels
for hPixIdx = 1:numHPix
    disp(['Correcting Hot Pixel ' num2str(hPixIdx) ' of ' num2str(numHPix)]);
    for frameIdx = 1:numFrames
        currFrame = double(rawImgStk(:,:,frameIdx)); % uint16->double
        % Change values of hotpixels to NaN
        currFrame(logical(hPixMap)) = NaN;
        % Pull neighboring pixels to hotpixel
        neighborPix = currFrame(topIdx(hPixIdx):bottomIdx(hPixIdx),leftIdx(hPixIdx):rightIdx(hPixIdx)); 
        % Some pixels in the neighborhood (definitely including the
        % hotpixel itself) will be NaN
        NaNPixs = isnan(neighborPix);
        % Set NaN pixels to 0
        neighborPix(NaNPixs) = 0;
        % Modify the weighting matrix to throw out contributions from NaN
        % pixels
        modBilinWeights = bilinWeights.*(~NaNPixs);
        % Weighted-sum of neighboring pixels (excludes NaN's!) (Convert
        % back to uint16)
        corrImgStk(hPixY(hPixIdx),hPixX(hPixIdx),frameIdx) = uint16(sum(neighborPix(:).*modBilinWeights(:))/sum(modBilinWeights(:)));
    end
end


% Show map of hotpixels (relative the first frame)
if showAnalysis == 1
    figure;plot(hPixX,-hPixY,'*');
    title('Detected Hot Pixels (Relative The First Frame)');
    ylabel('Y Pixels')
    xlabel('X Pixels')
end

