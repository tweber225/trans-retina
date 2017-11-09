function rotStack = rot_stack(inputStack,rotList)
% ANALYSIS/ROT_STACK
% Rotates (bilinear interpolation) each frame of the stack by the amount
% specified in rotList
% 
% Part 3e of standard image processing pipeline
% Timothy D. Weber
% Biomicroscopy Lab, BU 2017

% Get size
[pixWidth,~,numFrames] = size(inputStack);

% Allocate rotated stack
rotStack = zeros(pixWidth,pixWidth,numFrames);

% Loop through all frames applying the rotation
for frameIdx = 1:numFrames
    rotStack(:,:,frameIdx) = imrotate(inputStack(:,:,frameIdx),-rotList(frameIdx),'bilinear','crop');
end