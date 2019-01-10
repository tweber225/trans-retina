% ANALYSIS/FUNDUS_IMAGE_REGISTRATION_PIPELINE
% Script to find and load raw fundus imagery, run several pre-processing
% steps, register frames, detect motion, and exclude motion-corrupted
% frames. In order, the steps are:
%
% 1. Locate data and load
% 2. Sweep for hotpixels and correct
% 3. Rotational and translational registration
% 4. Save registered and hotpixel-corrected stacks, and an average stabilized frame
% 
% Timothy D. Weber
% Biomicroscopy Lab, BU 2017

% Clear out all the big stack variables so we don't run out of memory
clear rawStack hotPixFreeStack croppedStack flatCropStack rotStack registeredStack stableStack
warning('off', 'Images:initSize:adjustingMag');

%% PARAMETERS
useUIOpenData = 0;
showAnalysis = 1; % Flag to enable real-time analysis figures
medFiltRad = 5; % For hot pixel sweeping
probCutOff = 1e-12;
usePrevCrop = 1;
doubleRegister = 1; % To repeat registration using the stabilized average frame 
rotUpsample = 128;
latUpsample = 64;
blurRadFrac = .04;
thresholdMag = 20;
widenCropByNPix = 10;

%% 1. LOAD DATA
[rawStack,tiffFileName,tiffPathName] = load_single_color_fundus(useUIOpenData,newPathName,newFileName);
rawStackSize = size(rawStack);

%% 2. HOTPIXEL CORRECTION
[hotPixFreeStack,hPixX,hPixY] = hot_pixel_correction(rawStack,medFiltRad,probCutOff,showAnalysis); % both uint16 stacks
clear rawStack % The raw stack won't be used again

%% 3. REGISTRATION
% a) Crop to bound the circular field size with a square
[croppedStack,cropRange] = crop_stack(hotPixFreeStack,usePrevCrop,tiffPathName);
[cropWidth,~,numFrames] = size(croppedStack);
% Override widening factor if the crop is too close to edges
spaceLeftOnEachSide = [cropRange(1)-widenCropByNPix-1, rawStackSize(2)-(cropWidth+widenCropByNPix), cropRange(3)-widenCropByNPix-1, rawStackSize(1)-(cropWidth+widenCropByNPix)];
if min(spaceLeftOnEachSide)<0, widenCropByNPix = widenCropByNPix+min(spaceLeftOnEachSide); end

% b) Flatten and apodize image field
bhWin = blackman_harris_window(cropWidth);
flatCropStack = flatten_image_field(double(croppedStack),blurRadFrac,0).*repmat(bhWin,[1 1 numFrames]); % Don't show analysis for this one

% c) Determine OTF support limit
normOTFCutoff = calculate_OTF_support(flatCropStack,thresholdMag,showAnalysis);

% d) Detect rotational movement
[rotList,radPowSpec] = detect_rot(flatCropStack,normOTFCutoff,rotUpsample,showAnalysis);

% e) Rotate stack
rotStack = rot_stack(flatCropStack,rotList);
clear flatCropStack

% f) Detect translational movement
[transList,numPeaksList,eList] = detect_trans(rotStack,normOTFCutoff,latUpsample,showAnalysis);
clear rotStack

% g) Transform cropped, hot pixel-free stack by the detected translation
% and rotation for each frame (bilinear interpolation) 
cropRangeWithExtra = cropRange + [-1, 1, -1, 1]*widenCropByNPix;
[registeredStack,xPad,yPad] = transform_stack(hotPixFreeStack(cropRangeWithExtra(3):cropRangeWithExtra(4),cropRangeWithExtra(1):cropRangeWithExtra(2),:),rotList,transList,showAnalysis);

% h) Exclude frames corrupted by motion, criteria for this:
% +/- 1 frame on either side of a multi-peak detected cross-correlation
% any frame with cross-correlation peak's eccentricity is >.5
% and any frame with eccentricity > mean(remaining frames) + 1.1*std(remaining frames)
% frames on either side of a jump in position > 1.5x (OTF cutoff)^-1
stableStack = exclude_motion(registeredStack,transList,numPeaksList,eList,normOTFCutoff,showAnalysis);

% i) Finally, if the double register option is enabled, compute an average
% stable frame from stableStack, and use that to re-register all the frames
if doubleRegister == 1
    stableAvgFrame = uint16(mean(double(stableStack),3));
    % crop down the stabilized average frame to dimensions of original crop
    stableAvgFrame = stableAvgFrame((1+yPad+widenCropByNPix):(end-yPad-widenCropByNPix),(1+xPad+widenCropByNPix):(end-xPad-widenCropByNPix)); 
    % Replace first frame of "croppedStack" with this frame
    croppedStack(:,:,1) = stableAvgFrame;
    % Repeat flattening
    flatCropStack = flatten_image_field(double(croppedStack),blurRadFrac,0).*repmat(bhWin,[1 1 numFrames]); % Show analysis over-riden here
    % Repeat rotation detection, rotation
    [rotList,radPowSpec] = detect_rot(flatCropStack,normOTFCutoff,rotUpsample,showAnalysis,radPowSpec);
    rotStack = rot_stack(flatCropStack,rotList);
    clear flatCropStack
    % Repeat translation detection
    [transList,numPeaksList,eList] = detect_trans(rotStack,normOTFCutoff,latUpsample,showAnalysis);
    clear rotStack
    % Repeat transforming
    [registeredStack,xPad,yPad] = transform_stack(hotPixFreeStack(cropRangeWithExtra(3):cropRangeWithExtra(4),cropRangeWithExtra(1):cropRangeWithExtra(2),:),rotList,transList,showAnalysis);
    % Repeat motion exclusion
    [stableStack,stableFrameList] = exclude_motion(registeredStack,transList,numPeaksList,eList,normOTFCutoff,showAnalysis);
end

stableAvgFrame = mean(double(stableStack),3);


%% 4. Save Registration Stacks and Data
% Save image stacks
baseName = tiffFileName(1:(end-5));
fullRegFileName = [baseName '-fullReg.tiff'];
stableRegFileName = [baseName '-stableReg.tiff'];
avgStableFrameFileName = [baseName '-stableAvg.tiff'];
save_tiff_stack(registeredStack,[tiffPathName filesep fullRegFileName]);
save_tiff_stack(stableStack,[tiffPathName filesep stableRegFileName]);
save_tiff_stack(single(stableAvgFrame),[tiffPathName filesep avgStableFrameFileName]);

% Save registration data (rotation, x,y trans, # peaks, eccentricity, motion exclusion list, etc)
disp('Saving Registration Records');
regInfoFileName = [baseName '-regRecords.mat'];
save([tiffPathName filesep regInfoFileName],'rotList','transList','numPeaksList','eList','normOTFCutoff','stableFrameList')


