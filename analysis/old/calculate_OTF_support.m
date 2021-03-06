function normOTFCutoff = calculate_OTF_support(inputStack,thresholdMag,showAnalysis)
% ANALYSIS/CALCULATE_OTF_SUPPORT
% Flattens the image fields
% 
% Part 3c of standard image processing pipeline
% Timothy D. Weber
% Biomicroscopy Lab, BU 2017

disp('Estimating OTF cutoff')
% Determine stack size
[xPix, ~, numFrames] = size(inputStack);

% FFT2 the whole stack and take magnitude
magFFT2Stack = abs(fft2(inputStack));
clear inputStack
for frameIdx = 1:numFrames
    magFFT2Stack(:,:,frameIdx) = fftshift(magFFT2Stack(:,:,frameIdx)); % and fftshift dimensions 1 and 2
end

% Get an average magnitude across the whole stack
magMean = mean(magFFT2Stack,3);
if showAnalysis == 1
    figure;imagesc(log(magMean));title('Average Magnitude Spectrum');drawnow;pause(2);
end

% Interpolate radially outward from the center of the average mag spectrum
numThetas = xPix*pi; % Just the circumference of a circle inscribed to the frame
startAngle = 0;
anglePitch = 360/numThetas;
endAngle = 360-anglePitch;
anglesRad = deg2rad(startAngle:anglePitch:endAngle);
radii = 0:floor(0.5*(xPix-2));

% Warping the frame to get radial line profiles of the average mag spectrum
[polCoordsTheta, polCoordsR] = meshgrid(anglesRad,radii);
[cartNormalCoordsX, cartNormalCoordsY] = meshgrid((-xPix/2):(xPix/2-1),(-xPix/2):(xPix/2-1));
[cartWarpCoordsX, cartWarpCoordsY] = pol2cart(polCoordsTheta,polCoordsR);
warpedMagMean = interp2(cartNormalCoordsX, cartNormalCoordsY, magMean, cartWarpCoordsX, cartWarpCoordsY);
avgRad = mean(warpedMagMean,2);

% Next calculate an average magnitude for frequences in latter half of
% avgRad--where we presume is just noise!
noiseBackground = avgRad(round(end/2):end);
meanNoise = mean(noiseBackground);
stdNoise = std(noiseBackground);

cutoffRho = max(radii(avgRad > (meanNoise + thresholdMag*stdNoise)));
normOTFCutoff = cutoffRho/(xPix/2);
disp(['Detected normalized OTF cutoff: ' num2str(normOTFCutoff)])

if showAnalysis == 1
    figure;plot(log(avgRad));
    hold on;plot(5*(avgRad > (meanNoise + thresholdMag*stdNoise)));
    title('Radial Mean Magnitude and Cutoff');
    legend('Radial average magnitude','OTF support cutoff');drawnow;
end




