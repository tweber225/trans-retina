function [transformedStack,xSpace,ySpace] = transform_stack(inputStack,rotList,transList,showAnalysis)
% ANALYSIS/ROT_STACK
% Rotates and translates (bilinear interpolation) each frame of the stack by the amount
% specified in rotList
%
% inputStack should be 16 bit, each frame is converted to double precision,
% transform is applied, and frame is converted back to 16 bit to output
% stack
% 
% Part 3e of standard image processing pipeline
% Timothy D. Weber
% Biomicroscopy Lab, BU 2017

% Get size of input stack
[pixWidth,~,numFrames] = size(inputStack);

% Compute padding requirements from maximum translational shifts
xSpace = ceil(max(abs(transList(:,1))))+1;
ySpace = ceil(max(abs(transList(:,2))))+1;

% Compute integral translational shifts
intShift = ceil(transList);

% Compute sub-pixel translational shifts
subShift = intShift-transList;

% Allocate space for registered stack
transformedStack = zeros(pixWidth+2*ySpace,pixWidth+2*xSpace,numFrames,'uint16');

% Loop through all frames applying the rotation, and translation
if showAnalysis == 1,figure;end
for frameIdx = 1:numFrames
    % Note: do all the intermediate image transforms in double-prec, then
    % convert to uint16 on the last step
    % Rotate a symmetrically padded version of the current input frame
    transformedFrame = imrotate(padarray(double(inputStack(:,:,frameIdx)),[ySpace xSpace],0,'both'),-rotList(frameIdx),'bilinear','crop');
    
    % Translation: circular shift integral number of pixels
    transformedFrame = circshift(transformedFrame,fliplr(-intShift(frameIdx,:)));
    
    % Translation: bilinear transform via 2 convolutions for sub-pixel shifts
    transformedFrame = conv2(transformedFrame,[(1-subShift(frameIdx,1)),subShift(frameIdx,1)],'same');
    transformedFrame = conv2(transformedFrame,[(1-subShift(frameIdx,2));subShift(frameIdx,2)],'same');
    transformedStack(:,:,frameIdx) = uint16(transformedFrame);

    % Show frames in video
    if showAnalysis == 1
        imshow(transformedFrame,[min(transformedFrame(:)) max(transformedFrame(:))]);
        drawnow;
    end
end
if showAnalysis == 1,close;end
