camMan = imread('cameraman.tif');
camManRotAngles = [0.5 7.5];
camManStack = zeros(256,256,(1+length(camManRotAngles)));
camManStack(:,:,1) = camMan;

for rotIdx = 1:length(camManRotAngles)
    camManStack(:,:,1+rotIdx) = imrotate(camMan,camManRotAngles(rotIdx),'crop','bilinear');
end

startAngle = 0;
anglePitch = pi/(2*100*pi);
endAngle = pi-anglePitch;
thetaList = startAngle:anglePitch:endAngle;
maxRho = 100;
rhoList = 1:(maxRho);

camManPolarFT = polar_fft2(camManStack,thetaList,rhoList);

%% Compute power spectra
powSpec = camManPolarFT.*conj(camManPolarFT);
circFT = fft(powSpec,[],2);

% crop out stuff that lies within possible 
[numRho,numTheta,numFrames] = size(powSpec);
[thetaGrid,rhoGrid] = meshgrid(thetaList,rhoList);

leftMask = ((rhoGrid) >= (thetaGrid*2*maxRho/pi));
rightMask = fliplr((rhoGrid-1) >= (thetaGrid*2*maxRho/pi));
fullMask = leftMask | rightMask;

for frameIdx = 2:numFrames
    xPowSpec = circFT(:,:,1).*conj(circFT(:,:,frameIdx))./abs(circFT(:,:,1).*conj(circFT(:,:,frameIdx)));
    xCorr = ifft(xPowSpec.*fullMask,[],2);
    subplot(2,1,1);imagesc(real(xCorr));
    subplot(2,1,2);plot(sum(real(xCorr)));hold on;plot(sum(abs(xCorr)));hold off
    pause(4)
end


