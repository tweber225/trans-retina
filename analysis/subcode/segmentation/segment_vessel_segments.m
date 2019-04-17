function masks = segment_vessel_segments(fundusImg,fitSegments,interpSegments,ROIDilateFactor)
% Takes interpolated vessel segment list (interpSegments) and with the
% estimated radius at each of the points in interpSegments computes the
% left and right edges of vessel. Draws ROIs by connecting left and right
% edges around individual vessel segments. Makes binary masks for each ROI.

% Count segments
numSegments = numel(fitSegments);

% Make space for segment masks
masks = zeros([size(fundusImg) numSegments],'logical');

% Draw fundus image for ROI creation
figure; 
imshow(norm_contrast(fundusImg));

% Loop through each segment
for segmentIdx = 1:numSegments
    
    rList = fitSegments(segmentIdx).rList; % Could smooth here
    
    % Draw left bounding edge(note this is not necessarily left in reality)
    xLeft = interpSegments(segmentIdx).xPoints - cos(interpSegments(segmentIdx).angles-pi/2).*rList*ROIDilateFactor;
    yLeft = interpSegments(segmentIdx).yPoints - sin(interpSegments(segmentIdx).angles-pi/2).*rList*ROIDilateFactor;
    
    % Draw right edge
    xRight = interpSegments(segmentIdx).xPoints + cos(interpSegments(segmentIdx).angles-pi/2).*rList*ROIDilateFactor;
    yRight = interpSegments(segmentIdx).yPoints + sin(interpSegments(segmentIdx).angles-pi/2).*rList*ROIDilateFactor;
    
    % Draw ROI around the segment out to 2*FWHM and make binary mask
    polyROI = drawpolygon('Position',[xLeft,yLeft;flipud(xRight),flipud(yRight)]);
    masks(:,:,segmentIdx) = createMask(polyROI);
end

% Close the figure
close