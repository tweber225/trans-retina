function [transList,numPeaksList,eccentricList] = detect_trans(inputStack,normOTFCutoff,latUpsample,showAnalysis)
% ANALYSIS/DETECT_TRANS
% Detects translation (i.e. lateral XY movement) in the image stack.
% 
% Part 3f of standard image processing pipeline
% Timothy D. Weber
% Biomicroscopy Lab, BU 2017

maxThresh = .2; % Fraction of the full frame cross-correlation maximum to use as binary threshold for motion detection
eccentricThresh = .1;

% Get pixel size
[xPix,~,numFrames] = size(inputStack);

% Compute upsampling derived parameters
totalUpsampleFreqsX = xPix*latUpsample;
totalUpsampleFreqsY = xPix*latUpsample;

% Set up a complex exponentiation function, better to compute this way
% rather than raising a double-precision number to various large powers
omegaFactor = @(idx,N) exp(-2*pi*1j*idx/N);

% Based on width of the image and the passed OTF cutoff, calculate max
% spatial frequency to contribute to the cross-correlation (anything above
% we consider as fix-pattern noise, and will interfer with translation
% detection)
maxSpatialFreq = (xPix/2)*normOTFCutoff; % does not need to be an integer

% Compute 2D-FFT down the whole stack
disp('Computing 2D-FFT for translation detection');
FTInputStack = fft2(inputStack);
clear inputStack

% Compute mask to remove contributions from out-of-band spatial frequencies
x = (-(xPix/2-.5)):(xPix/2-.5);
[xGr,yGr] = meshgrid(x,x);
binMask = ifftshift((xGr.^2 + yGr.^2) < maxSpatialFreq^2);

% Allocate space for list of detected translations (x,y)
transList = zeros(numFrames,2);
numPeaksList = zeros(numFrames,1);
eccentricList = -ones(numFrames,1);

% Loop through frames
disp('Detecting translation...');
percentsVect = 10:10:100;
percentFrames = round(numFrames*percentsVect/100);
if showAnalysis ==1, figure;end
for frameIdx = 1:numFrames
    % Compute the normalized cross-power spectrum between (frame #) 1 and frameIdx
    xPowSpec = FTInputStack(:,:,1).*conj(FTInputStack(:,:,frameIdx))./abs(FTInputStack(:,:,1).*conj(FTInputStack(:,:,frameIdx)));
    
    % Inverse transform a masked version to obtain cross correlation
    xCorr = fftshift(real(ifft2(xPowSpec.*binMask)));
    
    % Coarse estimate of translation from the peak height
    [maxVal,maxIdxX] = max(max(xCorr,[],1),[],2);
    [~,maxIdxY] = max(max(xCorr,[],2),[],1);
    coarseTransEst = [maxIdxX,maxIdxY] - floor(xPix/2) - 1;
    
    % Check whether there are multiple peaks present-which would indicate
    % motion during the frame
    xCorrThresh = xCorr > (maxVal.*maxThresh);
    connObj = bwconncomp(xCorrThresh,4);
    numPeaksList(frameIdx) = connObj.NumObjects;
    
    % If we don't detect more than one peak in the full frame
    % cross-correlation, then make
    if numPeaksList(frameIdx) == 1
        upsampleRangeRadius = 6;
    else
        upsampleRangeRadius = 1.5;
    end
    
    % With the coarse translation estimate, we can formulate a pair of more
    % precise (inverse) DFT matrices just around the coarse estimate (not
    % the whole cross-correlation space, since we can be sure the max of
    % the cross-correlation will not be anywhere else). We will need to
    % multiply 3 matrices: 1 "left" matrix, responsible for fourier
    % transforming along Y dimensions, 1 image matrix, and 1 "right"
    % matrix, responsible for Fourier transforming along X dimension.
    freqsToUseX = ((-coarseTransEst(1)-upsampleRangeRadius)*latUpsample):((-coarseTransEst(1)+upsampleRangeRadius)*latUpsample);
    freqsToUseY = ((-coarseTransEst(2)-upsampleRangeRadius)*latUpsample):((-coarseTransEst(2)+upsampleRangeRadius)*latUpsample);
    phaseLeft = 0:(ceil(xPix/2)-1);
    phaseRight = (totalUpsampleFreqsY-floor(xPix/2)):(totalUpsampleFreqsY-1);
    phaseTop = 0:(ceil(xPix/2)-1);
    phaseBottom = (totalUpsampleFreqsX-floor(xPix/2)):(totalUpsampleFreqsX-1);
    phaseFreqIdxMatY = freqsToUseY'*[phaseLeft phaseRight];
    phaseFreqIdxMatX = [phaseTop';phaseBottom']*freqsToUseX;

    % Multiply all 3 matrices to get upsampled cross-correlation in
    % neighborhood of the original estimate
    upsampledXCorr = real((omegaFactor(phaseFreqIdxMatY,totalUpsampleFreqsY)*(xPowSpec.*binMask))*omegaFactor(phaseFreqIdxMatX,totalUpsampleFreqsX));

    % Locate maximum in upsampled x-corr
    [maxUpsampledVal, maxIdxX] = max(max(upsampledXCorr,[],1),[],2); 
    [~, maxIdxY] = max(max(upsampledXCorr,[],2),[],1);
    transList(frameIdx,:) = (xPix/totalUpsampleFreqsX)*[freqsToUseX(maxIdxX), freqsToUseY(maxIdxY)];
    
    % If just one local peak is identified in the cross-correlation (which
    % automatically disqualifies it from the "stable" stack), then compute
    % the main peak's eccentricity
    if numPeaksList(frameIdx) == 1
        binPeakMap = upsampledXCorr > (maxUpsampledVal*eccentricThresh);
        regProps = regionprops(binPeakMap,'Eccentricity');
        eccentricList(frameIdx) = regProps(1).Eccentricity;
    end
    
    % Display progress
    if sum(percentFrames == frameIdx)
        [~,pIdx] = max(percentFrames == frameIdx);
        disp([num2str(percentsVect(pIdx)) '%']);
    end
    
    % Display the cross-correlations
    if showAnalysis == 1
        subplot(2,2,1);imagesc(fftshift(angle(xPowSpec)));
        title(['Frame ' num2str(frameIdx) ': Cross-Power Spec. Phase'])
        subplot(2,2,2);imagesc(fftshift(angle(xPowSpec.*binMask)));
        title('Cropped Cross-Power Spec. Phase')
        subplot(2,2,3);imagesc(xCorr);
        title('Full 2D Cross-Corr.')       
        subplot(2,2,4)
        imagesc(upsampledXCorr);
        title(['Upsampled, E=' num2str(eccentricList(frameIdx))]) 
        drawnow;
    end
    
end
if showAnalysis == 1,close;end

% Show x and y translations, velocity magnitude
if showAnalysis ==1
    figure;
    subplot(2,1,1);plot(transList);
    title('Translational movement');xlabel('Frame #');ylabel('Pixels shifted');legend('X','Y')
    subplot(2,1,2);plot((1.5:1:numFrames),sqrt(sum(diff(transList,[],1).^2,2)));
    title('Movement Velocity');xlabel('Frame #');ylabel('Velocity (pixels)');
    drawnow;
end