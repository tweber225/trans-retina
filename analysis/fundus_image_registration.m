% ANALYSIS/FUNDUS IMAGE REGISTRATION
% Script to read in .tiff image stacks of fundus imagery, interactively
% choose a region in which to use for image to image registration, perform
% sub-pixel stabilization. We implement 2D rigid registration with 
% upsampling of cross-correlations

% Parameters
padFact = 16; % Factor in which to split original image pixels for sub-pixel image registration (~10X is usually fine)
movementTol = .75; % pixels per frame movement tolerance

% Load image stack info
[tiffFileName,tiffPathName,filtIdx] = uigetfile('*.tiff','Select TIFF File');
tiffFileInfo = imfinfo([tiffPathName filesep tiffFileName]);
numFrames = numel(tiffFileInfo);

% Allocate image array
rawFrames = ones(tiffFileInfo(1).Height,tiffFileInfo(1).Width,numFrames);

% Load frames sequentially
for frameIdx = 1:numFrames
    rawFrames(:,:,frameIdx) = imread([tiffPathName filesep tiffFileName], frameIdx, 'Info', tiffFileInfo);
end

% Determine image to use as template
templateImages = inputdlg('Enter frame numbers to use as average template(enter space-separated numbers):','Template Image', [1 60]);
templateImagesNum = str2double(templateImages{:}); 
templateImage = mean(rawFrames(:,:,templateImagesNum),3);
templateImageSc = (templateImage-min(templateImage(:)))./(max(templateImage(:))-min(templateImage(:)));

% Crop interactively
[~,rLims] = imcrop(templateImageSc);
x1 = round(rLims(1));
x2 = round(rLims(1)+rLims(3));
y1 = round(rLims(2));
y2 = round(rLims(2)+rLims(4));

% Flatten image fields
filtSize = 0.025*size(rawFrames,2);
templateMeanImageBlurred = imgaussfilt(templateImage,filtSize);
stackMeanImageBlurred = zeros(size(rawFrames));
for frameIdx = 1:numFrames
    stackMeanImageBlurred(:,:,frameIdx) = imgaussfilt(rawFrames(:,:,frameIdx),filtSize);
end

flattenedTemplate = templateImage./templateMeanImageBlurred;
flattenedCroppedTemplate = flattenedTemplate(y1:y2,x1:x2);

flattenedStack = rawFrames./stackMeanImageBlurred;
flattenedCroppedStack = flattenedStack(y1:y2,x1:x2,:);

padX = floor((padFact/2-.5)*size(flattenedCroppedTemplate,2));
padY = floor((padFact/2-.5)*size(flattenedCroppedTemplate,1));

% Cross correlations
clear xShift
clear yShift
padFlatCropTemplateFT = padarray(fftshift(fft2(flattenedCroppedTemplate-1)),[padY padX]);
for frameIdx = 1:numFrames  
    padFlatCropFrame = padarray(fftshift(fft2(flattenedCroppedStack(:,:,frameIdx)-1)),[padY padX]);
    xCorrDisplacement = ifftshift(ifft2(conj(padFlatCropTemplateFT).*padFlatCropFrame));
    [max_c, imax] = max(abs(xCorrDisplacement(:)));
    [yPeak, xPeak] = ind2sub(size(xCorrDisplacement),imax(1));
    xShift(frameIdx) = xPeak;
    yShift(frameIdx) = yPeak;
    disp(frameIdx)
end
xShift = xShift-xShift(1);
yShift = yShift-yShift(1);

% Pad Original Image Stack Enough
scaleFactorX = size(flattenedCroppedTemplate,2)/size(padFlatCropTemplateFT,2);
scaleFactorY = size(flattenedCroppedTemplate,1)/size(padFlatCropTemplateFT,1);
xShiftPix = xShift*scaleFactorX;
yShiftPix = yShift*scaleFactorY;
maxXShift = ceil(max(abs(xShiftPix)));
maxYShift = ceil(max(abs(yShiftPix)));
rawFramesPadded = padarray(rawFrames,[maxYShift+1, maxXShift+1]);

% Circularly shift an integer ammount then do bi-linear transform to get
% sub-pixel shifts
regFrames = zeros(size(rawFramesPadded));
for frameIdx = 1:numFrames
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

% Calculate velocities and find stable frames
ux = conv(xShift*scaleFactorX,[.5 0 -.5],'same');
uy = conv(yShift*scaleFactorY,[.5 0 -.5],'same');
stableFrames = abs(ux)<movementTol & abs(uy)<movementTol;

% Save registered stable frames data as tiff stack in same directory
filenameMinusExtension = tiffFileName(1:(end-5));
newFileNameAndPath = [tiffPathName filesep filenameMinusExtension '-regstable.tiff'];
saveastiff(single(regFrames(:,:,stableFrames)),newFileNameAndPath);


