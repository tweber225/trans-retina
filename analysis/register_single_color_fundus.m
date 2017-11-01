function [regStack, xShift, yShift, rotEst] = register_single_color_fundus(unregStack,latUpsample,rotUpsample)
% ANALYSIS/REGISTER_SINGLE_COLOR_FUNDUS Function to register a series of
% fundus images from a single color channel. Uses upsampled phase
% correlations to detect lateral and rotational image shifts. The degree of
% upsampling in lateral and rotational directions is given by input
% parameters "latUpsample" and "rotUpsample", respectively. Defaults
% registration precision before upsampling is 1 pixel (lateral) and
% 360/[circumference of inscribed circle] degrees (rotational).
% 
% Part 2 of standard image processing pipeline
% Timothy D. Weber
% Biomicroscopy Lab, BU 2017

tic
% INITIAL PARAMETERS
[yPix, xPix, numFrames] = size(unregStack);
imgDiam = min([xPix yPix]);
numInitialAngles = 2*round((imgDiam*pi)/2); % Force the number angles to be even (necessary for steps below)
% FFT2 WHOLE STACK
FFT2UnregStack = zeros(yPix,xPix,numFrames);
for frameIdx = 1:numFrames
    FFT2UnregStack(:,:,frameIdx) = fftshift(fft2(unregStack(:,:,frameIdx))); % and fftshift dimensions 1 and 2
end

% ROTATIONAL REGISTRATION 
% The idea here is we have multiple concentric rings of values around the
% center of the fft magnitude spectrum. We take Fourier transforms along
% these rings giving multiple realizations of the rotational shift. We can
% estimate the rotation by a weighted average of phase correlations from
% these realizations.

% Make indices of coordinates
startAngle = 360/(2*numInitialAngles);
anglePitch = 360/numInitialAngles;
anglesRad = deg2rad(startAngle:anglePitch:360);
radii = 1:floor(0.5*(imgDiam-1));
[polCoordsTheta, polCoordsR] = meshgrid(anglesRad,radii);
[cartNormalCoordsX, cartNormalCoordsY] = meshgrid((-(xPix-1)/2):((xPix-1)/2),(-(yPix-1)/2):((yPix-1)/2));
[cartWarpCoordsX, cartWarpCoordsY] = pol2cart(polCoordsTheta,polCoordsR);

% Warp and rotationally-Fourier transform the first frame
warpedFirstFrame = interp2(cartNormalCoordsX, cartNormalCoordsY, abs(FFT2UnregStack(:,:,1)), cartWarpCoordsX, cartWarpCoordsY);
rotFFTFirstFrame = fft(warpedFirstFrame,[],2);

% Calculate DFT matrix parameters for upsampled phase-correlation
totalUpsampleFreqs = numInitialAngles*rotUpsample;

% Create weighting matrix for rotational realizations
weightMat = repmat(radii',[1 numInitialAngles]);

% Lateral registration variables
FFT2FirstFrame = FFT2UnregStack(:,:,1);
xShift = zeros(numFrames,1);
yShift = zeros(numFrames,1);

% Compute a handle omega power function ("twiddle" factor), better to
% compute this way rather than raising a double-precision number to various
% large powers
omegaFactor = @(idx,N) exp(-2*pi*1j*idx/N);

% Loop through frames
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
    [~, rotCoarseEst] = max(real(sum(xCorr.*weightMat,1)./sum(weightMat,1)));
    rotCoarseEst = rotCoarseEst-1; % Minus one because finding a max at the first element would mean no shift

    % With the coarse estimate of the rotation, we can formulate a more
    % precise (inverse) DFT matrix just around this estimate on the
    % cross-power spectrum (not the whole frequency space, since we can be
    % sure the max of the cross-correlation will not be anywhere else)
    freqsToUse = floor((rotCoarseEst-2)*rotUpsample):ceil((rotCoarseEst+2)*rotUpsample);
    phaseIdxLeft = 0:(numInitialAngles/2-1);
    phaseIdxRight = (totalUpsampleFreqs-(numInitialAngles/2)):(totalUpsampleFreqs-1);
    phaseFreqIdxMat = freqsToUse'*[phaseIdxLeft, phaseIdxRight];
    
    % Note the awkard amount of transposes is so that we can set up the DFT
    % matrix in the conventional configuration (i.e. wikipedia's)
    targetedDFTMat = omegaFactor(phaseFreqIdxMat,totalUpsampleFreqs); % Neglecting normalization factor
    
    % Compute the upsampled DFT in the neighborhood of coarse estimate
    upsampledXCorr = (targetedDFTMat*(xPowSpec)')';

    % weight by the circumference of each circular track
    upsampledWeightMat = repmat(radii',[1 size(freqsToUse,2)]);
    [~, maxIdx] = max(real(sum(upsampledXCorr.*upsampledWeightMat,1)));
    rotEst(frameIdx) = mod(360*freqsToUse(maxIdx)/totalUpsampleFreqs+180,360)-180;
    
    
    % LATERAL REGISTRATION
    % The same idea as before--determine a rough estimate of the lateral
    % displacement from a phase correlation, then determine sub-pixel
    % registration from upsampled DFT just around that location
    
    % Rotate FFT2 frame by detected ammount
    rotFrame = imrotate(unregStack(:,:,frameIdx),-rotEst(frameIdx),'crop','bilinear');
    FFT2RotFrame = fftshift(fft2(rotFrame));
    % calculate cross power spectrum and cross correlation
    xPowSpec = ifftshift(FFT2FirstFrame.*conj(FFT2RotFrame)./abs(FFT2FirstFrame.*conj(FFT2RotFrame)));
    xCorr = ifft2(xPowSpec);
    
    % Get the max in both x and y
    [~, transCoarseEstX] = max(max(real(xCorr),[],1));
    [~, transCoarseEstY] = max(max(real(xCorr),[],2));
    if transCoarseEstX >= xPix/2
        transCoarseEstX = abs(transCoarseEstX-xPix)+1;
    else
        transCoarseEstX = -transCoarseEstX+1;
    end
    if transCoarseEstY >= yPix/2
        transCoarseEstY = abs(transCoarseEstY-yPix)+1;
    else
        transCoarseEstY = -transCoarseEstY+1;
    end
    
    totalUpsampleFreqsX = xPix*latUpsample;
    totalUpsampleFreqsY = yPix*latUpsample;
    % The targeted DFT in this case needs to be 2D, so we will need to
    % multiply 3 matrices: 1 "left" matrix, responsible for fourier
    % transforming along Y dimensions, 1 image matrix, and 1 "right"
    % matrix, responsible for Fourier transforming along X dimension.
    freqsToUseX = ((transCoarseEstX-3)*latUpsample):((transCoarseEstX+3)*latUpsample);
    freqsToUseY = ((transCoarseEstY-3)*latUpsample):((transCoarseEstY+3)*latUpsample);
    phaseLeft = 0:(yPix/2-1);
    phaseRight = (totalUpsampleFreqsY-(yPix/2)):(totalUpsampleFreqsY-1);
    phaseBottom = (totalUpsampleFreqsX-(xPix/2)):(totalUpsampleFreqsX-1);
    phaseTop = 0:(xPix/2-1);
    phaseFreqIdxMatY = freqsToUseY'*[phaseLeft phaseRight];
    phaseFreqIdxMatX = [phaseTop';phaseBottom']*freqsToUseX;
    
    % Multiply to get DFT-ed cross-correlation
    upsampledXCorr = (omegaFactor(phaseFreqIdxMatY,totalUpsampleFreqsY)*(xPowSpec))*omegaFactor(phaseFreqIdxMatX,totalUpsampleFreqsX);
    imagesc(real(upsampledXCorr));drawnow
    
    % Find new max, rescale to units of pixels
    [~, maxIdxX] = max(max(real(upsampledXCorr),[],1)); 
    [~, maxIdxY] = max(max(real(upsampledXCorr),[],2));
    
    xShift(frameIdx) = xPix*freqsToUseX(maxIdxX)/totalUpsampleFreqsX;
    yShift(frameIdx) = yPix*freqsToUseY(maxIdxY)/totalUpsampleFreqsY;
    
    % Translate back to complete the registration

end

toc


regStack = 0;






