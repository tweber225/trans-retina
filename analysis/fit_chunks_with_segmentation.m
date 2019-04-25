function fitSegments = fit_chunks_with_segmentation(interpSegments,fundusImg,masks,crossSectionWidth,axialFitPeriod,showProfiles)
% Generate cross sections through a path (path given by "interpSegments")
% and fit it the cross sections from segments to a specific model.
% Interpolate cross section points tagged as belonging to other vessels.
if showProfiles == 1, figure; end

% Make indices for cross sectional axis
crossSectionIndices = (-crossSectionWidth/2):0.5:(crossSectionWidth/2);

% Loop through each vessel segment
numSegments = numel(interpSegments);
for segmentIdx = 1:numSegments
    % Estimate the background of current segmented vessel with inward inpainting
    estimatedBackgroundImg = regionfill(fundusImg,masks(:,:,segmentIdx));
    
    % Flatten image by dividing out the estimated background
    flattenedFundusImg = fundusImg./estimatedBackgroundImg;
    flattenedFundusImgNaNs = flattenedFundusImg;
    
    % Make mask of all other vessels
    otherVesselsMask = any(masks(:,:,(1:(numSegments+1)) ~= segmentIdx),3);
    
    % Compute vessel intersection map - set these to NaN in modified image
    intersectionMask = masks(:,:,segmentIdx) & otherVesselsMask;
    flattenedFundusImgNaNs(intersectionMask) = NaN;
    
    % Compute end points for each vessel cross section
    x1 = interpSegments(segmentIdx).xPoints - cos(interpSegments(segmentIdx).angles-pi/2)*crossSectionWidth/2;
    y1 = interpSegments(segmentIdx).yPoints - sin(interpSegments(segmentIdx).angles-pi/2)*crossSectionWidth/2;
    x2 = interpSegments(segmentIdx).xPoints + cos(interpSegments(segmentIdx).angles-pi/2)*crossSectionWidth/2;
    y2 = interpSegments(segmentIdx).yPoints + sin(interpSegments(segmentIdx).angles-pi/2)*crossSectionWidth/2;
    
    % Generate all the interpolation cross section locations and profiles
    numPoints = numel(interpSegments(segmentIdx).xPoints);
    crossSectionsNormal = zeros(numPoints,2*crossSectionWidth+1);
    crossSections = zeros(numPoints,2*crossSectionWidth+1);
    crossSectionsNaNs = zeros(numPoints,2*crossSectionWidth+1);
    vesselBackground = zeros(numPoints,1);
    for pointIdx = 1:numPoints
        xInterp = linspace(x1(pointIdx),x2(pointIdx),2*crossSectionWidth+1);
        yInterp = linspace(y1(pointIdx),y2(pointIdx),2*crossSectionWidth+1);
        crossSectionsNormal(pointIdx,:) = double(interp2(fundusImg,xInterp,yInterp));
        crossSections(pointIdx,:) = double(interp2(flattenedFundusImg,xInterp,yInterp)); %should already be a double--fix?
        crossSectionsNaNs(pointIdx,:) = double(interp2(flattenedFundusImgNaNs,xInterp,yInterp));
        vesselBackground(pointIdx) = double(interp2(estimatedBackgroundImg,interpSegments(segmentIdx).xPoints(pointIdx),interpSegments(segmentIdx).yPoints(pointIdx)));
    end
    
    % Loop through select points of the segment and fit the model
    rList = zeros(numPoints,1);
    uList = rList;
    y0List = rList;
    rSquare = rList;
    for pointIdx = (1+axialFitPeriod):axialFitPeriod:(numPoints-axialFitPeriod)
        % Calculate range of data to use for this fit
        axialStart = pointIdx - axialFitPeriod;
        axialEnd = pointIdx + axialFitPeriod;
        axialIndices = axialStart:axialEnd;
        % Make sure the range is valid
        if axialStart < 1, axialStart = 1; end
        if axialEnd > numPoints, axialEnd = numPoints; end
        axialIndices = axialIndices((axialIndices >= 1) & (axialIndices <= numPoints))- pointIdx;
        
        % Extract the data from straightened vessel cross section image
        crossSectionSubImage = crossSections(axialStart:axialEnd,:);
        crossSectionSubImageNaNs = crossSectionsNaNs(axialStart:axialEnd,:);
        
        % Fit the profile to model
        [fitresult, xData, yData, zData, gof] = fit_chunk(axialIndices,crossSectionIndices,crossSectionSubImageNaNs);
        
        if showProfiles == 1
            % Show the fundus image and current segment chunk
            subplot(1,2,1);
            imshow(norm_contrast(fundusImg));hold on
            x = interpSegments(segmentIdx).xPoints(axialStart:axialEnd);
            y = interpSegments(segmentIdx).yPoints(axialStart:axialEnd);
            line(x,y); hold off;
            
            % Generate a predicted image based on model fit
            [crossGr,axialGr] = meshgrid(crossSectionIndices,axialIndices);
            fitImg = imgaussfilt(fitresult(axialGr,crossGr),2);
            
            % Generate a simulated vessel-free image, that is un-do the
            % exp(-u*2*sqrt(r^2 - x^2)) factor, and also blurring the image
            % slightly
            u = fitresult.u;
            r = fitresult.r;
            y0 = fitresult.y0;
            y = repmat(crossSectionIndices,[numel(axialIndices) 1]);
            vesselFunction = exp(-u*2*upper_semicircle(y,r,y0));
            blurredVesselFunction = imgaussfilt(vesselFunction.^(-1),2);
            noVesselImg = crossSectionSubImage.*blurredVesselFunction;
                        
            % Generate residual image: of image - model
            residsImg = crossSectionSubImage - fitImg;
                        
            % Plot cross section and fit result
            imgs = [norm_contrast([crossSectionSubImage,fitImg,noVesselImg]),norm_contrast(residsImg)];
            imgsScaled = imresize(imgs,[2*size(imgs,1), 2*size(imgs,2)],'nearest');
            subplot(1,2,2)
            imshow(imgsScaled)
            title(['u = ' num2str(u) ', r = ' num2str(r) ', y0 = ' num2str(y0)])
        end
        
        % Save important model parameters (Gaussian FWHM & amplitude)
        rList(pointIdx) = fitresult.r;
        uList(pointIdx) = fitresult.u;
        y0List(pointIdx) = fitresult.y0;
        rSquare = gof.rsquare;
    end
    
    % Interpolate the in-between points
    allPoints = 1:numPoints;
    selectPoints = (1+axialFitPeriod):axialFitPeriod:(numPoints-axialFitPeriod);
    notPoints = allPoints(~ismember(allPoints,selectPoints));
    if numel(selectPoints) > 1
        rList(notPoints) = interp1(selectPoints,rList(selectPoints),notPoints);
        uList(notPoints) = interp1(selectPoints,uList(selectPoints),notPoints);
        y0List(notPoints) = interp1(selectPoints,y0List(selectPoints),notPoints);
    else 
        rList = repmat(rList(selectPoints),[numPoints 1]);
        uList = repmat(uList(selectPoints),[numPoints 1]);
        y0List = repmat(y0List(selectPoints),[numPoints 1]);
    end
       
    % And extrapolate the NaNs at the end
    rList(isnan(rList)) = interp1(allPoints(~isnan(rList)),rList(~isnan(rList)),allPoints(isnan(rList)),'nearest','extrap');
    uList(isnan(uList)) = interp1(allPoints(~isnan(uList)),uList(~isnan(uList)),allPoints(isnan(uList)),'nearest','extrap');
    y0List(isnan(y0List)) = interp1(allPoints(~isnan(y0List)),y0List(~isnan(y0List)),allPoints(isnan(y0List)),'nearest','extrap');

    % Loop through each cross-section point, find min in vessel region and
    % average of outside the vessel on either side
    minList = zeros(numPoints,1);
    surroundList = zeros(numPoints,1);
    for pointIdx = 1:numPoints
        % Find vessel boundaries
        highBound = find(crossSectionIndices==ceil(y0List(pointIdx) + rList(pointIdx)));
        lowBound = find(crossSectionIndices==floor(y0List(pointIdx) - rList(pointIdx)));
        minList(pointIdx) = min(crossSectionsNormal(pointIdx,lowBound:highBound),[],2);
        meanHigh = mean(crossSectionsNormal(pointIdx,(highBound+3):end),2);
        meanLow = mean(crossSectionsNormal(pointIdx,1:(lowBound-3)),2);
        surroundList(pointIdx) = (meanHigh + meanLow)/2;
    end
    
    % Add fit parameters info to output structure
    fitSegments(segmentIdx).rList = rList;
    fitSegments(segmentIdx).uList = uList;
    fitSegments(segmentIdx).y0List = y0List;
    fitSegments(segmentIdx).rSquare = rSquare;
    
    % Add vessel signal and background values
    fitSegments(segmentIdx).vesselBackground = vesselBackground;
    fitSegments(segmentIdx).vesselSignal = vesselBackground.*exp(-2*rList.*uList);
    
    % Add min and estimated surround values
    fitSegments(segmentIdx).minList = minList;
    fitSegments(segmentIdx).surroundList = surroundList;

end
