clear all
% Base image
I = imread('avg.tif');
I = I(:,129:end-128); % make square

% Parameters of random stack
angleMag = 8; % in mrad
transMag = 15; % in pixels
noiseMag = 2.5; % additional noise, in unit8 base
numFrames = 64*8;
rotGround = angleMag*randn(numFrames,1)*1e-3; %ground=ground truth
transGround = transMag*randn(numFrames,2);

% Set the first frame's translation and rotation to 0
rotGround(1:2) = 0;
transGround(1,:) = 0;

% Make the random stack
IStack = zeros(size(I,1),size(I,2),numFrames,'single');
for x = 1:numFrames
    
    ITrans = imtranslate(I,transGround(x,:)); % assumes square image
    IRot = imrotate(double(ITrans),rad2deg(rotGround(x)),'bilinear','crop');
    
    IStack(:,:,x) = single(IRot + 256*noiseMag*randn(size(I)));
end

% Crop the stack and apply aperture
cropPix = 256;
IStack = IStack((cropPix+1):(end-cropPix),(cropPix+1):(end-cropPix),:);
apertureRadius = 256+45;
x = -256:255;
[xg,yg] = meshgrid(x,x);
apWindow = imgaussfilt(double(xg.^2 + yg.^2 < apertureRadius^2),2);
IStack = IStack.*apWindow(:,:,ones(1,numFrames));

for x = 1:numFrames
    imshow(uint8(IStack(:,:,x)/256),'InitialMagnification',100)
    drawnow;
    pause(.05)
end

% Apply standard registration parameters
regOpt.skipRotation = 0; % flag to skip rotational registration
regOpt.regBWRadius = 80/2; % specify the radius of DFT frequencies to use, set to <1 to use selector
regOpt.refFrameNumber = 1;
regOpt.maxAngle = 100e-3; % mrad
regOpt.angleRes = 0.05e-3; % mrad - rotational precision
regOpt.rhoMin = 8/2; % min pixel radius range to use in rotation detection
regOpt.polDFTUpSampleFactor = 5; % Seems to give abs error <1% based on ...
%... small tests against an explicitly computed DFT at polar points
regOpt.polDFTChunkSize = 64; % Frames to polar-fft at once, 64 seems to be optimal on TDW's desktop
regOpt.minRhoTrans = 8/2;
regOpt.subPixelPrecision = 1/64; % sub-pixel translation precision
regOpt.pixelZoomRange = 1.5; % range of pixels in which to zoom in around course estimate of peak
regOpt.transChunkSize = 64; % # frames to detect translation in at once
regOpt.dateComputed = string(datetime);

% Register the sequence
[hyperList,regOpt] = register_single_sequence(IStack,regOpt);


% Plot detected rotation + translation vs ground truth values
figure;
plot(1:numFrames,hyperList.rotHList,1:numFrames,rotGround)
ylabel('Rotation')

figure;
plot(1:numFrames,hyperList.transHList,1:numFrames,transGround);
ylabel('Translation')

rmsRotError = mean(abs(hyperList.rotHList-rotGround))
rmsTransError = mean(abs(hyperList.transHList-transGround))