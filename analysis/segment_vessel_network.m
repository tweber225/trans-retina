function segment_vessel_network(segments,fundusImg)

% Function that takes in vessel segment points in segments structure

numSegments = numel(segments);

% Spline interpolate evenly-spaced points along vessel segment paths
pointSpacing = 1;
interpSegments = spline_interp_paths(segments,pointSpacing);

% Fit the segment cross sections to initial model
crossSectionLength = 32;
fitSegments = fit_segments_to_model(interpSegments,fundusImg,crossSectionLength,'linear and negative exponential');

% Draw vessel bounds lines
figure;
imshow(norm_contrast(fundusImg)); 
hold on;
for segmentIdx = 1:numSegments
    % Draw lower line
    x = interpSegments(segmentIdx).xPoints - cos(interpSegments(segmentIdx).angles-pi/2).*fitSegments(segmentIdx).FWHM/2;
    y = interpSegments(segmentIdx).yPoints - sin(interpSegments(segmentIdx).angles-pi/2).*fitSegments(segmentIdx).FWHM/2;
    line(x,y);
    
    % Draw upper line
    x = interpSegments(segmentIdx).xPoints + cos(interpSegments(segmentIdx).angles-pi/2).*fitSegments(segmentIdx).FWHM/2;
    y = interpSegments(segmentIdx).yPoints + sin(interpSegments(segmentIdx).angles-pi/2).*fitSegments(segmentIdx).FWHM/2;
    line(x,y);
    
end

% Try smoothing fit parameters
smoothSpan = 20;
figure;
imshow(norm_contrast(fundusImg)); 
hold on;
for segmentIdx = 1:numSegments
    fitSegments(segmentIdx).smoothFWHM = smooth(fitSegments(segmentIdx).FWHM,smoothSpan,'rlowess');
    
    % Draw lower line
    x = interpSegments(segmentIdx).xPoints - cos(interpSegments(segmentIdx).angles-pi/2).*fitSegments(segmentIdx).smoothFWHM/2;
    y = interpSegments(segmentIdx).yPoints - sin(interpSegments(segmentIdx).angles-pi/2).*fitSegments(segmentIdx).smoothFWHM/2;
    line(x,y);
    
    % Draw upper line
    x = interpSegments(segmentIdx).xPoints + cos(interpSegments(segmentIdx).angles-pi/2).*fitSegments(segmentIdx).smoothFWHM/2;
    y = interpSegments(segmentIdx).yPoints + sin(interpSegments(segmentIdx).angles-pi/2).*fitSegments(segmentIdx).smoothFWHM/2;
    line(x,y);
    
end

% Draw polygon ROI

polyROI = drawpolygon('Position',[x,y]);


spy

