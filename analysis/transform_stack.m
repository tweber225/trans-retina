function transformedStack = transformStack(inputStack,rotList,transList)
% ANALYSIS/ROT_STACK
% Rotates and translates (bilinear interpolation) each frame of the stack by the amount
% specified in rotList
% 
% Part 3e of standard image processing pipeline
% Timothy D. Weber
% Biomicroscopy Lab, BU 2017

% Get size
[pixWidth,~,numFrames] = size(inputStack);

% Allocate rotated stack
rotStack = zeros(pixWidth,pixWidth,numFrames);

% Loop through all frames applying the rotation, and translation
for frameIdx = 1:numFrames
    rotStack(:,:,frameIdx) = imrotate(inputStack(:,:,frameIdx),-rotList(frameIdx),'bilinear','crop');
end