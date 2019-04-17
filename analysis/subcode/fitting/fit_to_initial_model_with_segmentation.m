function fitSegments = fit_to_initial_model_with_segmentation(interpSegments,fundusImg,masks,crossSectionLength,showProfiles)
% Generate cross sections through a path (path given by "interpSegments")
% and fit all the cross sections jointly to a specific model.

% To be used later
crossSectionIndices = (-crossSectionLength/2):(crossSectionLength/2);
if showProfiles == 1, figure; end

% Loop through each vessel segment
numSegments = numel(interpSegments);
for segmentIdx = 1:numSegments
    % Modify the fundus image to interpolate other vessel segments
    exclusionMask = any(masks(:,:,(1:numSegments)~=segmentIdx),3);
    modifiedFundusImg = regionfill(fundusImg,exclusionMask);
    
    % Compute end points for each vessel cross section
    x1 = interpSegments(segmentIdx).xPoints - cos(interpSegments(segmentIdx).angles-pi/2)*crossSectionLength/2;
    y1 = interpSegments(segmentIdx).yPoints - sin(interpSegments(segmentIdx).angles-pi/2)*crossSectionLength/2;
    x2 = interpSegments(segmentIdx).xPoints + cos(interpSegments(segmentIdx).angles-pi/2)*crossSectionLength/2;
    y2 = interpSegments(segmentIdx).yPoints + sin(interpSegments(segmentIdx).angles-pi/2)*crossSectionLength/2;
    
    % Generate interpolation cross section locations and profiles
    numPoints = numel(interpSegments(segmentIdx).xPoints);
    crossSections = zeros(numPoints,crossSectionLength+1);
    for pointIdx = 1:numPoints
        xInterp = linspace(x1(pointIdx),x2(pointIdx),crossSectionLength+1);
        yInterp = linspace(y1(pointIdx),y2(pointIdx),crossSectionLength+1);
        crossSections(pointIdx,:) = double(interp2(modifiedFundusImg,xInterp,yInterp));
    end
    
    % For initial fit, assume a whole vessel segment's width is the same
    % Fit the profile to model
    [fitresult, xData, yData, zData, ~] = fit_whole_segment(1:numPoints,crossSectionIndices,crossSections);

    if showProfiles == 1
        % Show the fundus image and cross section
        subplot(1,2,1);
        imshow(norm_contrast(fundusImg));hold on
        line([x1(round(pointIdx/2)),x2(round(pointIdx/2))],[y1(round(pointIdx/2)),y2(round(pointIdx/2))]); hold off;

        % Plot cross section and fit result
        subplot(1,2,2)
        plot( fitresult, [xData, yData], zData);
    end
        
        
    
    % Add info to output fit structure
    fitSegments(segmentIdx).rList = repmat(fitresult.r,[numPoints 1]);

    
end
