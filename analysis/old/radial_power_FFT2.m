function radPowSpec = radial_power_FFT2(inputStack,thetaList,rhoList,mainlobeWidth)
% We will end up doing "chunks" of frames at once
numFramesPerChunk = 1;

% Get input stack dimensions
[xPix,~,numFrames] = size(inputStack);

% Calculate padding ammount based on image size and mainlobe width
regularSampling = mainlobeWidth/4; % to fulfill sampling criterion for regular XY
diagonalSampling = regularSampling/sqrt(2); % to fulfill sampling criterion when path is diagonal;
padPix = 2^nextpow2(xPix/diagonalSampling);
padToEachSide = (padPix/2)-(xPix/2);
padScale = padPix/xPix;
scaledRhoList = rhoList*padScale;

% Number of rho's and theta's to find spatial frequency content at
numTheta = numel(thetaList);
numRho = numel(rhoList);
radPowSpec = zeros(numRho,numTheta,numFrames);

% Create cartesian meshgrid coordinates for interpolation
x = (-padPix/2):(padPix/2-1);
y = x;
z = 1:numFramesPerChunk;
[xGr,yGr] = meshgrid(x,y);

% Now make a meshgrid of the desired theta and rho's
[thetaGr,rhoGr] = meshgrid(thetaList,scaledRhoList);

% Convert polar coordinates to cartesian--to use in interpolation
[xDesired, yDesired] = pol2cart(thetaGr,rhoGr);

% Loop through frame "chunks" computing 2D FFT
disp('Computing radial 2D-DFT (this may be slow) ...');
numChunks = numFrames/numFramesPerChunk;
percentsVect = 10:10:100;
percentChunks = round(numChunks*percentsVect/100);
for chunkIdx = 1:numChunks
    % Pad the current frames and take 2D-FFT (somewhat oversampled FFT)
    frameStart = (chunkIdx-1)*numFramesPerChunk+1;
    frameEnd = (chunkIdx)*numFramesPerChunk;
    FTFrame = fftshift(fftshift(fft2(padarray(inputStack(:,:,frameStart:frameEnd),padToEachSide*[1 1 0],'replicate','both')),2),1);
    % Interpolate to find power of FFT at desired theta & rho coordinates
    for fIdx = 1:numFramesPerChunk
        radPowSpec(:,:,(frameStart+fIdx-1)) = interp2(xGr,yGr,FTFrame(:,:,fIdx).*conj(FTFrame(:,:,fIdx)),xDesired,yDesired,'cubic');
    end
    % Display progress
    if sum(percentChunks == chunkIdx)
        [~,pIdx] = max(percentChunks == chunkIdx);
        disp([num2str(percentsVect(pIdx)) '%']);
    end
end


