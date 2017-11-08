% ANALYSIS/FUNDUS_IMAGE_PROCESSING_PIPELINE
% Script to find and load raw fundus imagery, run several pre-processing
% steps, and estimate chromophore density. In order, the steps are:
%
% 1. Locate data and load
% 2. Sweep for hotpixels and correct them
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

%% LOAD DATA
rawStack = load_single_color_fundus(1);

%% HOTPIXEL CORRECTION
[hotPixFreeStack, hPixX, hPixY] = hot_pixel_correction(rawStack,medFiltRad,probCutOff);

%% REGISTRATION
[regStack, dX, dY, dTheta] = register_single_color_fundus(rawStack,512,8,.025);

