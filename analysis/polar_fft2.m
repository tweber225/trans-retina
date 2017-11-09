function polFFT2 = polar_fft2(inputStack,thetaList,rhoList)
% Get pixel numbers
[numYPix,numXPix,numFrames] = size(inputStack);
omegaFactor = @(idx,N) exp(-2*pi*1j*idx/N);

% Number of rho's and theta's to find spatial frequency content at
numTheta = numel(thetaList);
numRho = numel(rhoList);

% Make meshgrids for x and y
x = (-(numXPix/2-0.5)):(numXPix/2-0.5);
y = fliplr((-(numYPix/2-0.5)):(numYPix/2-0.5));
[xGrid,yGrid] = meshgrid(x,y);

% Apodize input with circular aperture (3d binary mask)
circAperture = (xGrid.^2 + yGrid.^2) < ((numXPix/2)^2);
apodInputStack = inputStack.*repmat(circAperture,[1 1 numFrames]);

% Convert rho and theta vector to cartesian space (x,y)
[thetaGrid,rhoGrid] = meshgrid(thetaList,rhoList);
[kX,kY] = pol2cart(thetaGrid,rhoGrid);

% Make output matrix
polFFT2 = zeros(numRho,numTheta,numFrames);

parfor thetaIdx = 1:numTheta % Possibly useful to parallelize this
    disp(['Working on theta ' num2str(thetaIdx) ' of ' num2str(numTheta)]);
    for rhoIdx = 1:numRho
        % Generate spatial frequency map
        argMap = xGrid*kX(rhoIdx,thetaIdx) + yGrid*kY(rhoIdx,thetaIdx);
        polFFT2(rhoIdx,thetaIdx,:) = sum(sum(apodInputStack.*repmat(omegaFactor(argMap,numXPix),[1 1 numFrames]),1),2);
    end
end
