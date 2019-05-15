% Script to load 2 vessel fits (and the average images) and compare them

%% List the capture paths for the two image sets
capturePathName1 = 'U:\eng_research_biomicroscopy\Data\BME-BIOMC-24\20190413\subject001_capture005';
capturePathName2 = 'U:\eng_research_biomicroscopy\Data\BME-BIOMC-24\20190413\subject001_capture006';

%% Load images
analysisPath1 = [capturePathName1 filesep 'analysis']; 
mkdir([analysisPath1 filesep 'capturecompare'])

transImagePath1 = [analysisPath1 filesep 'channel2averaged.tif'];
transImage1 = double(loadtiff(transImagePath1));

analysisPath2 = [capturePathName2 filesep 'analysis']; 
transImagePath2 = [analysisPath2 filesep 'channel2averaged.tif'];
transImage2 = double(loadtiff(transImagePath2));

reflImagePath1 = [analysisPath1 filesep 'channel1averaged.tif'];
reflImage1 = double(loadtiff(reflImagePath1));

reflImagePath2 = [analysisPath2 filesep 'channel1averaged.tif'];
reflImage2 = double(loadtiff(reflImagePath2));

%% Load fitting results
fitDataFileName1 = [analysisPath1 filesep 'trans_refl_fits.mat'];
load(fitDataFileName1,'interpSegments','transFit','reflFit'); % File should contain these 3 variables (all structures), 
interpSegments1 = interpSegments; clear interpSegments;
transFit1 = transFit; clear transFit;
reflFit1 = reflFit; clear reflFit;

fitDataFileName2 = [analysisPath2 filesep 'trans_refl_fits.mat'];
load(fitDataFileName2,'interpSegments','transFit','reflFit'); % File should contain these 3 variables (all structures), 
interpSegments2 = interpSegments; clear interpSegments;
transFit2 = transFit; clear transFit;
reflFit2 = reflFit; clear reflFit;


% Order vessels to show
cap1Order = {'1','1-1','1-2','1-4','2','2-1','3','4','7','8','8-1','9','12','13','14'};
cap2Order = {'1','1-2','1-1','1-3','2','2-1','3','4','7','8','8-1','9','12','13','14'};

numSegments = numel(cap1Order);
segmentsIndices1 = 1:numel(interpSegments1);
segmentsIndices2 = 1:numel(interpSegments2);

figure('Renderer', 'painters', 'Position', [50 50 1200 720])

% Loop through the selected segments
for segmentIdx = 1:numSegments
    % Determine capture 1 and 2's segment number for current segment ID
    interp1CellArray = struct2cell(interpSegments1);
    cap1SegNum = segmentsIndices1(strcmp(squeeze(interp1CellArray(1,:,:)),cap1Order{segmentIdx}));
    interp2CellArray = struct2cell(interpSegments2);
    cap2SegNum = segmentsIndices2(strcmp(squeeze(interp2CellArray(1,:,:)),cap2Order{segmentIdx}));
    
    % Show images and highlight the vessel segments on each
    subplot(2,3,1)
    imshow(norm_contrast(reflImage1,[.999,.05])); hold on
    line(interpSegments1(cap1SegNum).xPoints,interpSegments1(cap1SegNum).yPoints,'Color','blue'); hold off
    title(['Reflection 1 Segment ' cap1Order{segmentIdx}])
    
    subplot(2,3,4)
    imshow(norm_contrast(reflImage2,[.999,.05])); hold on
    line(interpSegments2(cap2SegNum).xPoints,interpSegments2(cap2SegNum).yPoints,'Color','blue','LineStyle','--'); hold off
    title(['Reflection 2 Segment ' cap2Order{segmentIdx}])
    
    subplot(2,3,2)
    imshow(norm_contrast(transImage1,[.999,.05])); hold on
    line(interpSegments1(cap1SegNum).xPoints,interpSegments1(cap1SegNum).yPoints,'Color','red'); hold off
    title(['Transmission 2 Segment ' cap1Order{segmentIdx}])
    
    subplot(2,3,5)
    imshow(norm_contrast(transImage2,[.999,.05])); hold on
    line(interpSegments2(cap2SegNum).xPoints,interpSegments2(cap2SegNum).yPoints,'Color','red','LineStyle','--'); hold off
    title(['Transmission 2 Segment ' cap2Order{segmentIdx}])
    
    % Show radius and extinction plots
    x1 = 0:.5:(.5*numel(transFit1(cap1SegNum).rList)-.5);
    x2 = 0:.5:(.5*numel(transFit2(cap2SegNum).rList)-.5);
    subplot(2,3,3)
    plot(x1,transFit1(cap1SegNum).rList,'r'); hold on
    plot(x2,transFit2(cap2SegNum).rList,'r','LineStyle','--');
    plot(x1,reflFit1(cap1SegNum).rList,'b');
    plot(x2,reflFit2(cap2SegNum).rList,'b','LineStyle','--'); hold off
    ylim([0 7.5])
    title('Estimated Caliber')
    xlabel('Distance along vessel segment (pixels)')
    ylabel('Radius (pixels)')
    
    subplot(2,3,6)
    plot(x1,transFit1(cap1SegNum).uList,'r'); hold on
    plot(x2,transFit2(cap2SegNum).uList,'r','LineStyle','--');
    plot(x1,reflFit1(cap1SegNum).uList,'b');
    plot(x2,reflFit2(cap2SegNum).uList,'b','LineStyle','--'); hold off
    ylim([0 10e-3])
    title('Estimated Extinction')
    xlabel('Distance along vessel segment (pixels)')
    ylabel(texlabel('mu_e (pixels^(-1))'))
    
    drawnow;
    
    % Save this figure
    figFilePath = [analysisPath1 filesep '2capturecompare' filesep num2str(segmentIdx) '.png'];
    saveas(gcf,figFilePath)
    
    
end


