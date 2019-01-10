function [rotList,corrPeakList] = detect_rotation(BWMask,croppedFrameStack,regOpt)

% Set up rotation list
numFrames = size(croppedFrameStack,3);
rotList = zeros(numFrames,1);
corrPeakList = zeros(numFrames,1);
pixPerSide = size(croppedFrameStack,1);

% Terminate if rotation registration is skipped
if regOpt.skipRotation
    disp('Skipping rotational registration')
    return
end

rhoMin = regOpt.rhoMin;
rhoMax = floor(sqrt(sum(sum(BWMask))/pi)); % geometric mean radius of mask
numAngles = rhoMax*8; % to span the 1 outer edge: 2x rhoMax, then we have two ...
% .. edges (leading to pi polar DFT range), and one more factor 2 for
% squaring in frequency domain leading to convolution in real domain (after
% doing the ifft)

% Compute the polar DFT, in chunks at a time, due to memory constraints
numChunks = ceil(numFrames/regOpt.polDFTChunkSize);
polarDFT = zeros(length(rhoMin:rhoMax),numAngles,numFrames);
windowFunction = repmat(blackman_harris(pixPerSide),[1 1 regOpt.polDFTChunkSize]);

for chunkIdx = 1:numChunks
    disp(['Computing polar FFT chunk ' num2str(chunkIdx) ' of ' num2str(numChunks)])
    fStart = 1+regOpt.polDFTChunkSize*(chunkIdx-1);
    fEnd = regOpt.polDFTChunkSize*chunkIdx;
    polarDFT(:,:,fStart:fEnd) = polar_fft2(double(croppedFrameStack(:,:,fStart:fEnd)).*windowFunction,rhoMin,rhoMax,numAngles,regOpt.polDFTUpSampleFactor);
end

% FT the squared magnitude spectrum wrt angular dimension
thetaFTConj = conj(fft(abs(polarDFT).^2,[],2));
thetaFTRef = conj(thetaFTConj(:,:,regOpt.refFrameNumber));

% Create a mask to block out contributions from impossibly-high frequencies
[x,y] = meshgrid(1:numAngles,rhoMin:rhoMax);
leftHalfMask = (y >= x/2+1);
rightHalfMask = fliplr(y >= x/2);
mask = rightHalfMask + leftHalfMask;

% Parameters for chirp z transform used in loop
m = regOpt.maxAngle*2/regOpt.angleRes;
a = exp(1i*2*pi*regOpt.maxAngle/pi); 
w = exp(1i*2*pi*2*regOpt.maxAngle/m/pi); 

% Compute cross-correlations
disp('Computing rotational cross-correlations')
for frameIdx = 1:numFrames
    XPowSpec = thetaFTRef.*thetaFTConj(:,:,frameIdx);
    normXPowSpec = (XPowSpec./abs(XPowSpec)).*mask;   
    normXPowSpec = ifftshift(normXPowSpec,2);
       
    % Now since rotation is usually within a couple degrees, just do zoomed
    % FFT in this range
    xCorr = abs(czt(normXPowSpec',m,w,a));
    [corrPeakList(frameIdx),rotList(frameIdx)] = max(sum(xCorr,2));
end

% Finally convert the indices to real radians of rotation
rotList = -(rotList-rotList(regOpt.refFrameNumber))*regOpt.angleRes;

% And fix any very bad correlations
inversePeak = corrPeakList.^(-1);
badFramesList = inversePeak > 2*mean(inversePeak);
rotList(badFramesList) = 0; % just set them to 0 for now

