function [interpSegments,reFitSegments] = fit_vessel_network(segments,fundusImg,channelName,analysisPath)
% Function that takes in vessel segment points in segments structure and
% fits segments to a model


% Spline interpolate to form evenly-spaced points along vessel segment paths
pointSpacing = 1/2; % half-pixel spacing axially along vessel
interpSegments = spline_interp_paths(segments,pointSpacing);

% Fit the segment cross sections to initial model (forcing same absorption
% coefficient and circular vessel width
crossSectionWidth = 64; % Length of cross-section through vessel
showProfiles = 1;
fitSegments = fit_to_initial_model(interpSegments,fundusImg,crossSectionWidth,analysisPath,showProfiles);

% Segment vessel segments (make ROIs to tag pixels belonging to vessels)
radiusMargin = 1.5; % Factor to expand radius of vessels for segmentation
masks = segment_vessel_segments(fundusImg,fitSegments,interpSegments,radiusMargin);
% save masks
options.overwrite = true;
saveastiff(uint8(masks),[analysisPath filesep channelName 'masks.tif'],options);

% Load additional optic disc mask and add to end of masks stack
OD_mask = logical(loadtiff([analysisPath filesep 'discmask.tif']));
masks(:,:,end+1) = OD_mask;

% Repeat fitting with segmentation now available
showProfiles = 1;
crossSectionWidth = 32; % Can now be a bit smaller
axialFitPeriod = 32; % Fit a 2D surface every X pixels along vessel, interpolate in-between (boosts speed greatly)
reFitSegments = fit_chunks_with_segmentation(interpSegments,fundusImg,masks,crossSectionWidth,2*axialFitPeriod,showProfiles);





