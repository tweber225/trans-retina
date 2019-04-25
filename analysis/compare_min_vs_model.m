function compare_min_vs_model(capturePathName)
% Function to compare the cross-section min and surround method vs full
% model estimation for vessel optical density estimation

%% Load images
analysisPath = [capturePathName filesep 'analysis']; 
transImagePath = [analysisPath filesep 'channel2averaged.tif'];
transImage = double(loadtiff(transImagePath));
reflImagePath = [analysisPath filesep 'channel1averaged.tif'];
reflImage = double(loadtiff(reflImagePath));

%% Load fit results
fitDataFileName = [analysisPath filesep 'trans_refl_fits.mat'];
load(fitDataFileName,'interpSegments','transFit','reflFit'); % File should contain these 3 variables (all structures)
numSegments = numel(interpSegments);

% Make directory for saving later
mkdir([analysisPath filesep 'minvsmodel'])

%% Loop through the segments
figure('Renderer', 'painters', 'Position', [50 50 1200 720])
for segmentIdx = 1:numSegments
    % Show images with vessels highlighted
    subplot(2,3,1)
    imshow(norm_contrast(reflImage,[.999,.05])); hold on
    line(interpSegments(segmentIdx).xPoints,interpSegments(segmentIdx).yPoints,'Color','red'); hold off
    title(['Reflection Segment ' interpSegments(segmentIdx).ID])
    subplot(2,3,4)
    imshow(norm_contrast(transImage,[.999,.05])); hold on
    line(interpSegments(segmentIdx).xPoints,interpSegments(segmentIdx).yPoints,'Color','red'); hold off
    title(['Transmission Segment ' interpSegments(segmentIdx).ID])
    
    % Show Min and Surround
    subplot(2,3,2)
    x = 0:.5:(.5*numel(reflFit(segmentIdx).rList)-.5);
    plot(x,reflFit(segmentIdx).minList,'k'); hold on;
    plot(x,reflFit(segmentIdx).surroundList,'k');
    plot(x,reflFit(segmentIdx).vesselSignal,'b');
    plot(x,reflFit(segmentIdx).vesselBackground,'b'); hold off
    subplot(2,3,5)
    x = 0:.5:(.5*numel(transFit(segmentIdx).rList)-.5);
    plot(x,transFit(segmentIdx).minList,'k'); hold on;
    plot(x,transFit(segmentIdx).surroundList,'k');
    plot(x,transFit(segmentIdx).vesselSignal,'b');
    plot(x,transFit(segmentIdx).vesselBackground,'b'); hold off
    
    % Show derived optical densities from the two techniques
    subplot(2,3,3)
    plot(x,-log10(reflFit(segmentIdx).minList./reflFit(segmentIdx).surroundList),'k'); hold on;
    plot(x,-log10(reflFit(segmentIdx).vesselSignal./reflFit(segmentIdx).vesselBackground),'b'); hold off;
    subplot(2,3,6)
    plot(x,-log10(transFit(segmentIdx).minList./transFit(segmentIdx).surroundList),'k'); hold on;
    plot(x,-log10(transFit(segmentIdx).vesselSignal./transFit(segmentIdx).vesselBackground),'b'); hold off;
    
    % Save this figure
    figFilePath = [analysisPath filesep 'minvsmodel' filesep num2str(segmentIdx) '.png'];
    saveas(gcf,figFilePath)
    
end
close