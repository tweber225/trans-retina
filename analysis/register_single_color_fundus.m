function [regStack xShift yShift thetaShift] = register_single_color_fundus(unregStack,latUpSample,rotUpSample)
% ANALYSIS/REGISTER_SINGLE_COLOR_FUNDUS Function to register a series of
% fundus images from a single color channel. Uses upsampled phase
% correlations to detect lateral and rotational image shifts. The degree of
% upsampling in lateral and rotational directions is given by input
% parameters "latUpSample" and "rotUpSample", respectively. Defaults
% registration precision before upsampling is 1 pixel (lateral) and
% 360/[circumference of inscribed circle] degrees (rotational).
% 
% Part 2 of standard image processing pipeline
% Timothy D. Weber
% Biomicroscopy Lab, BU 2017
tic
% INITIAL PARAMETERS
[xPix, yPix, numFrames] = size(unregStack);
imgDiam = min([xPix yPix]);
numInitialAngles = 2*round((imgDiam*pi)/2); % Force the number angles to be even (necessary for steps below)
% FFT2 WHOLE STACK
FFT2UnregStack = fftshift(fft2(unregStack),1);
FFT2UnregStack = fftshift(FFT2UnregStack,2); % and fftshift dimensions 1 and 2


% ROTATIONAL REGISTRATION
% The idea here is we have multiple concentric rings of values around the
% center of the fft magnitude spectrum. We take Fourier transforms along
% these rings giving multiple realizations of the rotational shift. We can
% estimate the rotation by a weighted average of these realizations.

% Make indices of coordinates
anglesRad = deg2rad(0:(360/numInitialAngles):(360/numInitialAngles)*(numInitialAngles-1));
radii = 1:floor(0.5*(imgDiam-1));
[polCoordsTheta, polCoordsR] = meshgrid(anglesRad,radii);
[cartNormalCoordsX, cartNormalCoordsY] = meshgrid((-(xPix-1)/2):((xPix-1)/2),(-(yPix-1)/2):((yPix-1)/2));
[cartWarpCoordsX, cartWarpCoordsY] = pol2cart(polCoordsTheta,polCoordsR);

% Warp and rotationally-Fourier transform the first frame
warpedFirstFrame = interp2(cartNormalCoordsX, cartNormalCoordsY, abs(FFT2UnregStack(:,:,1)), cartWarpCoordsX, cartWarpCoordsY);
rotFFTFirstFrame = fft(warpedFirstFrame,[],2);

% Calculate DFT matrix parameters for upsampled phase-correlation
totalUpSampleFreqs = numInitialAngles*rotUpSample;

% Create weighting matrix for rotational realizations
weightMat = repmat(radii',[1 numInitialAngles]);

% Compute a handle omega power function ("twiddle" factor), better to
% compute this way rather than raising a double-precision number to various
% large powers
omegaFactor = @(idx,N) exp(-2*pi*1j*idx/N);


for frameIdx = 2:numFrames
    % Interpolate along circular tracks around the center of the image, to
    % make warped image
    warpedFrame = interp2(cartNormalCoordsX, cartNormalCoordsY, abs(FFT2UnregStack(:,:,frameIdx)), cartWarpCoordsX, cartWarpCoordsY);
    
    % 1D FFT along the rotational axis
    rotFFTFrame = fft(warpedFrame,[],2);
    
    % Calculate rotations from Fourier-domain cross-correlation, weight
    % each concentric circle's rotational cross correlation result based on
    % its circumference (correction for unequal interpolated sampling)
    xPowSpec = rotFFTFirstFrame.*conj(rotFFTFrame)./abs(rotFFTFirstFrame.*conj(rotFFTFrame));
    xCorr = ifft(xPowSpec,[],2);
    [~, rotCoarseEst] = max(sum(xCorr.*weightMat,1)./sum(weightMat,1));
    
    % With the coarse estimate of the rotation, we can formulate a more
    % precise (inverse) DFT matrix just around this estimate on the
    % cross-power spectrum (not the whole frequency space, since we can be
    % sure the max of the cross-correlation will not be anywhere else)
    freqsToUseFineGrid = floor((rotCoarseEst-2)*rotUpSample):ceil((rotCoarseEst+2)*rotUpSample);
    phaseIdxLeft = 0:(numInitialAngles/2-1);
    phaseIdxRight = (totalUpSampleFreqs-(numInitialAngles/2)):(totalUpSampleFreqs-1);
    phaseFreqIdxMat = freqsToUseFineGrid'*[phaseIdxLeft, phaseIdxRight];
    
    % Note the awkard amount of transposes is so that we can set up the DFT
    % matrix in the conventional configuration (i.e. wikipedia's)
    targetedDFTMat = omegaFactor(phaseFreqIdxMat,totalUpSampleFreqs); % Neglecting normalization factor
    
    % Compute the upsampled DFT in the neighborhood of coarse estimate
    upsampledXCorr = (targetedDFTMat*(xPowSpec)')';
    
    % weight by the circumference of each circular track
    upsampledWeightMat = repmat(radii',[1 size(freqsToUseFineGrid,2)]);
    [~, maxIdx] = max(sum(upsampledXCorr.*upsampledWeightMat,1));
    upsampledRotEst(frameIdx) = 360*freqsToUseFineGrid(maxIdx)/totalUpSampleFreqs;
end



toc






% LATERAL REGISTRATION
