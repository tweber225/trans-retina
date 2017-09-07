% ANALYSIS/MULTICOLOR FUNDUS IMAGE REGISTRATION
% Script to read in several (>1) different color image channels and
% register one another We implement 2D rigid registration with upsampling
% of cross-correlations

% Parameters
padFact = 8; % Factor in which to split original image pixels for sub-pixel image registration (~10X is usually fine)

% Determine number of spectral channels
numColorChannelsResponse = inputdlg('Enter Number of Spectral Channels','Color Channels', [1 30]);
numColorChans = str2double(numColorChannelsResponse{:}); 

% Load the first image info to get width/height
[tiffFileName,tiffPathName,~] = uigetfile('*.tiff','Select First TIFF Image File');
tiffFileInfo = imfinfo([tiffPathName filesep tiffFileName]);

% Allocate space and load first image data
rawFrames = zeros(tiffFileInfo(1).Height,tiffFileInfo(1).Width,numColorChans);
rawFrames(:,:,1) = imread([tiffPathName filesep tiffFileName],'Info', tiffFileInfo);

% Load subsequent images
for chanIdx = 2:numColorChans
    [tiffFileName,tiffPathName,~] = uigetfile('*.tiff',['Select TIFF File #' num2str(chanIdx)]);
    rawFrames(:,:,chanIdx) = imread([tiffPathName filesep tiffFileName]);
end

% Crop interactively off the first frame
firstFrameNormed = (rawFrames(:,:,1)-min(min(rawFrames(:,:,1))))/(max(max(rawFrames(:,:,1)))-min(max(rawFrames(:,:,1))));
[~,rLims] = imcrop(firstFrameNormed);
x1 = round(rLims(1));
x2 = round(rLims(1)+rLims(3));
y1 = round(rLims(2));
y2 = round(rLims(2)+rLims(4));

% Make a cropped stack of images
croppedFrames = rawFrames(y1:y2,x1:x2,:);

% Flatten image fields (over whole images, not cropped)
filtSize = 0.005*size(rawFrames,2);
firstImageBlurred = imgaussfilt(rawFrames(:,:,1),filtSize);
stackBlurred = zeros(size(rawFrames));
for frameIdx = 1:numColorChans
    stackBlurred(:,:,frameIdx) = imgaussfilt(rawFrames(:,:,frameIdx),filtSize);
end

flattenedFirstFrame = rawFrames(:,:,1)./firstImageBlurred;
flattenedCroppedFirstFrame = flattenedFirstFrame(y1:y2,x1:x2);

flattenedStack = (rawFrames./stackBlurred)-1;
flattenedCroppedStack = flattenedStack(y1:y2,x1:x2,:);
flattenedCroppedStackNormed = flattenedCroppedStack./repmat(min(min(flattenedCroppedStack)),[size(flattenedCroppedStack,1) size(flattenedCroppedStack,2) 1]);

padX = floor((padFact/2-.5)*size(flattenedCroppedFirstFrame,2));
padY = floor((padFact/2-.5)*size(flattenedCroppedFirstFrame,1));

% Cross correlations
clear xShift
clear yShift
%padFlatCropFirstFrameFT = padarray(fftshift(fft2(flattenedCroppedFirstFrame-1)),[padY padX]);
padFlatCropFirstFrameFT = padarray(fftshift(fft2(flattenedCroppedStackNormed(:,:,1)>0.25)),[padY padX]);
for frameIdx = 1:numColorChans  
    %padFlatCropFrameFT = padarray(fftshift(fft2(flattenedCroppedStack(:,:,frameIdx)-1)),[padY padX]);
    frameToUse = flattenedCroppedStackNormed(:,:,frameIdx)>0.25;
    padFlatCropFrameFT = padarray(fftshift(fft2(frameToUse)),[padY padX]);
    xCorrDisplacement = ifftshift(ifft2(conj(padFlatCropFirstFrameFT).*padFlatCropFrameFT));
    subplot(1,3,1);imagesc(abs(xCorrDisplacement));subplot(1,3,2);imagesc(frameToUse);colorbar;subplot(1,3,3);imagesc(flattenedCroppedStackNormed(:,:,frameIdx))
    [max_c, imax] = max(abs(xCorrDisplacement(:)));
    [yPeak, xPeak] = ind2sub(size(xCorrDisplacement),imax(1));
    xShift(frameIdx) = xPeak;
    yShift(frameIdx) = yPeak;
    disp(frameIdx)
    pause(1)
end
xShift = xShift-xShift(1);
yShift = yShift-yShift(1);

% Pad original stack enough for shifting
scaleFactorX = size(flattenedCroppedFirstFrame,2)/size(padFlatCropFirstFrameFT,2);
scaleFactorY = size(flattenedCroppedFirstFrame,1)/size(padFlatCropFirstFrameFT,1);
xShiftPix = xShift*scaleFactorX;
yShiftPix = yShift*scaleFactorY;
maxXShift = ceil(max(abs(xShiftPix)));
maxYShift = ceil(max(abs(yShiftPix)));
rawFramesPadded = padarray(rawFrames,[maxYShift+1, maxXShift+1]);

% Circularly shift an integer ammount then do bi-linear transform to get
% sub-pixel shifts
regFrames = zeros(size(rawFramesPadded));
for frameIdx = 1:numColorChans
    intShiftX = floor(xShiftPix(frameIdx));
    intShiftY = floor(yShiftPix(frameIdx));
    subPixShiftX = xShiftPix(frameIdx)-intShiftX;
    subPixShiftY = yShiftPix(frameIdx)-intShiftY;
    
    shiftedImg = circshift(rawFramesPadded(:,:,frameIdx),[-intShiftY -intShiftX ]);
    shiftedImg = conv2(shiftedImg,[subPixShiftX, 1-subPixShiftX],'same');
    regFrames(:,:,frameIdx) = conv2(shiftedImg,[subPixShiftY; 1-subPixShiftY],'same');
    
    imagesc(regFrames(:,:,frameIdx)), colormap gray
    pause(.1)
end

% Save registered data as tiff stack in same directory
filenameMinusExtension = tiffFileName(1:(end-5));
newFileNameAndPath = [tiffPathName filesep filenameMinusExtension '-reg.tiff'];
saveastiff(single(regFrames),newFileNameAndPath);




