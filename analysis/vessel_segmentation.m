%% Begin vessel segmentation

% Compute central difference gradient for each point
dY = diff(yPoints);
dX = diff(xPoints);
dYCentral = zeros(size(yPoints));
dYCentral(1) = dY(1); dYCentral(end) = dY(end);
dYCentral(2:(end-1)) = (dY(1:(end-1)) + dY(2:end))/2;
dXCentral = zeros(size(xPoints));
dXCentral(1) = dX(1); dXCentral(end) = dX(end);
dXCentral(2:(end-1)) = (dX(1:(end-1)) + dX(2:end))/2;

% Compute tangent angle at each point
angleList = atan(dYCentral./dXCentral);

% Compute vessel cross section lines
crossSectionLength = 32;
xMinList = xPoints - cos(angleList+pi/2)*crossSectionLength/2;
xMaxList = xPoints + cos(angleList+pi/2)*crossSectionLength/2;
yMinList = yPoints - sin(angleList+pi/2)*crossSectionLength/2;
yMaxList = yPoints + sin(angleList+pi/2)*crossSectionLength/2;

% Show cross section lines
imshow(normImg); hold on;
for crossIdx = 1:numPoints
    line([xMinList(crossIdx),xMaxList(crossIdx)],[yMinList(crossIdx),yMaxList(crossIdx)])
end

% Interpolate the vessel cross sections and fit to a preliminary model
figure;
for csIdx = 1:numPoints
    xInterpPoints = linspace(xMinList(csIdx),xMaxList(csIdx),crossSectionLength);
    yInterpPoints = linspace(yMinList(csIdx),yMaxList(csIdx),crossSectionLength);
    crossSection = interp2(normImg,xInterpPoints,yInterpPoints);
    
    [fitResult, ~] = fit_linear_and_neg_gaussian(1:crossSectionLength,double(crossSection));
    pause(.1);drawnow
    
    FWHMList(csIdx) = fitResult.d;
    ampList(csIdx) = fitResult.c;
    
end