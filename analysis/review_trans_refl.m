function review_trans_refl(capturePathName)
% To review vessel fitting results and compare betwen transmission and
% reflection modalities

%% Load the data
analysisPath = [capturePathName filesep 'analysis'];
fundusImg = double(loadtiff([analysisPath filesep 'channel1averaged.tif']));
fitDataFileName = [analysisPath filesep 'trans_refl_fits.mat'];
load(fitDataFileName,'interpSegments','transFit','reflFit'); % File should contain these 3 variables (all structures), 
numSegments = numel(interpSegments);

% Make a directory
mkdir([analysisPath filesep 'segmentfits'])


%% Plots of individual vessels and their locations
for segmentIdx = 1:numSegments
    vesselAxialPosition = 0:.5:(.5*numel(interpSegments(segmentIdx).xPoints)-.5);
    
    % Identify where the vessel is located
    subplot(2,2,[1 3])
    imshow(norm_contrast(fundusImg));hold on;
    line(interpSegments(segmentIdx).xPoints,interpSegments(segmentIdx).yPoints)
    hold off;
    
    
    % Plot vessel radii
    subplot(2,2,2)
    plot(vesselAxialPosition,transFit(segmentIdx).rList); hold on;
    plot(vesselAxialPosition,reflFit(segmentIdx).rList);
    title('Radii')
    ylabel('Radius (pixels)')
    xlabel('Position along vessel segment (pixels)')
    legend('Transmission','Reflection')
    hold off;
    
    % Plot vessel extinction coefficient
    subplot(2,2,4)
    plot(vesselAxialPosition,transFit(segmentIdx).uList); hold on;
    plot(vesselAxialPosition,reflFit(segmentIdx).uList);
    title('Extinction')
    ylabel(texlabel('mu_e (pixels^(-1))'));
    xlabel('Position along vessel segment (pixels)')
    legend('Transmission','Reflection')
    hold off;
    
    drawnow
    
    % Save the figure
    figFilePath = [analysisPath filesep 'segmentfits' filesep num2str(segmentIdx) '.png'];
    saveas(gcf,figFilePath);
    
end

%% Plots of all the vessels
figure('Renderer', 'painters', 'Position', [50 50 1600 900])

%% Review radii
transList = [];
reflList = [];
breakList = [];
for segmentIdx = 1:numSegments
    transList = [transList; transFit(segmentIdx).rList];
    reflList = [reflList; reflFit(segmentIdx).rList];
    breakList = [breakList; numel(transList)];
end
subplot(2,1,1)
plot(transList,'.');
hold on;plot(reflList,'.');

% Apply some labels
for segmentIdx = 1:numSegments 
    line([breakList(segmentIdx) breakList(segmentIdx)],[0 10],'Color','black','LineWidth',1); 
    if segmentIdx > 1
        midXPos = (breakList(segmentIdx)+breakList(segmentIdx-1))/2;
    else
        midXPos = breakList(segmentIdx)/2;
    end
    text(midXPos,7-.5*mod(segmentIdx,2),interpSegments(segmentIdx).ID,'HorizontalAlignment','center');
    
end
hold off
title('Estimated Vessel Caliber');ylabel('Radii (pixels)');
legend('Transmission','Reflection')


%% Review extinction coefficient
transList = [];
reflList = [];
breakList = [];
for segmentIdx = 1:numSegments
    transList = [transList; transFit(segmentIdx).uList];
    reflList = [reflList; reflFit(segmentIdx).uList];
    breakList = [breakList; numel(transList)];
end
subplot(2,1,2)
plot(transList,'.');
hold on;plot(reflList,'.');

% Apply some labels
for segmentIdx = 1:numSegments 
    line([breakList(segmentIdx) breakList(segmentIdx)],[0 .015],'Color','black','LineWidth',1); 
    if segmentIdx > 1
        midXPos = (breakList(segmentIdx)+breakList(segmentIdx-1))/2;
    else
        midXPos = breakList(segmentIdx)/2;
    end
    text(midXPos,.01-.001*mod(segmentIdx,2),interpSegments(segmentIdx).ID,'HorizontalAlignment','center');
    
end
hold off
title('Estimated Extinction Coefficient');ylabel(texlabel('mu_e (pixels^(-1))'));
legend('Transmission','Reflection')

% Save this figure
figFilePath = [analysisPath filesep 'radius_extinction_fits.png'];
saveas(gcf,figFilePath)