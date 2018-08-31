function [croppedFrame, weightsFrame] = crop_and_export_weights(inputFrame)
% ANALYSIS/CROP_AND_EXPORT_WEIGHTS
% Crops the input frame and exports a frame of weights
%
% Timothy D. Weber
% Biomicroscopy Lab, BU 2017

originalHeight = size(inputFrame,1);
originalWidth = size(inputFrame,2);
% Scale for the cropping UI
croppingFrame = (inputFrame-min(inputFrame(:)))/(max(inputFrame(:))-min(inputFrame(:)));

%% Crop to field of view
% Use MATLAB's UI to find crop region
[~,rLims] = imcrop(croppingFrame);
y0 = rLims(2)+0.5*rLims(4);
x0 = rLims(1)+0.5*rLims(3);
b = 0.5*rLims(4);
a = 0.5*rLims(3);

% Make an elliptical mask for outline of frame
x = 1:originalWidth;
y = 1:originalHeight;
[xGrid,yGrid] = meshgrid(x,y);
ellipMask = ( (((xGrid-x0)./a).^2 + ((yGrid-y0)./b).^2) < 1 );
weightsFrame = double(ellipMask);

% Set area outside the field of view to 0
croppedFrame = inputFrame;
croppedFrame(~logical(ellipMask)) = 0;


%% Also crop around the optic disc
% Use MATLAB's UI to find crop region
[~,rLims] = imcrop(croppingFrame);
y0 = rLims(2)+0.5*rLims(4);
x0 = rLims(1)+0.5*rLims(3);
b = 0.5*rLims(4);
a = 0.5*rLims(3);

% Make an elliptical mask for outline of frame
x = 1:originalWidth;
y = 1:originalHeight;
[xGrid,yGrid] = meshgrid(x,y);
ellipMask = ( (((xGrid-x0)./a).^2 + ((yGrid-y0)./b).^2) < 1 );

weightsFrame = weightsFrame - double(ellipMask);
