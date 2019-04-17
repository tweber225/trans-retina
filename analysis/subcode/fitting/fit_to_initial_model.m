function fitSegments = fit_to_initial_model(interpSegments,fundusImg,crossSectionWidth,analysisPath,showProfiles)
% Generate cross sections through a path (path given by "interpSegments")
% and fit all the cross sections jointly to a specific model.

% To be used later
crossSectionIndices = (-crossSectionWidth/2):0.5:(crossSectionWidth/2);
if showProfiles == 1, figure; end

% Loop through each vessel segment
numSegments = numel(interpSegments);
for segmentIdx = 1:numSegments
    % Compute end points for each vessel cross section
    x1 = interpSegments(segmentIdx).xPoints - cos(interpSegments(segmentIdx).angles-pi/2)*crossSectionWidth/2;
    y1 = interpSegments(segmentIdx).yPoints - sin(interpSegments(segmentIdx).angles-pi/2)*crossSectionWidth/2;
    x2 = interpSegments(segmentIdx).xPoints + cos(interpSegments(segmentIdx).angles-pi/2)*crossSectionWidth/2;
    y2 = interpSegments(segmentIdx).yPoints + sin(interpSegments(segmentIdx).angles-pi/2)*crossSectionWidth/2;
    
    % Generate interpolation cross section locations and profiles
    numPoints = numel(interpSegments(segmentIdx).xPoints);
    crossSections = zeros(numPoints,2*crossSectionWidth+1);
    for pointIdx = 1:numPoints
        xInterp = linspace(x1(pointIdx),x2(pointIdx),2*crossSectionWidth+1);
        yInterp = linspace(y1(pointIdx),y2(pointIdx),2*crossSectionWidth+1);
        crossSections(pointIdx,:) = double(interp2(fundusImg,xInterp,yInterp));
    end
    
    % For initial fit, assume a whole vessel segment's width is the same
    % Fit the profile to model
    [fitresult, xData, yData, ~, ~] = fit_whole_segment(1:numPoints,crossSectionIndices,crossSections);

    if showProfiles == 1
        % Show the fitted vessel on image
        subplot(1,2,1)
        imshow(norm_contrast(fundusImg)); hold on
        line(interpSegments(segmentIdx).xPoints,interpSegments(segmentIdx).yPoints)
        hold off
        
        % Generate a "predicted" image based on model fit
        fitImg = imgaussfilt(reshape(fitresult(xData,yData),size(crossSections)),2);
        
        % Generate a simulated vessel-free image, that is un-do the
        % exp(-u*2*sqrt(r^2 - x^2)) factor, and also blurring the image
        % slightly
        u = fitresult.u;
        r = fitresult.r;
        y0 = fitresult.y0;
        y = repmat(crossSectionIndices,[numPoints 1]);
        vesselFunction = exp(-u*2*upper_semicircle(y,r,y0));
        blurredVesselFunction = imgaussfilt(vesselFunction.^(-1),2);
        noVesselImg = crossSections.*blurredVesselFunction;
        
        % Inpaint inside vessel
        vesselFunctionPlusMargin = exp(-u*2*upper_semicircle(y,r*1.33,y0));
        inpaintedImg = regionfill(crossSections,vesselFunctionPlusMargin < 1);
        
        % Generate residual image: of image - model
        residsImg = crossSections - fitImg;
        
        % Generate inpainting-flattened vessel image
        flattenedVesselImg = crossSections./inpaintedImg;

        % Show these again separately scaled
        imgs = [norm_contrast([crossSections,fitImg,noVesselImg,inpaintedImg]),norm_contrast(residsImg),norm_contrast(flattenedVesselImg)];
        imgsScaled = imresize(imgs,[size(imgs,1), 2*size(imgs,2)],'bilinear');
        subplot(1,2,2)
        imshow(imgsScaled)
        title(['u = ' num2str(u) ', r = ' num2str(r) ', y0 = ' num2str(y0)])
        
        % Save analysis image
        options.overwrite = true;
        saveastiff(single(imgsScaled),[analysisPath filesep 'segments' filesep interpSegments(segmentIdx).ID '.tif'],options);
    end
        
    
    % Add info to output fit structure
    fitSegments(segmentIdx).rList = repmat(fitresult.r,[numPoints 1]);

    
end
