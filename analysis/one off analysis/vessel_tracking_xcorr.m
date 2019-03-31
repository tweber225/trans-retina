% assume there's a single-prec image called fundus in workspace

% get starting point
imshow(fundus./max(fundus(:)))
[xi,yi] = getpts;
close

% zoom in a bit to get best starting point
zoomRes = 64;
zoomScale = 8;
xZoomPix = (round(xi)-zoomRes/2):(round(xi)+zoomRes/2);
yZoomPix = (round(yi)-zoomRes/2):(round(yi)+zoomRes/2);
zoomedFundus = fundus(yZoomPix,xZoomPix);
contrastZoomedFundus = (zoomedFundus-min(zoomedFundus(:)))./(max(zoomedFundus(:))-min(zoomedFundus(:)));

imshow(imresize(contrastZoomedFundus,zoomScale));
[xiZoom,yiZoom] = getpts;
close

% Compute global coordinates
subpixelXi = round(xi)-zoomRes/2 + (xiZoom-1)/zoomScale;
subpixelYi = round(yi)-zoomRes/2 + (yiZoom-1)/zoomScale;

% Auto correlate image patchs
patchSize = 16*2;
patchScale = 16;
interpPixelsX = linspace(subpixelXi - (patchSize/2),subpixelXi + (patchSize/2),(patchSize)*patchScale);
interpPixelsY = linspace(subpixelYi - (patchSize/2),subpixelYi + (patchSize/2),(patchSize)*patchScale);
[xGrid,yGrid] = meshgrid(interpPixelsX,interpPixelsY);
fundusWindow = interp2(fundus,xGrid,yGrid);
fundusSubWindow = fundusWindow(1+end/4:3*end/4,1+end/4:3*end/4);
fundusXCorr = ifft2(fft2(fundusSubWindow).*conj(fft2(fundusSubWindow))./((abs(fft2(fundusSubWindow)).^1)));
imagesc(log(abs(ifftshift(fundusXCorr))))


