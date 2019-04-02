function segment_vessel_network(segments)

% Function that takes in vessel segment points in segments structure



% Spline interpolate evenly-spaced points along vessel segment paths
pointSpacing = 1;
interpSegments = spline_interp_paths(segments,pointSpacing);

% Fit the segment cross sections to initial model
fitSegments = fit_segments_to_model(interpSegments,'linear and negative exponential');

