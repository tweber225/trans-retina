function BWMask = estimate_img_bandwidth(FTStack,stdAboveNoise)

numPix = size(FTStack,1);
% Select just a portion of spectrum well outside pass band to estimate
% noise level stats
centerArea = FTStack(round(2*end/5):round(3*end/5),round(2*end/5):round(3*end/5),:);
noiseStdReal = std(real(centerArea(:)));
noiseStdImag = std(imag(centerArea(:)));

binStackReal = real(FTStack) > stdAboveNoise*noiseStdReal | real(FTStack) < -stdAboveNoise*noiseStdReal;
binStackImag = imag(FTStack) > stdAboveNoise*noiseStdImag | imag(FTStack) < -stdAboveNoise*noiseStdImag;
binStack = binStackReal | binStackImag; 
clear binStackReal binStackImag

% Create mask to select meaningful spatial frequencies in subsequent IFFT
roughMask = (imgaussfilt(sum(fftshift(binStack),3),10) > size(FTStack,3)/2);

% Force to be circular
rSqr = sum(roughMask(:))/pi;
[x,y] = meshgrid(-numPix/2:(numPix/2-1),-numPix/2:(numPix/2-1));
BWMask = (x.^2 + y.^2) < rSqr;