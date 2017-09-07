% ANALYSIS/FUNDUS IMAGE NORMALIZATION
% Script takes stabilized fundus image stacks and normalizes recorded
% intensity by the average intensity around the user-selected optic nerve.

% Parameters
croppingFrame = 1;

% Load image stack info
[tiffFileName,tiffPathName,filtIdx] = uigetfile('*.tiff','Select TIFF File to Normalize');
tiffFileInfo = imfinfo([tiffPathName filesep tiffFileName]);
numFrames = numel(tiffFileInfo);

% Allocate image array
unNormedFrames = zeros(tiffFileInfo(1).Height,tiffFileInfo(1).Width,numFrames);

% Load frames sequentially
for frameIdx = 1:numFrames
    unNormedFrames(:,:,frameIdx) = imread([tiffPathName filesep tiffFileName], frameIdx, 'Info', tiffFileInfo);
end

% Crop interactively
[~,rLims] = imcrop(unNormedFrames(:,:,croppingFrame)./max(max(unNormedFrames(:,:,croppingFrame))));
x1 = round(rLims(1));
x2 = round(rLims(1)+rLims(3));
y1 = round(rLims(2));
y2 = round(rLims(2)+rLims(4));

% Compute average intensities for each frame
avgDisc = mean(mean(unNormedFrames(y1:y2,x1:x2,:),2),1);
plot(squeeze(avgDisc))

% Divide out all frames
normedFrames = unNormedFrames./repmat(avgDisc,[tiffFileInfo(1).Height, tiffFileInfo(1).Width, 1]);

% Save the normalized frames
filenameMinusExtension = tiffFileName(1:(end-5));
newFileNameAndPath = [tiffPathName filesep filenameMinusExtension '-norm.tiff'];
saveastiff(single(normedFrames),newFileNameAndPath);