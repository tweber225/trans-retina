function [regStack xShift yShift thetaShift] = register_single_color_fundus(unregStack,latUpSample,rotUpSample)
% ANALYSIS/REGISTER_SINGLE_COLOR_FUNDUS Function to register a series of
% fundus images from a single color channel. Uses upsampled phase
% correlations to detect lateral and rotational image shifts. The degree of
% upsampling in lateral and rotational directions is given by input
% parameters "latUpSample" and "rotUpSample", respectively. Defaults
% registration precision before upsampling is 1 pixel (lateral) and 1
% degree (rotational).
% 
% Part 2 of standard image processing pipeline
% Timothy D. Weber
% Biomicroscopy Lab, BU 2017

% INITIAL PARAMETERS
[xPix, yPix, numFrames] = size(unregStack);
numInitialAngles = 360;
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
radii = 1:floor(0.5*min([xPix,yPix]));
[polCoordsTheta, polCoordsR] = meshgrid(anglesRad,radii);
[cartNormalCoordsX, cartNormalCoordsY] = meshgrid((-(xPix-1)/2):((xPix-1)/2),(-(yPix-1)/2):((yPix-1)/2));
[cartWarpCoordsX, cartWarpCoordsY] = pol2cart(polCoordsTheta,polCoordsR);

rotFFTStack = zeros([size(cartWarpCoordsX,1), size(cartWarpCoordsX,2), numFrames]);
for frameIdx = 1:numFrames
    % Interpolate along circular tracks around the center of the image, to
    % make warped image
    warpedImage = interp2(cartNormalCoordsX, cartNormalCoordsY, abs(FFT2UnregStack(:,:,frameIdx)), cartWarpCoordsX, cartWarpCoordsY);
    
    % 1D FFT along the rotational axis
    rotFFTStack(:,:,frameIdx) = fftshift(fft(warpedImage,[],2),2);
end

% Calculate rotations from Fourier-domain cross-correlation
for frameIdx = 2:numFrames
    hmm = rotFFTStack(:,:,1).*conj(rotFFTStack(:,:,frameIdx))./abs(rotFFTStack(:,:,1).*conj(rotFFTStack(:,:,frameIdx)));
end
spy

% parseval weight correction?




% LATERAL REGISTRATION
