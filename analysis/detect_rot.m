function rotList = detect_rot(inputStack,normOTFCutoff,rotUpsample);
% ANALYSIS/DETECT_ROT
% Detects rotation in the image stack
% 
% Part 3d of standard image processing pipeline
% Timothy D. Weber
% Biomicroscopy Lab, BU 2017

% Get some initial parameters
[xPix,~,numFrames] = size(inputStack);

% Set up a complex exponentiation function, better to compute this way
% rather than raising a double-precision number to various large powers
omegaFactor = @(idx,N) exp(-2*pi*1j*idx/N);

% Based on width of the image and the passed OTF cutoff, calculate max
% radial spatial frequency (rho in polar coordinates)
maxRho = 2*floor(((xPix/2)*normOTFCutoff)/2); % and force it to be even
rhoList = 1:maxRho;

% Calculate the necessary number of angles to prevent aliasing, based on
% sampling the whole circumference times 2 (x2 because we will eventually
% take the power spectrum to use to cross-correlate, and taking the power
% spectrum is a bit like squaring the signal where the bandwidth is
% doubled).
startAngle = 0;
anglePitch = pi/(sqrt(2)*maxRho*pi);
endAngle = pi-anglePitch;
thetaList = startAngle:anglePitch:endAngle;
numThetas = numel(thetaList);
equivTotalUpsampleFreqs = numThetas*rotUpsample;
upsampleRangeRadius = 1.5;

% Apodized parameters 
mainlobeWidth = 1.4648; % Theoretical mainlobe width (-3dB) for Blackman-Harris window

% Perform a radial (polar) DFT2 and return power spectrum
radPowSpec = radial_power_FFT2(inputStack,thetaList,rhoList,mainlobeWidth);
clear inputStack % no longer needed

% Compute Fourier transforms along angular (theta) dimension
angularFTPowSpec = fft(radPowSpec,[],2);
clear radPowSpec

% Compute a mask to remove contributions of impossibly-high angular frequencies
[thetaGr,rhoGr] = meshgrid(thetaList,rhoList);
leftMask = ((rhoGr) >= (thetaGr*2*maxRho/pi));
rightMask = fliplr((rhoGr-1) >= (thetaGr*2*maxRho/pi));
fullMask = leftMask | rightMask;

% Allocate space for list of detected rotations
rotList = zeros(numFrames,1);

% Loop through frames
disp('Detecting rotation...');
percentsVect = 25:25:100;
percentFrames = round(numFrames*percentsVect/100);
for frameIdx = 2:numFrames
    % Compute the normalized cross-power spectrum between (frame #) 1 and frameIdx
    angularXPowSpec = angularFTPowSpec(:,:,1).*conj(angularFTPowSpec(:,:,frameIdx))./abs(angularFTPowSpec(:,:,1).*conj(angularFTPowSpec(:,:,frameIdx)));
    
    % Inverse transform a masked version to obtain angular cross
    % correlation
    angularXCorr = fftshift(ifft(angularXPowSpec.*fullMask,[],2),2);
    
    % Coarse estimate of rotation from peak height
    [~,maxIdx] = max(sum(real(angularXCorr)));
    coarseRotEst = maxIdx - floor(numThetas/2) - 1;
    
    % With the coarse rotation estimate, we can formulate a more precise
    % (inverse) DFT matrix just around the estimate (not the
    % cross-correlation space, since we can be sure the max of the
    % cross-correlation will not be anywhere else)
    freqsToUse = floor((coarseRotEst-upsampleRangeRadius)*rotUpsample):ceil((coarseRotEst+upsampleRangeRadius)*rotUpsample);
    numFreqsToUse = numel(freqsToUse);
    phaseIdxLeft = 0:(ceil(numThetas/2)-1);
    phaseIdxRight = (equivTotalUpsampleFreqs-floor(numThetas/2)):(equivTotalUpsampleFreqs-1);
    phaseFreqIdxMat = freqsToUse'*[phaseIdxLeft, phaseIdxRight];
    targetedDFTMat = omegaFactor(phaseFreqIdxMat,equivTotalUpsampleFreqs);
    
    % Compute the upsampled DFT in the neighborhood of coarse estimate
    % Note: the awkward amount of transposes is so that we can set up the DFT
    % matrix in the conventional configuration (i.e. wikipedia's)
    upsampledAngularXCorr = (targetedDFTMat*(angularXPowSpec.*fullMask)')';
    
    subplot(2,1,1);imagesc(real(upsampledAngularXCorr));
    subplot(2,1,2);plot(sum(real(upsampledAngularXCorr)));drawnow;
    
    [~, maxIdx] = max(sum(real(upsampledAngularXCorr)));
    rotList(frameIdx) = (180/equivTotalUpsampleFreqs)*freqsToUse(maxIdx);
    
    % Display progress
    if sum(percentFrames == frameIdx)
        [~,pIdx] = max(percentFrames == frameIdx);
        disp([num2str(percentsVect(pIdx)) '%']);
    end
end
figure;plot(rotList);
xlabel('Frame #');ylabel('Detected rotation (deg)');






