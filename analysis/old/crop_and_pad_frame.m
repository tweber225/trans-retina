function croppedAndPaddedFrame = crop_and_pad_frame(inputFrame)
% ANALYSIS/CROP_AND_PAD_FRAME
% Crops the input frame and replicates everything outside an inscribed
% circle around the crop area
%
% Part 5 of standard image processing pipeline
% Timothy D. Weber
% Biomicroscopy Lab, BU 2017

% Use the MATLAB UI to crop the frame
[croppedAvgFrame,~] = crop_stack(inputFrame,0);
[cropPixWidth,~] = size(croppedAvgFrame);

% Fill in outside of inscribed circle with values at the edge of the
% inscribed circle (radial 'replicate' for a circular selection)

% Make a circular binary mask
rhoEdge = (cropPixWidth/2);
x = (-cropPixWidth/2+.5):(cropPixWidth/2-.5);
y = (-cropPixWidth/2+.5):(cropPixWidth/2-.5);
[xGrid,yGrid] = meshgrid(x,y);
circMask = ((xGrid.^2 + yGrid.^2) < rhoEdge^2);

% Find x,y coordinates for each pixel outside the circle
xOutCirc = xGrid(~logical(circMask));
yOutCirc = yGrid(~logical(circMask));
numOutCircPix = length(xOutCirc);

% Interpolate new values for these pixels
[theta,~] = cart2pol(xOutCirc,yOutCirc);
[Xq,Yq] = pol2cart(theta,repmat(rhoEdge,[numOutCircPix 1]));
croppedAndPaddedFrame = croppedAvgFrame;
%croppedAndPaddedFrame(~logical(circMask)) = interp2(xGrid,yGrid,croppedAvgFrame,Xq,Yq);
croppedAndPaddedFrame(~logical(circMask)) = 0;