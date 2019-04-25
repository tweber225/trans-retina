% Script to try to estimate a low (spatial) number of parameter fit for
% intraocular scattering. Just uses 2nd channel (transmission)

%% Load images
capturePathName = 'U:\eng_research_biomicroscopy\Data\BME-BIOMC-24\20190413\subject001_capture006';
analysisPath = [capturePathName filesep 'analysis']; 
transImagePath = [analysisPath filesep 'channel2averaged.tif'];
transImage = double(loadtiff(transImagePath));

%% Load fit results
fitDataFileName = [analysisPath filesep 'trans_refl_fits.mat'];
load(fitDataFileName,'interpSegments','transFit'); % File should contain these 3 variables (all structures)
numSegments = numel(interpSegments);

% Make directory for saving later
%mkdir([analysisPath filesep 'ios']);

%% Estimate the intraocular scattering
% Estimate function jointly from multiple segments
chosenVesselIDs = {'1-2','8','8-1','12','13'};
numChosenIDs = numel(chosenVesselIDs);

allSegmentsIndices = 1:numSegments;
interpCellArray = struct2cell(interpSegments);

% Allocate space
maxVesselLength = 1500;
xData = zeros(maxVesselLength,numChosenIDs);
yData = zeros(maxVesselLength,numChosenIDs);
Iest = zeros(maxVesselLength,numChosenIDs);
I0est = zeros(maxVesselLength,numChosenIDs);
L = zeros(maxVesselLength,numChosenIDs);

% Loop through the chosen segments extracting data for optimization
for chosenIdx = 1:numChosenIDs
    segmentIdx = allSegmentsIndices(strcmp(squeeze(interpCellArray(1,:,:)),chosenVesselIDs{chosenIdx}));

    numPointsSegment = numel(transFit(segmentIdx).vesselSignal);
    startPoint = round(.1*numPointsSegment);
    endPoint = round(.95*numPointsSegment);

    % Rename a couple variables for min problem
    xData(startPoint:endPoint,chosenIdx) = interpSegments(segmentIdx).xPoints(startPoint:endPoint);
    yData(startPoint:endPoint,chosenIdx) = interpSegments(segmentIdx).yPoints(startPoint:endPoint);
    Iest(startPoint:endPoint,chosenIdx) = transFit(segmentIdx).vesselSignal(startPoint:endPoint);
    I0est(startPoint:endPoint,chosenIdx) = transFit(segmentIdx).vesselBackground(startPoint:endPoint);
    L(startPoint:endPoint,chosenIdx) = 2*transFit(segmentIdx).rList(startPoint:endPoint);
    
end

%% Make minimization problem
R = maxVesselLength; % for clarity below
% x(1) is const b term of IOS
% x(2) is m1 term related to x-slope of IOS
% x(3:end) are mu_e terms
fun = @(x) sum(sum( (Iest - I0est.*exp(-x(ones(R,1),3:end).*L) - (x(1)+x(2).*xData).*(1-exp(-x(ones(R,1),3:end).*L))).^2 ));
x0 = [500,-1,repmat(.01,[1,numChosenIDs])];
LB = [0,-Inf,repmat(0,[1,numChosenIDs])];
UB = [1000,0,repmat(Inf,[1,numChosenIDs])];
options = optimset('MaxFunEvals',numel(x0)*1000);
paramsOut = fminsearchbnd(fun,x0,LB,UB,options);

ios = paramsOut(1);

%% Show result on figure
figure('Renderer', 'painters', 'Position', [150 150 1500 700])

subplot(1,2,1)
imshow(norm_contrast(transImage,[.999,.05])); hold on
colorList = lines(numChosenIDs);
for chosenIdx = 1:numChosenIDs
    pointsToShow = xData(:,chosenIdx)~=0;
    line(xData(pointsToShow,chosenIdx),yData(pointsToShow,chosenIdx),'Color',colorList(chosenIdx,:))
end
hold off

subplot(1,2,2)
hold on
for chosenIdx = 1:numChosenIDs
    pointsToShow = xData(:,chosenIdx)~=0;
    plot(-log(Iest(pointsToShow,chosenIdx)./I0est(pointsToShow,chosenIdx))./L(pointsToShow,chosenIdx),'Color',colorList(chosenIdx,:),'LineStyle','--')
    plot(-log((Iest(pointsToShow,chosenIdx)-ios)./(I0est(pointsToShow,chosenIdx)-ios))./L(pointsToShow,chosenIdx),'Color',colorList(chosenIdx,:))
end



