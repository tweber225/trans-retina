function transList = detect_trans(inputStack,normOTFCutoff,latUpsample)
% ANALYSIS/DETECT_TRANS
% Detects translation (i.e. lateral XY movement) in the image stack.
% 
% Part 3f of standard image processing pipeline
% Timothy D. Weber
% Biomicroscopy Lab, BU 2017

% Get pixel size
[xPix,~,numFrames] = size(inputStack);

% Compute upsampling derived parameters
upsampleRangeRadius = 2;
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

% Loop through frames
disp('Detecting translation...');
percentsVect = 10:10:100;
percentFrames = round(numFrames*percentsVect/100);
for frameIdx = 2:numFrames
    % Compute the normalized cross-power spectrum between (frame #) 1 and frameIdx
    xPowSpec = FTInputStack(:,:,1).*conj(FTInputStack(:,:,frameIdx))./abs(FTInputStack(:,:,1).*conj(FTInputStack(:,:,frameIdx)));
    
    % Inverse transform a masked version to obtain cross correlation
    xCorr = fftshift(ifft2(xPowSpec.*binMask));
    
    % Coarse estimate of translation from the peak height
    [~,maxIdxX] = max(max(real(xCorr),[],1),[],2);
    [~,maxIdxY] = max(max(real(xCorr),[],2),[],1);
    coarseTransEst = [maxIdxX,maxIdxY] - floor(xPix/2) - 1;
    
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
    upsampledXCorr = (omegaFactor(phaseFreqIdxMatY,totalUpsampleFreqsY)*(xPowSpec.*binMask))*omegaFactor(phaseFreqIdxMatX,totalUpsampleFreqsX);

    % Locate maximum in upsampled x-corr
    [~, maxIdxX] = max(max(real(upsampledXCorr),[],1),[],2); 
    [~, maxIdxY] = max(max(real(upsampledXCorr),[],2),[],1);
    transList(frameIdx,:) = (xPix/totalUpsampleFreqsX)*[freqsToUseX(maxIdxX), freqsToUseY(maxIdxY)];
    
    % Display progress
    if sum(percentFrames == frameIdx)
        [~,pIdx] = max(percentFrames == frameIdx);
        disp([num2str(percentsVect(pIdx)) '%']);
    end
end