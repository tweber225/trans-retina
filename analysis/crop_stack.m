function [croppedStack,cropRange] = crop_stack(inputStack)

% Pull out the first frame
firstFrame = inputStack(:,:,1);

% Scale this frame for the cropping UI
croppingFrame = (firstFrame-min(firstFrame(:)))/(max(firstFrame(:))-min(firstFrame(:)));

% Use MATLAB's UI to find crop region
[~,rLims] = imcrop(croppingFrame); 

% Make even number of pixels per dimension and square
minDim = min(rLims(3),rLims(4));
frameEdge = 2*ceil(minDim/2);
x1 = round(rLims(1));
x2 = round(rLims(1)+frameEdge)-1;
y1 = round(rLims(2));
y2 = round(rLims(2)+frameEdge)-1;
croppedStack = inputStack(y1:y2,x1:x2,:);

cropRange = [x1,x2,y1,y2];