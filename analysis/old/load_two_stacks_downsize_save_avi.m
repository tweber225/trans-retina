% Note here that we assume the stacks have the same frame dimensions
% Parameters
AVIFrameRate = 11.3;

%% Determine the 1st stack to use
[tiffFileName,tiffPathName,~] = uigetfile({'*.tif;*.tiff', 'TIFF Files (*.tif,*.tiff)'});
tiffPathFileName = [tiffPathName tiffFileName];


% Load unregistered-absorbance frames
tiffFileInfo = imfinfo(tiffPathFileName); 
numFrames = numel(tiffFileInfo);
disp(['Loading: ' tiffPathFileName]);
tiffStackRaw1 = zeros(tiffFileInfo(1).Height,tiffFileInfo(1).Width,numFrames);
for frameIdx = 1:numFrames
    tiffStackRaw1(:,:,frameIdx) = imread(tiffPathFileName,frameIdx,'Info',tiffFileInfo);
end

%% Determine the 2nd stack to use
[tiffFileName,tiffPathName,~] = uigetfile({'*.tif;*.tiff', 'TIFF Files (*.tif,*.tiff)'});
tiffPathFileName = [tiffPathName tiffFileName];

% Load unregistered-absorbance frames
tiffFileInfo = imfinfo(tiffPathFileName); numFrames = numel(tiffFileInfo);
disp(['Loading: ' tiffPathFileName]);
tiffStackRaw2 = zeros(tiffFileInfo(1).Height,tiffFileInfo(1).Width,numFrames);
for frameIdx = 1:numFrames
    tiffStackRaw2(:,:,frameIdx) = imread(tiffPathFileName,frameIdx,'Info',tiffFileInfo);
end

% Make both even number of pixels width
frameHeight = size(tiffStackRaw1,1);
frameWidth = size(tiffStackRaw1,2);
newHeight = 2*floor(frameHeight/2); frameHeight = newHeight;
newWidth = 2*floor(frameWidth/2); frameWidth = newWidth;
tiffStackRaw1 = tiffStackRaw1(1:newHeight,1:newWidth,:);
tiffStackRaw2 = tiffStackRaw2(1:newHeight,1:newWidth,:);

%% Do stuff with the frame here (i.e. convert to 8-bit or something)

% Loop through frames adjusting the brightness and scaling to 8 bits
% (0-255)

tiffStack8Bit1 = zeros([frameHeight/2,frameWidth/2,numFrames],'uint8');
tiffStack8Bit2 = tiffStack8Bit1;
combinedStack = [tiffStack8Bit1 zeros([frameHeight/2,2,numFrames],'uint8') tiffStack8Bit2];
frameTimes = linspace(0,255/11.3,256);
for frameIdx = 1:numFrames
    % resize them
    currentFrameRaw1 = tiffStackRaw1(:,:,frameIdx);
    resizeFrame1 = imresize(currentFrameRaw1,0.5);
    currentFrameRaw2 = tiffStackRaw2(:,:,frameIdx);
    resizeFrame2 = imresize(currentFrameRaw2,0.5);
        
    maxCurrentFrame1 = max(resizeFrame1(:));
    minCurrentFrame1 = min(resizeFrame1(:));
    tiffStack8Bit1(:,:,frameIdx) = uint8(255.5*(resizeFrame1-minCurrentFrame1)/(maxCurrentFrame1-minCurrentFrame1));
    maxCurrentFrame2 = max(resizeFrame2(:));
    minCurrentFrame2 = min(resizeFrame2(:));
    tiffStack8Bit2(:,:,frameIdx) = uint8(255.5*(resizeFrame2-minCurrentFrame2)/(maxCurrentFrame2-minCurrentFrame2));
    
    % Combine into a single stack
    RGBImage = [tiffStack8Bit1(:,:,frameIdx) zeros([frameHeight/2,2],'uint8') tiffStack8Bit2(:,:,frameIdx)];
    
    % Add frameTime
    RGBImage = repmat(RGBImage,[1 1 3]);
    textString = [num2str(frameTimes(frameIdx),'%0.1f') ' sec'];
    position = [0 0];
    RGBImage = insertText(RGBImage,position,textString,'FontSize',28,'BoxOpacity',0.0,'TextColor','white');
    combinedStack(:,:,frameIdx) = RGBImage(:,:,1);
    imshow(RGBImage(:,:,1));drawnow;
    
end



%% Save as avi

% Convert grayscale to RGB
% combinedStack = permute(combinedStack,[1 2 4 3]);
% combinedStack = repmat(combinedStack,[1 1 3 1]);

% Add a blank line at the end
combinedStackToSave = [combinedStack ; zeros([3,frameWidth+2,numFrames],'uint8')];

clear v
aviFileName = 'combinedRawReg.avi';
aviPathFileName = [tiffPathName aviFileName];

v = VideoWriter(aviPathFileName,'Grayscale AVI');
v.FrameRate = AVIFrameRate;
%v.Quality = 100;
open(v)
writeVideo(v,combinedStackToSave)
close(v)


