% Parameters
AVIFrameRate = 2.5;

% Determine the stack to use
[tiffFileName,tiffPathName,~] = uigetfile({'*.tif;*.tiff', 'TIFF Files (*.tif,*.tiff)'});
tiffPathFileName = [tiffPathName tiffFileName];
aviFileName = [tiffFileName '.avi'];

%% Load unregistered-absorbance frames
tiffFileInfo = imfinfo(tiffPathFileName); numFrames = numel(tiffFileInfo);
disp(['Loading: ' tiffPathFileName]);
for frameIdx = 1:numFrames
    tiffStackRaw(:,:,frameIdx) = imread(tiffPathFileName,frameIdx,'Info',tiffFileInfo);
end


%% Do stuff with the frame here (i.e. convert to 8-bit or something)

frameWidth = size(tiffStackRaw,1);
meshIndex = (-frameWidth/2+.5):(frameWidth/2);
[xGr,yGr] = meshgrid(meshIndex,meshIndex);
binMaskCircle = double(((xGr.^2 + yGr.^2) <= (frameWidth/2)^2));
binMaskCircle = imgaussfilt(binMaskCircle,1.5);

% Loop through frames adjusting the brightness and scaling to 8 bits
% (0-255)
tiffStack8Bit = zeros(size(tiffStackRaw),'uint8');
for frameIdx = 1:numFrames
    currentFrameRaw = tiffStackRaw(:,:,frameIdx);
    
    % Also multiply by a mask to get rid of stuff on edges of circle
    currentFrameRaw = currentFrameRaw.*binMaskCircle;
    
    maxCurrentFrame = max(currentFrameRaw(:));
    minCurrentFrame = min(currentFrameRaw(:));
    tiffStack8Bit(:,:,frameIdx) = uint8(255.5*(currentFrameRaw-minCurrentFrame)/(maxCurrentFrame-minCurrentFrame));
    
    % Add pixel kernel label
    RGBImage = repmat(tiffStack8Bit(:,:,frameIdx),[1 1 3]);
    textString = ['filter rad: ' num2str(frameIdx) ' pix'];
    position = [0 0];
    RGBImage = insertText(RGBImage,position,textString,'FontSize',28,'BoxOpacity',0.0,'TextColor','white');
    tiffStack8Bit(:,:,frameIdx) = RGBImage(:,:,1);
    
end


%% Save as avi
aviPathFileName = [tiffPathName aviFileName];

v = VideoWriter(aviPathFileName,'Grayscale AVI');
v.FrameRate = AVIFrameRate;
open(v)
writeVideo(v,[tiffStack8Bit tiffStack8Bit])
close(v)


