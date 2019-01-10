function [transList,XCPeaks] = detect_translation(BWMask,frameStack,regOpt)

numPointsToUpSample = 2*regOpt.pixelZoomRange/regOpt.subPixelPrecision;

numFrames = size(frameStack,3);
numPixels = size(frameStack,1);

% Multiply the frame stack by blackman harris window function
BHWindow = blackman_harris(numPixels);
frameStack = frameStack.*BHWindow(:,:,ones(1,numFrames));

coarseTransList = zeros(numFrames,2); % 1st column is X
fineTransList = coarseTransList;
XCPeaks = zeros(numFrames,1);

% Tweak the bandwidth mask to eliminate contibution for the very center
centerRad = regOpt.minRhoTrans;
pixRange = (-numPixels/2):(numPixels/2-1);
[kx,ky] = meshgrid(pixRange,pixRange);
BWMask = BWMask & (kx.^2+ky.^2 > centerRad^2);

% Do X-corrs in chunks to not tie up all the memory
numChunks = floor(numFrames/regOpt.transChunkSize);
extraFrames = numFrames - numChunks*regOpt.transChunkSize;

% Compute reference frame's spectrum
FTRefFrame = fft2(frameStack(:,:,regOpt.refFrameNumber));


%% Go through each chunk
for cIdx = 1:numChunks
    disp(['Computing translational cross correlations, set ' num2str(cIdx) ' of ' num2str(numChunks)])

    fStart = (cIdx-1)*regOpt.transChunkSize;
    FTStack = fft2(frameStack(:,:,(fStart+1):(fStart+regOpt.transChunkSize)));

    XPowSpecStack = FTRefFrame(:,:,ones(1,regOpt.transChunkSize)).*conj(FTStack);
    clear FTStack

    normXPowSpecStack = XPowSpecStack./abs(XPowSpecStack).*repmat(ifftshift(BWMask),[1 1 regOpt.transChunkSize]);
    XCorrStack = real(ifft2(normXPowSpecStack));

    [~,maxIndices] = max(reshape(fftshift(fftshift(XCorrStack,1),2),[numPixels^2 regOpt.transChunkSize]),[],1);
    [y,x] = ind2sub([numPixels numPixels],maxIndices);
    coarseTransList((fStart+1):(fStart+regOpt.transChunkSize),:) = -[x',y'] + repmat(numPixels/2 +1,[regOpt.transChunkSize,2]);

    % In each case the spacing is the same for the CZT, only the starting
    % point, a is changing
    w = exp(-1i*2*pi*2*regOpt.pixelZoomRange/(numPixels*numPointsToUpSample));
    m = numPointsToUpSample;
    for fIdx = 1:regOpt.transChunkSize
        % CZT in the y, then x direction
        ay = exp(-2i*pi*(regOpt.pixelZoomRange-coarseTransList(fStart+fIdx,2))/numPixels);
        ax = exp(-2i*pi*(regOpt.pixelZoomRange+coarseTransList(fStart+fIdx,1))/numPixels);
        cztY = czt(fftshift(normXPowSpecStack(:,:,fIdx)),m,w,ay);
        zoomXCorr = czt(cztY',m,w,ax)';

        % Find max location
        [XCPeak, maxIndex] = max(abs(zoomXCorr(:)));
        XCPeaks(fStart+fIdx) = XCPeak;
        [y,x] = ind2sub([m m],maxIndex);
        fineTransList(fStart+fIdx,:) = [x,y];

    end
end

%% Extra frames
efStart = numChunks*regOpt.transChunkSize;
FTStack = fft2(frameStack(:,:,(efStart+1):(efStart+extraFrames)));

XPowSpecStack = FTRefFrame(:,:,1:extraFrames).*conj(FTStack);
clear FTRefFrameStack FTStack

normXPowSpecStack = XPowSpecStack./abs(XPowSpecStack).*repmat(ifftshift(BWMask),[1 1 extraFrames]);
XCorrStack = real(ifft2(normXPowSpecStack));

[~,maxIndices] = max(reshape(fftshift(fftshift(XCorrStack,1),2),[numPixels^2 extraFrames]),[],1);
[y,x] = ind2sub([numPixels numPixels],maxIndices);
coarseTransList((efStart+1):(efStart+extraFrames),:) = -[x',y'] + repmat(numPixels/2 +1,[extraFrames,2]);

% In each case the spacing is the same for the CZT, only the starting
% point, a is changing
w = exp(-1i*2*pi*2*regOpt.pixelZoomRange/(numPixels*numPointsToUpSample));
m = numPointsToUpSample;
for fIdx = 1:extraFrames
    % CZT in the y, then x direction
    ay = exp(-2i*pi*(regOpt.pixelZoomRange-coarseTransList(fIdx,2))/numPixels);
    ax = exp(-2i*pi*(regOpt.pixelZoomRange+coarseTransList(fIdx,1))/numPixels);
    cztY = czt(fftshift(normXPowSpecStack(:,:,fIdx)),m,w,ay);
    zoomXCorr = czt(cztY',m,w,ax)';
       
    % Find max location
    [XCPeak, maxIndex] = max(abs(zoomXCorr(:)));
    XCPeaks(efStart+fIdx) = XCPeak;
    [y,x] = ind2sub([m m],maxIndex);
    fineTransList(efStart+fIdx,:) = [x,y];
    
end


%% Finally compute the final translations from coarse and fine lists
transList = coarseTransList + repmat([-1 1],[numFrames,1]).*(fineTransList-(1+m/2))*regOpt.subPixelPrecision;

