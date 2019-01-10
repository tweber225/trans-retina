% ANALYSIS/FUNDUS_IMAGE_ABSORBANCE_ALT
% Script to load average stabilized frame, crop, flatten, and convert image
% to absorbance.
%
% 1. Load stable average frame
% 2. Flattening, convert to absorbance, loop through several filter radii
% 3. Save processed data
% 
% Timothy D. Weber
% Biomicroscopy Lab, BU 2017

%% Parameters
maskNegativeValue = 0;
polyModel = 'poly55';
filterList = [1:11 12:2:27 28:4:40 44:8:64];

%% 1.) Load stable average frame, and manually-segmented weighting frame (aka mask frame since it's binary)
stableAvgFrame = double(imread([newPathName filesep stableAvgFrameFileName]));
weightFrame = double(imread([newPathName filesep stableAvgFrameFileNameMask]) ~= 0);

%% 2.) Image flattening and absorbance calculation
%% b.) Compute envelop and divide out envelope
[xGr, yGr] = meshgrid(1:size(stableAvgFrame,2),1:size(stableAvgFrame,1));
[curve, goodness, output] = fit([xGr(:) yGr(:)],stableAvgFrame(:),'poly55','Weights',weightFrame(:));
illumEnvelope = reshape(feval(curve,[xGr(:) yGr(:)]),size(xGr));
flatAvgFrame = stableAvgFrame./illumEnvelope;

% c.) Repeat filtering with different fitting spans
numRadsToTry = length(filterList);
absorbanceStack = zeros(size(flatAvgFrame,1),size(flatAvgFrame,2),numRadsToTry);
figure;
for radIdx = 1:numRadsToTry
    % Find local maximum 
    smoothMaxFrame = smooth_max_filter(flatAvgFrame,filterList(radIdx));
    
    % Compute log of ratio to get absorbance
    absImg = real(1*log10(smoothMaxFrame./flatAvgFrame));
    absorbanceStack(:,:,radIdx) = absImg;
    maxInWeightingArea = max(weightFrame(:).*absImg(:));
    minInWeightingArea = min(weightFrame(:).*absImg(:));
    imagesc(absImg,[minInWeightingArea maxInWeightingArea]);
    colormap gray;title(['Filter Span = ' num2str(filterList(radIdx))]);drawnow;pause(1);
end

%% 3.) Save absorbance stack
absorbanceStackFileName = [stableAvgFrameFileName(1:(end-5)) '-absorb.tiff'];
save_tiff_stack(single(real(absorbanceStack)),[newPathName filesep absorbanceStackFileName]);

