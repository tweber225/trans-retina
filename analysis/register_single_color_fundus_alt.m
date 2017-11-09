function rotEst = detect_rot_single_color(unregUncroppedStack,rotUpsample,latUpsample,flatFraction)
% ANALYSIS/
% Detects rotation in image stack and outputs vector of degree rotations
% Requires a field-flattened inputstack
% 
% Part 3 of standard image processing pipeline
% Timothy D. Weber
% Biomicroscopy Lab, BU 2017