function fitSegments = fit_segments_to_model(interpSegments,fundusImg,crossSectionLength,model_name)
% Function to fit the cross sections from segments to a specific model
% given in "model_name"

% To be used later
sectionIndices = (-crossSectionLength/2+1/2):(crossSectionLength/2-1/2);

% Loop through each vessel segment
numSegments = numel(interpSegments);
for segmentIdx = 1:numSegments
    % Compute end points for each vessel cross section
    x1 = interpSegments(segmentIdx).xPoints - cos(interpSegments(segmentIdx).angles-pi/2)*crossSectionLength/2;
    y1 = interpSegments(segmentIdx).yPoints - sin(interpSegments(segmentIdx).angles-pi/2)*crossSectionLength/2;
    x2 = interpSegments(segmentIdx).xPoints + cos(interpSegments(segmentIdx).angles-pi/2)*crossSectionLength/2;
    y2 = interpSegments(segmentIdx).yPoints + sin(interpSegments(segmentIdx).angles-pi/2)*crossSectionLength/2;
    
    % Loop through each point of the segment 
    % and fit the model
    numPoints = numel(interpSegments(segmentIdx).xPoints);
    FWHM = zeros(numPoints,1);
    amplitude = zeros(numPoints,1);
    for pointIdx = 1:numPoints
        % Interpolate the cross section profile
        xInterp = linspace(x1(pointIdx),x2(pointIdx),crossSectionLength);
        yInterp = linspace(y1(pointIdx),y2(pointIdx),crossSectionLength);
        crossSection = double(interp2(fundusImg,xInterp,yInterp));
        
        % Fit the profile to model
        [fitresult, ~] = fit_linear_and_neg_gaussian(sectionIndices,crossSection);
        
        % Save important model parameters (Gaussian FWHM & amplitude)
        FWHM(pointIdx) = fitresult.d;
        amplitude(pointIdx) = fitresult.c;
    end
    
    % Add info to output structure
    fitSegments(segmentIdx).FWHM = FWHM;
    fitSegments(segmentIdx).amplitude = amplitude;
    
end
