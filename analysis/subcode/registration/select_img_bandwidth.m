function BWMask = select_img_bandwidth(FTStack,regOpt)



numFrames = size(FTStack,3);
numPix = size(FTStack,1);
% Display angle of cross power spectrum-reference first frame


% Prompt user to select radius of "useful" bandwidth (ie circle bounding
% frequencies that seem to be coherent with the shift
if regOpt.regBWRadius < 1
    frameRef = 1;
    for frameIdx = 1:numFrames
        xPowerSpec = FTStack(:,:,frameRef).*conj(FTStack(:,:,frameIdx));
        imagesc(angle(fftshift(xPowerSpec)));
        drawnow;pause(.03)
    end
    rSqr = input('Radius of BW:')^2;
else
    rSqr = regOpt.regBWRadius^2;
end


% Force to be circular
[x,y] = meshgrid(-numPix/2:(numPix/2-1),-numPix/2:(numPix/2-1));
BWMask = (x.^2 + y.^2) < rSqr;