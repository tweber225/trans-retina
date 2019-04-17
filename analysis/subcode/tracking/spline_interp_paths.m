function interpSegments = spline_interp_paths(segments,stepLength)
% Takes discrete points along path (in "segments" structure), and
% interpolates equally-spaced points and their tangent angles along path.
% Curvilinear distance between interpolated points equals "stepLength"
%
% "segments" structure is of length N (N the number of segments in the
% network) and has fields "ID" (segment hierarchy code), "xPoints" and
% "yPoints" (coordinates of the vessel path).

% Loop through all the segments
numSegments = numel(segments);
for segmentIdx = 1:numSegments
    % Compute a parameterization, t for x and y points
    numPoints = numel(segments(segmentIdx).xPoints);
    t = 1:numPoints;
    
    % Compute splines for x and y data
    xSplinePP = spline(t,segments(segmentIdx).xPoints);
    ySplinePP = spline(t,segments(segmentIdx).yPoints);
    
    % Interpolate on the splines
    tUpSample = 1:.01:numPoints;
    upSampleIndices = 1:numel(tUpSample);
    xUpSample = ppval(xSplinePP,tUpSample);
    yUpSample = ppval(ySplinePP,tUpSample);
    
    % Calculate distance along the interpolated data
    dD = sqrt(diff(xUpSample).^2 + diff(yUpSample).^2);
    D = cumsum(dD);
    
    % Search along the distance vector 
    searchForDistance = stepLength;
    equalSpacedX = [];
    equalSpacedY = [];
    equalSpacedAngle = [];
    while sum(D>searchForDistance)
        % Find the minimum distance over the search-for-distance (call this
        % close enough)
        nextIndex = min(upSampleIndices(D>searchForDistance));
        
        % Add the interpolated x and y points and calculate tanget angle
        equalSpacedX = [equalSpacedX;xUpSample(nextIndex)];
        equalSpacedY = [equalSpacedY;yUpSample(nextIndex)];
        dX = xUpSample(nextIndex+1) - xUpSample(nextIndex);
        dY = yUpSample(nextIndex+1) - yUpSample(nextIndex);
        equalSpacedAngle = [equalSpacedAngle;atan2(dY,dX)];
        
        % Move to the next distance along distance vector
        searchForDistance = searchForDistance+stepLength;
    end
    
    interpSegments(segmentIdx).ID = segments(segmentIdx).ID;
    interpSegments(segmentIdx).xPoints = equalSpacedX;
    interpSegments(segmentIdx).yPoints = equalSpacedY;
    interpSegments(segmentIdx).angles = equalSpacedAngle;
end