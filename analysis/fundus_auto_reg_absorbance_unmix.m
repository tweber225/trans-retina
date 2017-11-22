% ANALYSIS/FUNDUS_AUTO_REG_ABSORBANCE_UNMIX
% Script to load several absorbance fundus images (or stacks--repeated
% calculations with different filter kernel widths), register them,
% transform them, then run spectral unmixing
%
% This is the automatic version (as of Nov 20, 2017, couldn't get this to
% work really well (i.e. no noticable error acrosst the entire frame for
% all colors, pretty stringent requirements). So a manual approach has been
% adopted instead
%
% Timothy D. Weber
% Biomicroscopy Lab, BU 2017

%% PARAMETERS
% For multiple filter kernels (absorbance stacks), specify particular
% kernels for use 
kernelsToUnmix = [1 2 4 6 8 12 16 20 24]; numKernelsToUnmix = numel(kernelsToUnmix);

% Parameters specifically for SURF feature detection and transform
% estimation, tried to maximize available number of features since the
% contrast can change fairly dramatically from wavelength to wavelength
MetricThreshold = 660;
NumOctaves = 3;
NumScaleLevels = 5;
matchThresh = 50;maxRatio = maxRatio*.01;

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
    
    % Loop through loading frames--crop to inscribed circle
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

% Current strategy: Register to the middle (wavelength range, usually
% 780nm) frame in each case
tFormMat = zeros(3,3,numSources,numKernels);
middleFrameSourceNumber = 2;
kernelStart = 2;
kernelEnd = 6;
for sourceIdx = 1:numSources
    for kernelIdx = kernelStart:kernelEnd
        % Pull out the right cropped frames
        %frame1 = absStackArray{2}(x1:x2,x1:x2,kernelIdx); %Static frame
        %frame2 = absStackArray{sourceIdx}(x1:x2,x1:x2,kernelIdx); % Moving frame
        frame1 = absStackArray{middleFrameSourceNumber}(:,:,kernelIdx); %Static frame
        frame2 = absStackArray{sourceIdx}(:,:,kernelIdx); % Moving frame
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
        fr1Pts = detectSURFFeatures(frame1,'MetricThreshold',MetricThreshold,'NumOctaves',NumOctaves,'NumScaleLevels',NumScaleLevels);
        fr2Pts = detectSURFFeatures(frame2,'MetricThreshold',MetricThreshold,'NumOctaves',NumOctaves,'NumScaleLevels',NumScaleLevels);
        % Extract features
        [fr1Feats,fr1ValidPts] = extractFeatures(frame1,fr1Pts,'Upright',false);
        [fr2Feats,fr2ValidPts] = extractFeatures(frame2,fr2Pts,'Upright',false);
        % Match features
        indexPairs = matchFeatures(fr1Feats,fr2Feats,'MatchThreshold',matchThresh,'MaxRatio',maxRatio);
        fr1MatchedPts = fr1ValidPts(indexPairs(:,1));
        fr2MatchedPts = fr2ValidPts(indexPairs(:,2));
        % Estimate transformation
        [tform,inlierPtsFrame2,inlierPtsFrame1] = estimateGeometricTransform(fr2MatchedPts,fr1MatchedPts,'projective','MaxNumTrials',1000000);
        tFormMat(:,:,sourceIdx,kernelIdx) = tform.T;
        % Apply transformation and show result
%         regFrame2 = imwarp(frame2,fr2RefObj,tform,'OutputView',fr1RefObj,'SmoothEdges',true);
%         imshowpair(frame1,regFrame2);drawnow;pause(0);

        showMatchedFeatures(frame1,frame2,inlierPtsFrame1,inlierPtsFrame2);drawnow;pause(3);
    end
end

%% Convert estimated transforms to x-shift, y-shift, rotation, magnification
%xShift = tFormMat(3,1,:,kernelStart:);

%% Compute average transform matrix for each registration
blankTForm = affine2d;
tFormRelativeFirstSource = blankTForm.T; % Make a blank transform
for sourceIdx = 1:(numSources-1)
    meanTForm(:,:,sourceIdx) = mean(squeeze(tFormMat(:,:,sourceIdx,:)),3);
    tFormRelativeFirstSource(:,:,sourceIdx+1) = tFormRelativeFirstSource(:,:,sourceIdx)*meanTForm(:,:,sourceIdx);
end

% Compute the maximum shifts
maxXPos = ceil(max(squeeze(tFormRelativeFirstSource(3,1,:))));
maxXNeg = -floor(min(squeeze(tFormRelativeFirstSource(3,1,:))));
maxYPos = ceil(max(squeeze(tFormRelativeFirstSource(3,2,:))));
maxYNeg = -floor(min(squeeze(tFormRelativeFirstSource(3,2,:))));

% Create a non-cropping larger spatial reference object
fullRefObj = imref2d(size(absStackArray{1}(:,:,kernelIdx)));
fullRefObj.XWorldLimits = fullRefObj.XWorldLimits + [-maxXNeg maxXPos];
fullRefObj.YWorldLimits = fullRefObj.YWorldLimits + [-maxYNeg maxYPos];
fullRefObj.ImageSize = fullRefObj.ImageSize + [(maxYPos+maxYNeg),(maxXPos+maxXNeg)];
regStackSize = [fullRefObj.ImageSize, numSources, numKernelsToUnmix];

% Allocate space for a stack of registered sources
regSourceStack = zeros(regStackSize);

% Apply transforms to generate stacks
for kernelIdx = kernelsToUnmix
    for sourceIdx = 1:numSources
        % Pull out the right transform
        currentTForm = affine2d;
        currentTForm.T = tFormRelativeFirstSource(:,:,sourceIdx);
        % Pull out the right frame
        currentFrame = absStackArray{sourceIdx}(:,:,kernelIdx);
        regSourceStack(:,:,sourceIdx,kernelIdx) = imwarp(currentFrame,imref2d(size(currentFrame)),currentTForm,'OutputView',fullRefObj,'SmoothEdges',true);
        imagesc(regSourceStack(:,:,sourceIdx,kernelIdx));drawnow;pause(1)
    end
    
    % Save each kernel's stack
    save_tiff_stack(single(squeeze(regSourceStack(:,:,:,kernelIdx))),[dataPath filesep 'absStackKernel' num2str(kernelIdx,'%02d') '.tiff'])
end




%% Unmix stacks based on input chromophore and source spectra






