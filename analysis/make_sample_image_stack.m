% Quick script to make a stack of sample images
% Translates, rotates, and varies the whole image intensity
clear all;
numFrames = 512;
baseImg = double(imread('cameraman.tif'));
rotList = (7 + 2*randn(numFrames,1)); % degrees to randomly translate
transList = 3*randn(numFrames,2);  % pixels x,y to randomly translate
intensityList = 1+0.1*randn(numFrames,1); % factor to multiply original image values by
noiseStd = 256*.05;

% Loop through and transform frames
maxShift = ceil(max(abs(transList)));
padBaseImg = padarray(baseImg,maxShift,0);
unregStack = zeros(size(padBaseImg,1),size(padBaseImg,2),numFrames);
padBaseImgSize = size(padBaseImg);

for frameIdx = 2:numFrames
    padRotImg = imrotate(padBaseImg,rotList(frameIdx),'crop','bilinear');
    frameTForm = affine2d([1 0 0; 0 1 0; transList(frameIdx,1) transList(frameIdx,2) 1]);
    unregStack(:,:,frameIdx) = intensityList(frameIdx)*imwarp(padRotImg,frameTForm,'OutputView',imref2d(padBaseImgSize));
end
unregStack(:,:,1) = padBaseImg;
rotList(1) = 0;
transList(1,:) = [0 0];
intensityList(1) = 1;

%% Find suitable area to crop
zerosStack = sum((unregStack == 0),3);
zeroImg = (zerosStack~=0);

% work out from center checking whether we have hit non-zeros
xLeftIdx = 1;
xLeft = 1;
xRightIdx = 1;
xRight = 1;
yBottomIdx = 1;
yBottom = 1;
yTopIdx = 1;
yTop = 1;
while (xLeft || xRight || yBottom || yTop)
    if xLeft
        xLeftIdx = xLeftIdx + 1;
        if (sum(sum(zeroImg((round(padBaseImgSize(1)/2)-yTopIdx):(round(padBaseImgSize(1)/2)+yBottomIdx),(round(padBaseImgSize(2)/2)-xLeftIdx):(round(padBaseImgSize(2)/2)+xRightIdx))))>0)
            xLeftIdx = xLeftIdx -1;
            xLeft = 0;
        end
    end
    
    if xRight
        xRightIdx = xRightIdx + 1;
        if (sum(sum(zeroImg((round(padBaseImgSize(1)/2)-yTopIdx):(round(padBaseImgSize(1)/2)+yBottomIdx),(round(padBaseImgSize(2)/2)-xLeftIdx):(round(padBaseImgSize(2)/2)+xRightIdx))))>0)
            xRightIdx = xRightIdx -1;
            xRight = 0;
        end
    end
    
    if yBottom
        yBottomIdx = yBottomIdx + 1;
        if (sum(sum(zeroImg((round(padBaseImgSize(1)/2)-yTopIdx):(round(padBaseImgSize(1)/2)+yBottomIdx),(round(padBaseImgSize(2)/2)-xLeftIdx):(round(padBaseImgSize(2)/2)+xRightIdx))))>0)
            yBottomIdx = yBottomIdx -1;
            yBottom = 0;
        end
    end
    
    if yTop
        yTopIdx = yTopIdx + 1;
        if (sum(sum(zeroImg((round(padBaseImgSize(1)/2)-yTopIdx):(round(padBaseImgSize(1)/2)+yBottomIdx),(round(padBaseImgSize(2)/2)-xLeftIdx):(round(padBaseImgSize(2)/2)+xRightIdx))))>0)
            yTopIdx = yTopIdx -1;
            yTop = 0;
        end
        
    end
end

% Make the cropped area square and also centered
[~,minDim] = min([(yTopIdx+yBottomIdx+1),(xLeftIdx+xRightIdx+1)]);
if (yTopIdx+yBottomIdx+1) == (xLeftIdx+xRightIdx+1)
    % then nothing is necessary, the cropped frame is will be square
elseif minDim == 1
    % Then x>y
    pixDiff = (xLeftIdx+xRightIdx+1) - (yTopIdx+yBottomIdx+1);
    xLeftIdx = xLeftIdx-floor(pixDiff/2);
    xRightIdx = xRightIdx-ceil(pixDiff/2);
else
    % Then y>x
    pixDiff = (yTopIdx+yBottomIdx+1) - (xLeftIdx+xRightIdx+1);
    yTopIdx = yTopIdx - floor(pixDiff/2);
    yBottomIdx = yBottomIdx - ceil(pixDiff/2);
end

% Also try to make even
if (mod((yTopIdx+yBottomIdx+1),2) ~= 0)
    yBottomIdx = yBottomIdx -1;
    xRightIdx = xRightIdx -1;
end

cropUnregStack = unregStack((round(padBaseImgSize(1)/2)-yTopIdx):(round(padBaseImgSize(1)/2)+yBottomIdx),(round(padBaseImgSize(2)/2)-xLeftIdx):(round(padBaseImgSize(2)/2)+xRightIdx),:);

% Finally add noise
cropUnregStack = cropUnregStack + noiseStd*randn(size(cropUnregStack));

for frameIdx = 1:numFrames
    imagesc(cropUnregStack(:,:,frameIdx));drawnow;

end





