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
latUpsample = 16;
blurRadFrac = .04;
thresholdMag = 10;

%% 1. LOAD DATA
rawStack = load_single_color_fundus(1);

%% 2. HOTPIXEL CORRECTION
[hotPixFreeStack,hPixX,hPixY] = hot_pixel_correction(rawStack,medFiltRad,probCutOff);
clear rawStack % The raw stack won't be used again

%% 3. REGISTRATION
% a) Crop to bound the circular field size with a square
croppedStack = crop_stack(hotPixFreeStack);
close

% b) Flatten image field
flatCropStack = flatten_image_field(croppedStack,blurRadFrac);
clear croppedStack % only the flattened and cropped stack is used after this

% c) Determine OTF support limit
normOTFCutoff = calculate_OTF_support(flatCropStack,thresholdMag);

% d) Detect rotational movement
rotList = detect_rot(flatCropStack,normOTFCutoff,rotUpsample);

% e) Rotate flattened & cropped stack

% f) Detect translational movement
transList = detect_trans(flatCropStack,normOTFCutoff,latUpsample);

% g) Transform hot pixel-free stack by the detected translation and
% rotations
registeredStack = transform(hotPixFreeStack,rotList,transList);


