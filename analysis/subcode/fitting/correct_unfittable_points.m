function reFitSegmentsNoNan = correct_unfittable_points(reFitSegments,interpSegments)

% Copy the fit segments
reFitSegmentsNoNan = reFitSegments;

% Count the segments
numSegments = numel(interpSegments);

% Loop through segments
for segmentIdx = 1:numSegments
    % Count number of points in this segment
    numPoints = numel(interpSegments(segmentIdx).xPoints);
    pointsIndices = (1:numPoints)';
    
    % Valid points are ones that have been successfully fit (ie not-NaN)
    invalidPoints = isnan(reFitSegments(segmentIdx).FWHM);
    invalidPointsIndices = pointsIndices(invalidPoints);
    validPointsIndices = pointsIndices(~invalidPoints);
    
    % Change the fit values at NaN to closest valid points
    validFWHM = interp1(pointsIndices(validPointsIndices),reFitSegments(segmentIdx).FWHM(validPointsIndices),pointsIndices(invalidPointsIndices),'nearest','extrap');
    reFitSegmentsNoNan(segmentIdx).FWHM(invalidPoints) = validFWHM;
    validAmp = interp1(pointsIndices(validPointsIndices),reFitSegments(segmentIdx).amplitude(validPointsIndices),pointsIndices(invalidPointsIndices),'nearest','extrap');
    reFitSegmentsNoNan(segmentIdx).amplitude(invalidPoints) = validAmp;
        
end
