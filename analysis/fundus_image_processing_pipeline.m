% ANALYSIS/FUNDUS_IMAGE_PROCESSING_PIPELINE
% Script to find and load raw fundus imagery, run several pre-processing
% steps, and estimate chromophore density. In order, the steps are:
%
% 1. Locate data and load
% 2. Sweep for hotpixels and correct
% 3. Rotational and translational registration
% 4. Image flattening
% 5. Chromophore unmixing
% 6. Save processed data
% 
% Timothy D. Weber
% Biomicroscopy Lab, BU 2017

clear all
%% PARAMETERS
medFiltRad = 5; % For hot pixel sweeping
probCutOff = 1e-12;
rotUpsample = 1024;
latUpsample = 256;
blurRadFrac = .04;
thresholdMag = 25;

%% 1. LOAD DATA
rawStack = load_single_color_fundus(1);

%% 2. HOTPIXEL CORRECTION
[hotPixFreeStack,hPixX,hPixY] = hot_pixel_correction(rawStack,medFiltRad,probCutOff);
clear rawStack % The raw stack won't be used again

%% 3. REGISTRATION
% a) Crop to bound the circular field size with a square
[croppedStack,cropRange] = crop_stack(hotPixFreeStack);close
[cropWidth,~,numFrames] = size(croppedStack);

% b) Flatten and apodize image field
bhWin = blackman_harris_window(cropWidth);
flatCropStack = flatten_image_field(croppedStack,blurRadFrac).*repmat(bhWin,[1 1 numFrames]);
clear croppedStack % only the flattened and cropped stack is used after this

% c) Determine OTF support limit
normOTFCutoff = calculate_OTF_support(flatCropStack,thresholdMag);

% d) Detect rotational movement
rotList = detect_rot(flatCropStack,normOTFCutoff,rotUpsample);

% e) Rotate stack
rotStack = rot_stack(flatCropStack,rotList);
clear flatCropStack

% f) Detect translational movement
transList = detect_trans(rotStack,normOTFCutoff,latUpsample);

% Optional: play some tricks with smoothing rotList and transLists

% g) Transform cropped, hot pixel-free stack by the detected translation
% and rotation for each frame (bilinear interpolation)
registeredStack = transform_stack(hotPixFreeStack(cropRange(1):cropRange(2),cropRange(3):cropRange(4)),rotList,transList);


%% 6. Save Data
