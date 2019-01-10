function inputStack = flatten_image_field(inputStack,flatFraction,showAnalysis)
% ANALYSIS/FLATTEN_IMAGE_FIELD
% Flattens the image fields
% 
% Part 3b of standard image processing pipeline
% Timothy D. Weber
% Biomicroscopy Lab, BU 2017


% Determine image size
[xPix, ~, numFrames] = size(inputStack);

% Fill in outside of inscribed circle with values at the edge of the
% inscribed circle (radial 'replicate' for a circular selection)

% Make a circular binary mask
rhoEdge = (xPix/2);
x = (-xPix/2+.5):(xPix/2-.5);
y = (-xPix/2+.5):(xPix/2-.5);
[xGrid,yGrid] = meshgrid(x,y);
circMask = ((xGrid.^2 + yGrid.^2) < rhoEdge^2);

% Find x,y coordinates for each pixel outside the circle
xOutCirc = xGrid(~logical(circMask));
yOutCirc = yGrid(~logical(circMask));
numOutCircPix = length(xOutCirc);

% Compute the size of the filter kernel
filtSize = flatFraction*xPix;

% Loop through each frame and interpolate values for each out of circle
% pixel
disp('Beginning Field Flattening');
percentsVect = [10 20 30 40 50 60 70 80 90 100];
percentFrames = round(numFrames*percentsVect/100);
if showAnalysis == 1,figure;end
for frameIdx = 1:numFrames % using parfor seems to crash computer here, beware!
    % Pull out current frame
    currentFrame = inputStack(:,:,frameIdx);
    
    % Interpolate new values for these pixels
    [theta,~] = cart2pol(xOutCirc,yOutCirc);
    [Xq,Yq] = pol2cart(theta,repmat(rhoEdge,[numOutCircPix 1]));
    currentFrame(~logical(circMask)) = interp2(xGrid,yGrid,currentFrame,Xq,Yq);
    
    % Blur the current frame and divide by the blurred version, put back
    % into stack
    blurFrame = imgaussfilt(currentFrame,filtSize);
    inputStack(:,:,frameIdx) = currentFrame./blurFrame;
    
    % Display progress
    if sum(percentFrames == frameIdx)
        [~,pIdx] = max(percentFrames == frameIdx);
        disp([num2str(percentsVect(pIdx)) '%']);
    end
    
    % Show the flattened frames as they come out
    if showAnalysis == 1
        imagesc(inputStack(:,:,frameIdx));colorbar;
        title('Flattened frames');
        drawnow;
    end
end
