function fitSegments = fit_segments_to_model_with_segmentation(interpSegments,fundusImg,masks,crossSectionLength,axialFitRange,axialFitPeriod,showProfiles)
% Generate cross sections through a path (path given by "interpSegments")
% and fit it the cross sections from segments to a specific model.
% Interpolate cross section points tagged as belonging to other vessels.

% To be used later
if showProfiles == 1, figure; end

% Loop through each vessel segment
numSegments = numel(interpSegments);
for segmentIdx = 1:numSegments

    % Compute the interpolation mask (highlights all other vessel segments)
    otherVesselsMask = any(masks(:,:,(1:numSegments) ~= segmentIdx),3);
    
    % Change pixel values where other vessels are to inwardly interpolated
    % value
    modifiedFundusImg = regionfill(fundusImg,otherVesselsMask);
    
    % Compute end points for each vessel cross section
    x1 = interpSegments(segmentIdx).xPoints - cos(interpSegments(segmentIdx).angles-pi/2)*crossSectionLength/2;
    y1 = interpSegments(segmentIdx).yPoints - sin(interpSegments(segmentIdx).angles-pi/2)*crossSectionLength/2;
    x2 = interpSegments(segmentIdx).xPoints + cos(interpSegments(segmentIdx).angles-pi/2)*crossSectionLength/2;
    y2 = interpSegments(segmentIdx).yPoints + sin(interpSegments(segmentIdx).angles-pi/2)*crossSectionLength/2;
    
    % Generate all the interpolation cross section locations and profiles
    numPoints = numel(interpSegments(segmentIdx).xPoints);
    xInterpList = zeros(crossSectionLength,numPoints);
    yInterpList = xInterpList;
    crossSections = xInterpList';
    for pointIdx = 1:numPoints
        xInterpList(:,pointIdx) = linspace(x1(pointIdx),x2(pointIdx),crossSectionLength);
        yInterpList(:,pointIdx) = linspace(y1(pointIdx),y2(pointIdx),crossSectionLength);
        crossSections(pointIdx,:) = double(interp2(modifiedFundusImg,xInterpList(:,pointIdx),yInterpList(:,pointIdx)));
    end
    
    % Loop through each point of the segment and fit the model
    FWHM = zeros(numPoints,1);
    I_0 = FWHM;
    transmission = FWHM;
    rSquare = FWHM;
    for pointIdx = 1:axialFitPeriod:numPoints
        % Calculate range of data to use for this fit
        axialStart = pointIdx - axialFitRange/2;
        axialEnd = pointIdx + axialFitRange/2;
        axialIndices = axialStart:axialEnd;
        % Make sure the range is valid
        if axialStart < 1, axialStart = 1; end
        if axialEnd > numPoints, axialEnd = numPoints; end
        axialIndices = axialIndices((axialIndices >= 1) & (axialIndices <= numPoints))- pointIdx;
        crossSectionIndices = (-crossSectionLength/2+1/2):(crossSectionLength/2-1/2);
        
        % Extract the data from straightened vessel cross section image
        crossSectionSubImage = crossSections(axialStart:axialEnd,:);
        
        % Fit the profile to model
        [fitresult, xData, yData, zData, gof] = fit_surface_and_neg_cyl_gaussian(axialIndices,crossSectionIndices,crossSectionSubImage);
        
        if showProfiles == 1
            % Show the fundus image and cross section
            subplot(1,2,1);
            imshow(norm_contrast(fundusImg));hold on
            line([x1(pointIdx),x2(pointIdx)],[y1(pointIdx),y2(pointIdx)]); hold off;

            % Plot cross section and fit result
            subplot(1,2,2)
            plot( fitresult, [xData, yData], zData );
        end
        
        
        
        % Save important model parameters (Gaussian FWHM & amplitude)
        FWHM(pointIdx) = fitresult.f;
        I_0(pointIdx) = fitresult.a; % Corresponds to background signal level
        transmission(pointIdx) = 1+fitresult.d;
        rSquare = gof.rsquare;
    end
    
    % Interpolate the in-between points
    allPoints = 1:numPoints;
    selectPoints = 1:axialFitPeriod:numPoints;
    notPoints = allPoints(~ismember(allPoints,selectPoints));
    FWHM(notPoints) = interp1(selectPoints,FWHM(selectPoints),notPoints);
    I_0(notPoints) = interp1(selectPoints,I_0(selectPoints),notPoints);
    transmission(notPoints) = interp1(selectPoints,transmission(selectPoints),notPoints);

    % And extrapolate the NaNs at the end
    FWHM(isnan(FWHM)) = interp1(allPoints(~isnan(FWHM)),FWHM(~isnan(FWHM)),allPoints(isnan(FWHM)),'nearest','extrap');
    I_0(isnan(I_0)) = interp1(allPoints(~isnan(I_0)),I_0(~isnan(I_0)),allPoints(isnan(I_0)),'nearest','extrap');
    transmission(isnan(transmission)) = interp1(allPoints(~isnan(transmission)),transmission(~isnan(transmission)),allPoints(isnan(transmission)),'nearest','extrap');

    % Add info to output structure
    fitSegments(segmentIdx).FWHM = FWHM;
    fitSegments(segmentIdx).I_0 = I_0;
    fitSegments(segmentIdx).transmission = transmission;
    fitSegments(segmentIdx).rSquare = rSquare;
end
