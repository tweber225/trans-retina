%% Parameters and filenames
chromophorePath = 'C:\Users\tweber\Desktop\local data analysis\170905\2chroms660_730_780_850\lsq';
chromophoreFilename = 'chromophores_lsq_kernel16.tiff';

maskPath = 'C:\Users\tweber\Desktop\local data analysis\170905\masks';
artMaskFileName = 'a.tif';
veinMaskFileName = 'v.tif';

erosionFactor = 1;
smoothingFactor = 20;
alphaAntiAliasingFactor = 1;
skipArtOverlap = 1;
skipVeinOverlap = 1;
avoidOverlapFactor = 7;
diagnosticImagePlotting = 0;

%% Loading data, getting ready
disp('Loading Chromophore Data')
% Get chromophore (HbO2 and Hb) dataset to use
fullPathFilenameChromes = [chromophorePath filesep chromophoreFilename];
chromesFileInfo = imfinfo(fullPathFilenameChromes);
chromesStack = zeros(chromesFileInfo(1).Height,chromesFileInfo(1).Width,2);
chromesStack(:,:,1) = imread(fullPathFilenameChromes,1,'Info',chromesFileInfo);
chromesStack(:,:,2) = imread(fullPathFilenameChromes,2,'Info',chromesFileInfo);

disp('Loading Vessel Masks')
% Get vessel segment mask set to use (8bit binary images in a tif stack)
% The first frame is a max projection of individual vessel segment masks
% Subsequent frames are individual segment masks that are slightly tapered
% at terminal ends of the vessel track
fullPathFilenameArtMask = [maskPath filesep artMaskFileName];
fullPathFilenameVeinMask = [maskPath filesep veinMaskFileName];
maskArtFileInfo = imfinfo(fullPathFilenameArtMask);
maskVeinFileInfo = imfinfo(fullPathFilenameVeinMask); 
numArtVesselSegments = numel(maskArtFileInfo)-1;
numVeinVesselSegments = numel(maskVeinFileInfo)-1;
artVesselSegmentsStack = zeros(maskArtFileInfo(1).Height,maskArtFileInfo(1).Width,numArtVesselSegments);
veinVesselSegmentsStack = zeros(maskArtFileInfo(1).Height,maskArtFileInfo(1).Width,numVeinVesselSegments);
artHbO2SegmentsStack = artVesselSegmentsStack;
veinHbO2SegmentsStack = veinVesselSegmentsStack;
artHbSegmentsStack = artVesselSegmentsStack;
veinHbSegmentsStack = veinVesselSegmentsStack;
artMaskStack = artVesselSegmentsStack;
veinMaskStack = veinVesselSegmentsStack;

for artSegmentIdx = 1:(numArtVesselSegments+1)
    artVesselSegmentsStack(:,:,artSegmentIdx) = imread(fullPathFilenameArtMask,artSegmentIdx,'Info',maskArtFileInfo)/255;
end

for veinSegmentIdx = 1:(numVeinVesselSegments+1)
    veinVesselSegmentsStack(:,:,veinSegmentIdx) = imread(fullPathFilenameVeinMask,veinSegmentIdx,'Info',maskVeinFileInfo)/255;
end

% Compute estimated background for vessel mask area in HbO2 channel with
% "regionfill" command (solution to Laplacian with Dirichlet boundary
% conditions. Compute background for Hb in the same way
artHbO2BG = regionfill(chromesStack(:,:,1),artVesselSegmentsStack(:,:,1));
veinHbO2BG = regionfill(chromesStack(:,:,1),veinVesselSegmentsStack(:,:,1));
artHbBG = regionfill(chromesStack(:,:,2),artVesselSegmentsStack(:,:,1));
veinHbBG = regionfill(chromesStack(:,:,2),veinVesselSegmentsStack(:,:,1));


%% Looping through vessel segments
% Loop through each vessel segment, for each loop ...
for artSegmentIdx = 1:numArtVesselSegments
    % Subtract chromophores from their background estimates
    artHbO2BGCorrected = (chromesStack(:,:,1) - artHbO2BG).*artVesselSegmentsStack(:,:,artSegmentIdx+1);
    artHbBGCorrected = (chromesStack(:,:,2) - artHbBG).*artVesselSegmentsStack(:,:,artSegmentIdx+1);

    % Erode the vessel mask a few pixels (the edges tend to not be
    % trustworthy), and multiply into the background-corrected chromophore
    % vessel map--effectivley cropping the vessel slightly (the center of
    % the vessel will give the most accurate saturation measurement).
    artMaskEroded = imerode(artVesselSegmentsStack(:,:,artSegmentIdx+1),true(erosionFactor*2+1));
    artMaskErodedFinalCutout = artMaskEroded;
    if artSegmentIdx>1, artMaskEroded = artMaskEroded.*(1-max(artVesselSegmentsStack(:,:,2:(artSegmentIdx)),[],3)); end
    if skipArtOverlap == 1
        artMaskEroded = artMaskEroded.*(1-imdilate(veinVesselSegmentsStack(:,:,1),true(avoidOverlapFactor)));
    end
    artHbO2BGCorrectedEroded = artHbO2BGCorrected.*artMaskEroded;
    artHbBGCorrectedEroded = artHbBGCorrected.*artMaskEroded;
    
    % Gaussian smooth out background-corrected vessel chromophore
    artHbO2Smooth = imgaussfilt(artHbO2BGCorrectedEroded,smoothingFactor);
    artHbSmooth = imgaussfilt(artHbBGCorrectedEroded,smoothingFactor);

    % Divide the gaussian-smoothed image by another guassian smoothed image
    % of the eroding binary mask (this effectively implements "nanconv"--a
    % convolution that ignores NaN's, except here NaN's are 0's, so the
    % pixels under the vessel are properly normalized). Finally, multiply
    % the normalized, blurred, background-correct vessel chromophore map by
    % the eroding mask. This vessel segment is done.
    artMaskSmooth = imgaussfilt(artMaskEroded,smoothingFactor);
    artHbO2SegmentsStack(:,:,artSegmentIdx) = (artHbO2Smooth./(artMaskSmooth+eps)).*artMaskErodedFinalCutout;
    artHbSegmentsStack(:,:,artSegmentIdx) = (artHbSmooth./(artMaskSmooth+eps)).*artMaskErodedFinalCutout;
    artMaskStack(:,:,artSegmentIdx) = artMaskErodedFinalCutout; % Store the mask, too since we will use it later
    
    if diagnosticImagePlotting == 1
        imagesc(artHbO2SegmentsStack(:,:,artSegmentIdx),[-5 25]);colormap jet;colorbar;drawnow;pause(1)
    end

end

for veinSegmentIdx = 1:numVeinVesselSegments
    % Subtract chromophores from their background estimates
    veinHbO2BGCorrected = (chromesStack(:,:,1) - veinHbO2BG).*veinVesselSegmentsStack(:,:,veinSegmentIdx+1);
    veinHbBGCorrected = (chromesStack(:,:,2) - veinHbBG).*veinVesselSegmentsStack(:,:,veinSegmentIdx+1);

    % Erode the vessel mask a few pixels (the edges tend to not be
    % trustworthy), and multiply into the background-corrected chromophore
    % vessel map--effectivley cropping the vessel slightly (the center of
    % the vessel will give the most accurate saturation measurement).
    veinMaskEroded = imerode(veinVesselSegmentsStack(:,:,veinSegmentIdx+1),true(erosionFactor*2+1));
    veinMaskErodedFinalCutout = veinMaskEroded;
    if veinSegmentIdx>1, veinMaskEroded = veinMaskEroded.*(1-max(veinVesselSegmentsStack(:,:,2:(veinSegmentIdx)),[],3)); end
    if skipVeinOverlap == 1
        veinMaskEroded = veinMaskEroded.*(1-imdilate(artVesselSegmentsStack(:,:,1),true(avoidOverlapFactor)));
    end
    veinHbO2BGCorrectedEroded = veinHbO2BGCorrected.*veinMaskEroded;
    veinHbBGCorrectedEroded = veinHbBGCorrected.*veinMaskEroded;
    
    % Gaussian smooth out background-corrected vessel chromophore
    veinHbO2Smooth = imgaussfilt(veinHbO2BGCorrectedEroded,smoothingFactor);
    veinHbSmooth = imgaussfilt(veinHbBGCorrectedEroded,smoothingFactor);

    % Divide the gaussian-smoothed image by another guassian smoothed image
    % of the eroding binary mask (this effectively implements "nanconv"--a
    % convolution that ignores NaN's, except here NaN's are 0's, so the
    % pixels under the vessel are properly normalized). Finally, multiply
    % the normalized, blurred, background-correct vessel chromophore map by
    % the eroding mask. This vessel segment is done.
    veinMaskSmooth = imgaussfilt(veinMaskEroded,smoothingFactor);
    veinHbO2SegmentsStack(:,:,veinSegmentIdx) = (veinHbO2Smooth./(veinMaskSmooth+eps)).*veinMaskErodedFinalCutout;
    veinHbSegmentsStack(:,:,veinSegmentIdx) = (veinHbSmooth./(veinMaskSmooth+eps)).*veinMaskErodedFinalCutout;
    veinMaskStack(:,:,veinSegmentIdx) = veinMaskErodedFinalCutout; % Store the mask, too since we will use it later
    
    if diagnosticImagePlotting == 1
        imagesc(veinHbO2SegmentsStack(:,:,veinSegmentIdx),[-5 15]);colormap jet;colorbar;drawnow;pause(1)
    end

end

%% Making composite (multi-segment) views
% Connect the vessels maps by max-projecting along 3rd dimension of stacks
maxArtHbO2 = max(artHbO2SegmentsStack,[],3);
maxVeinHbO2 = max(veinHbO2SegmentsStack,[],3);
maxArtHb = max(artHbSegmentsStack,[],3);
maxVeinHb = max(veinHbSegmentsStack,[],3);
maxArtMask = max(artMaskStack,[],3);
maxVeinMask = max(veinMaskStack,[],3);

% From chromophore max projections compute O2 saturation (adding an epsilon
% to the denominator ensures out-of-vessel regions take the value of zero)
SaO2Map = maxArtHbO2./(maxArtHbO2+maxArtHb+eps);
SvO2Map = maxVeinHbO2./(maxVeinHbO2+maxVeinHb+eps);

% Concatenate all these maps and save as floating point tif stack
outputArtStack = single(cat(3,SaO2Map,maxArtHbO2,maxArtHb,maxArtMask));
outputVeinStack = single(cat(3,SvO2Map,maxVeinHbO2,maxVeinHb,maxVeinMask));
SaO2Filename = [chromophoreFilename(1:(end-5)) '_SaO2.tiff'];
SvO2Filename = [chromophoreFilename(1:(end-5)) '_SvO2.tiff'];
save_tiff_stack(outputArtStack,[chromophorePath filesep SaO2Filename]);
save_tiff_stack(outputVeinStack,[chromophorePath filesep SvO2Filename]);

%% Make color-coded O2 saturation overlay
% Use the the max projection mask as the alpha channel--but first round off
% the sharp pixel edges with a Gaussian blur (some form of this is called
% anti-aliasing)
blurredArtMask = imgaussfilt(maxArtMask,alphaAntiAliasingFactor);
blurredVeinMask = imgaussfilt(maxVeinMask,alphaAntiAliasingFactor);

% Take the saturation map and blur it the same ammount, then divide out the
% blurred mask to normalize
blurredNormedSaO2Map = imgaussfilt(SaO2Map,alphaAntiAliasingFactor)./blurredArtMask;
blurredNormedSvO2Map = imgaussfilt(SvO2Map,alphaAntiAliasingFactor)./blurredVeinMask;

% Convert O2 saturation fraction values to the "jet" RGB colormap
jetCMap = uint8(colormap(jet(256))*255);
SaO2Map8Bit = uint8(blurredNormedSaO2Map.*255);
SvO2Map8Bit = uint8(blurredNormedSvO2Map.*255);
SaO2MapRGB = cat(3,intlut(SaO2Map8Bit,jetCMap(:,1)),intlut(SaO2Map8Bit,jetCMap(:,2)),intlut(SaO2Map8Bit,jetCMap(:,3)));
SvO2MapRGB = cat(3,intlut(SvO2Map8Bit,jetCMap(:,1)),intlut(SvO2Map8Bit,jetCMap(:,2)),intlut(SvO2Map8Bit,jetCMap(:,3)));

% Export RGB image data and alpha channel in PNG format (handles
% transparency well)
SaO2OverlayFilename = [chromophoreFilename(1:(end-5)) '_SaO2.png'];
SvO2OverlayFilename = [chromophoreFilename(1:(end-5)) '_SvO2.png'];
imwrite(SaO2MapRGB,[chromophorePath filesep SaO2OverlayFilename],'png','Alpha',uint8(blurredArtMask*255));
imwrite(SvO2MapRGB,[chromophorePath filesep SvO2OverlayFilename],'png','Alpha',uint8(blurredVeinMask*255));







