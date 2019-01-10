function [stableStack,includeFrames] = exclude_motion(registeredStack,transList,numPeaksList,eccentricList,normOTFCutoff,showAnalysis)
% ANALYSIS/EXCLUDE_MOTION
% Excludes certain frames based on detected motion. Criteria for excluding:
% +/- 1 frame on either side of a multi-peak detected cross-correlation
% any frame with cross-correlation peak's eccentricity is >.5
% -and any frame with eccentricity > mean(remaining frames) + 1.1*std(remaining frames)
% frames on either side of a jump in position > 2x (OTF cutoff)^-1
% 
% Part 3h of standard image processing pipeline
% Timothy D. Weber
% Biomicroscopy Lab, BU 2017

numFrames = size(registeredStack,3);

% +/- 1 frame on either side of a multi-peak detected cross-correlation
multiPeakFrames = (numPeaksList>1);
multiPeakFramesAndNeighbors = multiPeakFrames + [0;multiPeakFrames(1:(end-1))] + [multiPeakFrames(2:end);0];
includeFrames = ~logical(multiPeakFramesAndNeighbors);

% any frame with cross-correlation peak's eccentricity is >.5
% and any frame with eccentricity > mean(remaining frames) + 1.1*std(remaining frames)
secondEccentricThreshold = mean(eccentricList(eccentricList<.5 & eccentricList>0)) + 1.1*std(eccentricList(eccentricList<.5 & eccentricList>0));
notTooEccentricList = (eccentricList <= secondEccentricThreshold);
includeFrames = includeFrames & notTooEccentricList;

% frames on either side of a jump in position > 1.5x (OTF cutoff)^-1
jumpThresh = (1.5/normOTFCutoff);
frameVelocities = sqrt(sum(diff(transList,[],1).^2,2));
jumperFrames = (frameVelocities > jumpThresh);
jumperFrames = [0;jumperFrames] + [jumperFrames;0];
includeFrames = includeFrames & ~logical(jumperFrames);

% Show detected motion-corrupted frames
if showAnalysis == 1
    eccentricList2 = eccentricList;
    eccentricList2(eccentricList2<0) = 0; % set the negative values to 0 (negative is a flag, not useful here)
    fList = (1:numFrames)';
    
    figure;
    subplot(3,1,1)
    plotyy(fList,numPeaksList,fList,eccentricList2)
    title('Num Detected Peaks and Eccentricity');xlabel('Frame #');
    subplot(3,1,2)
    plot(.5+fList(1:(end-1)),frameVelocities);
    title('Inter-frame Velocity');xlabel('Frame #');ylabel('Pixels/frame')
    subplot(3,1,3)
    plot(fList,logical(multiPeakFramesAndNeighbors),'ko');hold on;
    plot(fList,logical(~notTooEccentricList) & logical(~multiPeakFramesAndNeighbors),'ro')
    plot(fList,logical(jumperFrames) & logical(~multiPeakFramesAndNeighbors) & logical(notTooEccentricList),'bo')
    title('Reason for exclusion');legend('Multiple XCorr Peaks','XCorr Main Peak Eccentricity','Velocity');xlabel('Frame #')
    disp(['Excluded ' num2str(numFrames-sum(logical(includeFrames))) ' frames of ' num2str(numFrames) ' (' num2str(round(100*(numFrames-sum(logical(includeFrames)))/numFrames)) '%) from stabilized stack'])
    drawnow;
end
    
% Finally splice out the motion-corrupted frames and pass a new stack
stableStack = registeredStack(:,:,logical(includeFrames));


