function radPowSpec = radial_power_FFT2(inputStack,thetaList,rhoList,mainlobeWidth)

% Get input stack dimensions
[xPix,~,numFrames] = size(inputStack);

% Calculate padding ammount based on image size and mainlobe width
regularSampling = mainlobeWidth/2; % to fulfill sampling criterion for regular XY
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
[xGr,yGr] = meshgrid(x,y);

% Now make a meshgrid of the desired theta and rho's
[thetaGr,rhoGr] = meshgrid(thetaList,scaledRhoList);

% Convert polar coordinates to cartesian--to use in interpolation
[xDesired, yDesired] = pol2cart(thetaGr,rhoGr);

% Loop through frame computing 2D FFT
disp('Computing radial 2D-DFT...');
percentsVect = 10:10:100;
percentFrames = round(numFrames*percentsVect/100);
for frameIdx = 1:numFrames
    % Pad the current frame and take 2D-FFT (somewhat oversampled FFT)
    FTFrame = fftshift(fft2(padarray(inputStack(:,:,frameIdx),padToEachSide*[1 1],'replicate','both')));
    
    % Interpolate to find power of FFT at desired theta & rho coordinates
    radPowSpec(:,:,frameIdx) = interp2(xGr,yGr,FTFrame.*conj(FTFrame),xDesired,yDesired,'cubic');
    
    % Display progress
    if sum(percentFrames == frameIdx)
        [~,pIdx] = max(percentFrames == frameIdx);
        disp([num2str(percentsVect(pIdx)) '%']);
    end
end


