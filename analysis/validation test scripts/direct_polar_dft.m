function polarDFT = direct_polar_dft(inputImage,rhoMin,rhoMax,numAngles)

inputImageDouble = double(inputImage);

rhoList = rhoMin:rhoMax;
thetaList = -1/4*pi + pi*(0:(numAngles-1))/numAngles;

[rhoGrid,thetaGrid] = meshgrid(rhoList,thetaList);

[fx,fy] = pol2cart(thetaGrid,rhoGrid);

xPoints = 0:(size(inputImage,2)-1);
yPoints = 0:(size(inputImage,1)-1);
[xGrid,yGrid] = meshgrid(xPoints,yPoints);


polarDFT = zeros(length(rhoList),length(thetaList));
for rhoIdx = 1:length(rhoList)
    for thetaIdx = 1:length(thetaList)
        expImg = exp(-1i*(2*pi)*(fx(thetaIdx,rhoIdx)*xGrid + fy(thetaIdx,rhoIdx)*yGrid)/size(inputImage,1));
        
        polarDFT(rhoIdx,thetaIdx) = sum(sum(expImg.*inputImageDouble));
        
    end
   
end