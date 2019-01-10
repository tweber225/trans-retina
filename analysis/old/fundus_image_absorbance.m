% ANALYSIS/FUNDUS_IMAGE_ABSORBANCE
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
minRad = 1;
radDiff = 1;
maxRad = 30;

%% 1.) Load stable average frame
stableAvgFrame = double(imread([newPathName filesep stableAvgFrameFileName]));

%% 2.) Image flattening and absorbance calculation
% Current strategy: max filter, gaussian blur, divide blur by stable image,
% take log10

% a.) Re-crop stabilized average frame and pad correctly
disp('Crop for smooth max processing');
croppedAvgFrame = crop_and_pad_frame(stableAvgFrame);
% b.) Repeat fitlering with different filter kernel widths
radiusList = minRad:radDiff:maxRad;
numRadToTry = length(radiusList);
absorbanceStack = zeros(size(croppedAvgFrame,1),size(croppedAvgFrame,2),numRadToTry);
figure;
for radIdx = 1:numRadToTry
    maxBlurAvgFrame = smooth_max_filter(croppedAvgFrame,radiusList(radIdx));
    absorbanceStack(:,:,radIdx) = log10(maxBlurAvgFrame./croppedAvgFrame);
    imagesc(absorbanceStack(:,:,radIdx));
    colormap gray;title(['Filter Radius = ' num2str(radiusList(radIdx))]);drawnow;
end

%% 3.) Save absorbance stack
absorbanceStackFileName = [stableAvgFrameFileName(1:(end-15)) '-absorb.tiff'];
save_tiff_stack(single(absorbanceStack),[newPathName filesep absorbanceStackFileName]);