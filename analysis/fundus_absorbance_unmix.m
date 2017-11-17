% ANALYSIS/FUNDUS_ABSORBANCE_UNMIX
% Script to load several absorbance fundus images (or stacks--repeated calculations with different filter kernel widths), register them, transform
% them, then run spectral unmixing
%
% 
% Timothy D. Weber
% Biomicroscopy Lab, BU 2017

%% PARAMETERS
% For multiple filter kernels (absorbance stacks), specify particular
% kernels for use 
kernelsToUnmix = [8 10]; numKernelsToUnmix = numel(kernelsToUnmix);
matchThresh = 24.652778;
maxRatio = 0.246528;

% Input LED-source channels
sourceList = {'940nmLED', '850nmLED', '780nmLED', '730nmLED', '660nmLED'};
dataPath = 'C:\Users\tweber\Desktop\local data analysis\170905';
captureFileNameList = {'170905_subject001_capture006',...
    '170905_subject001_capture001', ...
    '170905_subject001_capture003', ...
    '170905_subject001_capture004', ...
    '170905_subject001_capture005'};
fileNameList = {'170905_subject001_capture006_660nm-absorb.tiff',...
    '170905_subject001_capture001_850nm-absorb.tiff', ...
    '170905_subject001_capture003_780nm-absorb.tiff', ...
    '170905_subject001_capture004_730nm-absorb.tiff', ...
    '170905_subject001_capture005_660nm-absorb.tiff'};
numSources = numel(sourceList);

% Input chromophores
chromList = {'HbO2', 'Hb', 'melanin'};
numChroms = numel(chromList);

%% Loop through and load each absorption stack
minFrameWidth = 10^6;
for sourceIdx = 1:numSources
    % Load image info to get stack's dimensions (pixels height, width, number
    % of frames)
    tiffPathName = [dataPath filesep captureFileNameList{sourceIdx}];
    tiffFileName = fileNameList{sourceIdx};
    tiffFileInfo = imfinfo([tiffPathName filesep tiffFileName]);
    numKernels = numel(tiffFileInfo);
    
    % Allocate space, datatype: doubles, make sure few GB RAM available
    absStack = zeros(tiffFileInfo(1).Height,tiffFileInfo(1).Width,numKernels);
    
    % Loop through loading frames
    disp(['Loading: ' tiffFileName]);
    for kernelIdx = 1:numKernels
        absStack(:,:,kernelIdx) = imread([tiffPathName filesep tiffFileName],kernelIdx,'Info',tiffFileInfo);
    end
    
    % Put into cell array of stacks-fast enough: don't really need to pre-allocate
    absStackArray{sourceIdx} = absStack;
    
    % Keep track of minimum frame width
    minFrameWidth = min(size(absStack,1),minFrameWidth);
end



%% Load source spectra
% analysisPathName = regexp(cd,filesep,'split');
% sourcePathName = [strjoin(analysisPathName{1:(end-1)}) filesep 'spectra' filesep 'sources'];
% 
% % Load all the spectra into a cell array of structures for each spectra
% % (wavelength, absorbance pair)
% for sourceIdx = 1:numSources
%     sourceSpectra{chromIdx} = load([sourcePathName sourceList{chromIdx} '.mat'],'waveLen','emission');
% end
% 
% % Down-sample/interpolate to 1nm sampling from 600 to 1000nm
% 
% 
% %% Load chromophore spectra
% chromophorePathName = [strjoin(analysisPathName{1:(end-1)}) filesep 'spectra' filesep 'chromophores'];
% 
% % Load all the spectra into a cell array of structures for each spectra
% % (wavelength, absorbance pair)
% for chromIdx = 1:numChroms
%     chromSpectra{chromIdx} = load([chromophorePathName chromList{chromIdx} '.mat'],'waveLen','absorbance');
% end
% 
% % Down-sample/interpolate to 1nm sampling from 600 to 1000nm


%% Register each absorption stack
% Best to use feature-based registration here because the contrast is
% different
x1 = round(round(minFrameWidth/2*(1-1/sqrt(2)))+1);
x2 = minFrameWidth-round(minFrameWidth/2*(1-1/sqrt(2)));
tformMat = zeros(3,3,numSources-1,numKernels);
for regIdx = 1:(numSources-1)
    for kernelIdx = 1:numKernels
        % Pull out the right cropped frames
        frame1 = absStackArray{regIdx}(x1:x2,x1:x2,kernelIdx);
        frame2 = absStackArray{regIdx+1}(x1:x2,x1:x2,kernelIdx);
        % Normalize frames
        minFrame1 = min(frame1(:));
        maxFrame1 = max(frame1(:));
        frame1 = (frame1-minFrame1)/(maxFrame1-minFrame1);
        minFrame2 = min(frame2(:));
        maxFrame2 = max(frame2(:));
        frame2 = (frame2-minFrame2)/(maxFrame2-minFrame2);
        % Set default spatial referencing objects
        fr1RefObj = imref2d(size(frame1));
        fr2RefObj = imref2d(size(frame2));
        % Detect SURF features (SURF=speeded up robust features)
        fr1Pts = detectSURFFeatures(frame1,'MetricThreshold',750.000000,'NumOctaves',3,'NumScaleLevels',5);
        fr2Pts = detectSURFFeatures(frame2,'MetricThreshold',750.000000,'NumOctaves',3,'NumScaleLevels',5);
        % Extract features
        [fr1Feats,fr1ValidPts] = extractFeatures(frame1,fr1Pts,'Upright',false);
        [fr2Feats,fr2ValidPts] = extractFeatures(frame2,fr2Pts,'Upright',false);
        % Match features
        indexPairs = matchFeatures(fr1Feats,fr2Feats,'MatchThreshold',matchThresh,'MaxRatio',maxRatio);
        fr1MatchedPts = fr1ValidPts(indexPairs(:,1));
        fr2MatchedPts = fr2ValidPts(indexPairs(:,2));
        % Estimate transformation
        tform = estimateGeometricTransform(fr2MatchedPts,fr1MatchedPts,'similarity');
        tformMat(:,:,regIdx,kernelIdx) = tform.T;
        % Apply transformation and show result
        regFrame2 = imwarp(frame2,fr2RefObj,tform,'OutputView',fr1RefObj,'SmoothEdges',true);
        imshowpair(frame1,regFrame2);drawnow;pause(.05);
    end
end

% Compute average transform matrix for each registration
blanktForm = affine2d;
tFormRelativeFirstSource = blanktForm.T; % Make a blank transform
for regIdx = 1:(numSources-1)
    meantForm(:,:,regIdx) = mean(squeeze(tformMat(:,:,regIdx,:)),3);
    tFormRelativeFirstSource(:,:,regIdx+1) = tFormRelativeFirstSource(:,:,regIdx)*meantForm(:,:,regIdx);
end

% Create a non-cropping larger spatial reference object
fullRefObj = imref2d(size(absStackArray{1}(:,:,kernelIdx)));

% Allocate space for a "full stack of registered sources", and a stack of
% "valid" registered sources, i.e. cropped to minimum size wher there's
% image data from each stack

% Apply transforms to generate both stacks


%% Unmix stacks based on input chromophore and source spectra






