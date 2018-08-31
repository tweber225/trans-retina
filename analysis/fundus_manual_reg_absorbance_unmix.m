% ANALYSIS/FUNDUS_MANUAL_REG_ABSORBANCE_UNMIX
% Script to load several absorbance fundus images (or stacks--repeated
% calculations with different filter kernel widths), register them,
% transform them, then run spectral unmixing
%
% This is the manual version of registation using user-selected control
% points
%
% Timothy D. Weber
% Biomicroscopy Lab, BU 2017
%

%% Filenames
sourceList = {'850nmLEDmax', '780nmLEDmax', '730nmLEDmax', '660nmLEDmax', '940nmLEDmax'}; % Note: inclusion in spectral unmixing is determined below 
chromList = {'HbO2', 'Hb' , 'melanin'}; % don't change (select or deselect below)
dataPath = 'C:\Users\tweber\Desktop\local data analysis\170905';
captureFileNameList = {'170905_subject001_capture001',...
    '170905_subject001_capture003', ...
    '170905_subject001_capture004', ...
    '170905_subject001_capture005', ...
    '170905_subject001_capture006'};
fileNameList = {'absorb_crop', ...
    'absorb_crop', ...
    'absorb_crop', ...
    'absorb_crop', ...
    'absorb_crop'};
controlPointsFile = 'control_points-final.mat';

%% Parameters
fixedSource = 1; % 850nm LED is sharpest (Nth capture in "captureFileNameList")
doManualRegistration = 1;
makeNewRegistrationControlPoints = 0;
fractionMaxToShowWhite = 0.5; % to show as white on the manaul control point registrations (tune as needed)
doControlPointCorrelationTuning = 1;
compareTransforms = 0;
downSampleFactor = 1;
adjustSourceSpectraForHead = 0;
adjustSourceSpectraForQE = 0;

% Transforms to consider
nonreflectivesimilarity = 1;
affine = 1;
projective = 0;
poly2 = 1;
poly3 = 1;
poly4 = 1;

% Select particular filter kernels absorbance images to use for
% registration and to unmix
kernelsToUseRegistration = [5]; numKernelsToUseRegistration = numel(kernelsToUseRegistration);
kernelsToUnmix = 1:26; numKernelsToUnmix = numel(kernelsToUnmix);

% Calculated parameters
numSources = numel(sourceList);
numChroms = numel(chromList);
numTransTypes = sum([nonreflectivesimilarity;affine;projective;poly2;poly3;poly4]);


%% Registration
if doManualRegistration == 1
    % Load unregistered-absorbance frames
    for sourceIdx = 1:numSources
        tiffPathFileName = [dataPath filesep captureFileNameList{sourceIdx} filesep fileNameList{sourceIdx} '.tiff'];
        tiffFileInfo = imfinfo(tiffPathFileName); numKernels = numel(tiffFileInfo);
        absStack = zeros(tiffFileInfo(1).Height,tiffFileInfo(1).Width,numKernels);
        disp(['Loading: ' tiffPathFileName]);
        for kernelIdx = 1:numKernels
            absStack(:,:,kernelIdx) = imread(tiffPathFileName,kernelIdx,'Info',tiffFileInfo);
        end
        absStackArray{sourceIdx} = absStack;
    end
    
    % Also if enabled, do manual control point selection
    if makeNewRegistrationControlPoints == 1
        % Loop through each kernel to use for registration
        for kernelIdx = 1:numKernelsToUseRegistration
            % Loop through this registering to fixed frame
            for sourceIdx = 1:numSources
                % Normalize image frames to show in control point select tool
                normFixed = absStackArray{fixedSource}(:,:,kernelsToUseRegistration(kernelIdx));
                normFixed = normFixed/(fractionMaxToShowWhite*max(normFixed(:)));
                normMoving = absStackArray{sourceIdx}(:,:,kernelsToUseRegistration(kernelIdx));
                normMoving = normMoving/(fractionMaxToShowWhite*max(normMoving(:)));
                % Gather the new control points
                disp(['Beginning manual control point selection for source #' num2str(fixedSource) ' vs #' num2str(sourceIdx)]);
                [selectedMovingPoints,selectedFixedPoints] = cpselect(normMoving,normFixed,'Wait',true);
                controlPointCellArray{kernelIdx,sourceIdx}.movingPoints = selectedMovingPoints;
                controlPointCellArray{kernelIdx,sourceIdx}.fixedPoints = selectedFixedPoints;
            end
        end
        
        % Save these points
        save([dataPath filesep controlPointsFile],'controlPointCellArray');
    else
        % Otherwise load control points generated and saved before
        % (variable=controlPointCellArray)
        load([dataPath filesep controlPointsFile],'controlPointCellArray')
    end
    
    % optional: cpcorr (to fine tune, or not to fine tune)
    if doControlPointCorrelationTuning == 1
    % Loop through each kernel to use for registration
        for kernelIdx = 1:numKernelsToUseRegistration
            % Loop through this registering to fixed frame
            for sourceIdx = 1:numSources
                if sourceIdx == fixedSource
                    % Skip this if we're comparing the fixed source to
                    % itself
                else
                    % gather correct moving and fixed points
                    movingPoints = controlPointCellArray{kernelIdx,sourceIdx}.movingPoints;
                    fixedPoints = controlPointCellArray{kernelIdx,sourceIdx}.fixedPoints;
                    
                    % gather moving and fixed frames
                    movingImg = absStackArray{sourceIdx}(:,:,kernelsToUseRegistration(kernelIdx));
                    fixedImg = absStackArray{fixedSource}(:,:,kernelsToUseRegistration(kernelIdx));
                    
                    % xcorr the control points to fine tune
                    movingPointsAdjusted = cpcorr(movingPoints,fixedPoints,movingImg,fixedImg);
                    
%                     % plot original points on moving frame
%                     figure; imshow(movingImg)
%                     hold on
%                     plot(movingPoints(:,1),movingPoints(:,2),'xw') 
%                     title('moving')
%                     
%                     % plot adjusted
%                     plot(movingPointsAdjusted(:,1),movingPointsAdjusted(:,2),'xy')
%                     pause(2)
                end
            
            end
        end
    end
    
    
    for sourceIdx = 1:numSources
        for kernelIdx = 1:numKernelsToUseRegistration
            if sourceIdx == fixedSource
                % Skip fixed frame, return a static transform
                sourceTForm = affine2d;
            else
                movingPoints = controlPointCellArray{kernelIdx,sourceIdx}.movingPoints;
                fixedPoints = controlPointCellArray{kernelIdx,sourceIdx}.fixedPoints;
                % various estimations of the geometric transform
                transType = 1;
                if nonreflectivesimilarity == 1
                    tForm{transType} = fitgeotrans(movingPoints,fixedPoints,'nonreflectivesimilarity');
                    transType = transType+1;
                end
                if affine == 1
                    tForm{transType} = fitgeotrans(movingPoints,fixedPoints,'affine');
                    transType = transType+1;
                end
                if projective == 1
                    tForm{transType} = fitgeotrans(movingPoints,fixedPoints,'projective');
                    transType = transType+1;
                end
                if poly2 == 1
                    tForm{transType} = fitgeotrans(movingPoints,fixedPoints,'polynomial',2);
                    transType = transType+1;
                end
                if poly3 == 1
                    tForm{transType} = fitgeotrans(movingPoints,fixedPoints,'polynomial',3);
                    transType = transType+1;
                end
                if poly4 == 1
                    tForm{transType} = fitgeotrans(movingPoints,fixedPoints,'polynomial',4);
                    transType = transType+1;
                end
                % review options and select the best fit for each channel
                % and each kernel
                if exist('bestTransMat') && (sum(bestTransMat) ~= 0)
                else
                    bestTransMat = zeros(numSources,numKernelsToUseRegistration);
                end
                selectionMade = 0;
                while ((selectionMade == 0) && (compareTransforms == 1))
                    for transIdx = 1:numTransTypes
                        movingFrame = absStackArray{sourceIdx}(:,:,kernelsToUseRegistration(kernelIdx));
                        fixedFrame = absStackArray{fixedSource}(:,:,kernelsToUseRegistration(kernelIdx));
                        % Warp the moving frame
                        regFrame = imwarp(movingFrame,imref2d(size(movingFrame)),tForm{transIdx},'OutputView',imref2d(size(fixedFrame)));
                        imshowpair(regFrame,fixedFrame);title(num2str(transIdx))
                        drawnow;
                        SSIVal = ssim(regFrame,fixedFrame);
                        disp(['Structural Similarity Index: ' num2str(SSIVal)])
                        pause(.5);
                    end
                    
                    prompt = 'Which transform was best? (1,2,3,etc) (0=repeat) ';
                    bestTransType = input(prompt);
                    bestTransMat(sourceIdx,kernelIdx) = bestTransType;
                    
                    if bestTransType ~= 0, selectionMade = 1; end
                end %while loop--review
            end %conditional to skip registering the same fixed frame to itself
        end % Loop through registration kernels
    end %loop through sources-applying transforms
    
    % Review selections made, make final decision on each source channel
    disp('Review your choices (Columns: kernels, Rows: sources)');
    disp(bestTransMat);
       
    % Ask which transformation to use, then do it
    fixedFrame = absStackArray{fixedSource}(:,:,1);
    fixedFrameSize = size(fixedFrame);
    fixedFrameRef = imref2d(fixedFrameSize);
    regAbsorbStack = zeros([fixedFrameSize numSources numKernelsToUnmix]);
    for sourceIdx = 1:numSources
        if sourceIdx == fixedSource
            % Don't need to transform
            outTForm = affine2d;
        else
            % Ask which transform to use
            choiceTransform = input(['Transform to use for source ' num2str(sourceIdx) '? ']);
            % Determine what tranform that was
            choiceClass = class(tForm{choiceTransform});
            
            % Gather all the control points to use
            allMovingPoints = []; allFixedPoints = [];
            %for kernelIdx = 1:numKernelsToUseRegistration
            for kernelIdx = 1 % hacking this line to just use, the first set of control points, which was fine (using them all together leads to some problems)
                allMovingPoints = [allMovingPoints; controlPointCellArray{kernelIdx,sourceIdx}.movingPoints];
                allFixedPoints = [allFixedPoints; controlPointCellArray{kernelIdx,sourceIdx}.fixedPoints];
            end
            
            % Compute average transform across all kernels for this source
            switch choiceClass
                case 'affine2d'
                    if isSimilarity(tForm{choiceTransform})
                        outTForm = fitgeotrans(allMovingPoints,allFixedPoints,'nonreflectivesimilarity');
                    else
                        outTForm = fitgeotrans(allMovingPoints,allFixedPoints,'affine');
                    end
                case 'projective2d'
                    outTForm = fitgeotrans(allMovingPoints,allFixedPoints,'projective');
                case 'images.geotrans.PolynomialTransformation2D'
                    polyDeg = tForm{choiceTransform}.Degree;
                    outTForm = fitgeotrans(allMovingPoints,allFixedPoints,'polynomial',polyDeg);
            end           
        end

        % Final transforms
                for kernelIdx = 1:numKernelsToUnmix
            sourceFrame = absStackArray{sourceIdx}(:,:,kernelsToUnmix(kernelIdx));
            regAbsorbStack(:,:,sourceIdx,kernelIdx) = imwarp(sourceFrame,imref2d(size(sourceFrame)),outTForm,'OutputView',fixedFrameRef);
        end
        
    end
    
    % Save each stack of multiple sources
    for kernelIdx = 1:numKernelsToUnmix
        chromFileName = ['multiabsorb_kernel' num2str(kernelsToUnmix(kernelIdx),'%02d') '.tiff'];
        save_tiff_stack(single(regAbsorbStack(:,:,:,kernelIdx)),[dataPath filesep chromFileName]);
    end
    
end %conditional to enable manual registration


%% Absorbance unmixing

% Which sources/chromophores to consider
%sourceList = {'850nmLEDmax', '780nmLEDmax', '730nmLEDmax', '660nmLEDmax', '940nmLEDmax'};
sourcesToInclude = [1, 1, 1, 1, 0];
%chromList = {'HbO2','Hb','melanin'}; 
chromsToInclude = [1, 1, 0];

numChromsUnmix = sum(chromsToInclude);
ascendingNumbers = 1:numChroms;
chromNumberIndices = ascendingNumbers(logical(chromsToInclude));
numSourcesUnmix = sum(sourcesToInclude);
ascendingNumbers = 1:numSources;
sourceNumberIndices = ascendingNumbers(logical(sourcesToInclude));

disp('Loading spectra ...')
% Make spectra folder string name
nmToInterpOver = 600:1000;numNmToInterpOver = numel(nmToInterpOver);
analysisPathNameArray = regexp(cd,'\','split');
transRetinaPathName = strjoin(analysisPathNameArray(1:(end-1)),'\');
spectraPathName = [transRetinaPathName filesep 'spectra'];
% Load chromophores
chromMat = zeros(numNmToInterpOver,numChromsUnmix);
normFlag = 0; % Don't normalize the chromophores absorption
for chromIdx = 1:numChromsUnmix
    chromMat(:,chromIdx) = load_interpolate_spectrum([spectraPathName filesep 'chromophores'],chromList{chromNumberIndices(chromIdx)},nmToInterpOver,normFlag);
    disp(chromList{chromNumberIndices(chromIdx)})
end

% Load source spectra
sourceMat = zeros(numNmToInterpOver,numSourcesUnmix);
normFlag = 1; % Do normalize source emissions
for sourceIdx = 1:numSourcesUnmix
    sourceMat(:,sourceIdx) = load_interpolate_spectrum([spectraPathName filesep 'sources'],sourceList{sourceNumberIndices(sourceIdx)},nmToInterpOver,normFlag);
    disp(sourceList{sourceNumberIndices(sourceIdx)})
end

% If enabled, adjust the source spectra to account for transmission through
% skin, head, and possibly RPE
if adjustSourceSpectraForHead == 1
    % Search for and load that spectrum
    normFlag = 0;
    headTrans = load_interpolate_spectrum([spectraPathName filesep 'head transmission'],'measured',nmToInterpOver,normFlag);
        
    % Multiply all the source spectra by head transmission
    incidentSourceMat = sourceMat;
    sourceMat = sourceMat.*repmat(headTrans,[1 numSourcesUnmix]);
    
    % Renormalize
    sourceMat = sourceMat./repmat(sum(sourceMat),[numNmToInterpOver 1]);
end

% If enabled, adjust the source spectra to account for camera's QE
if adjustSourceSpectraForQE == 1
    % Name the camera
    cameraQESpectrumName = 'pixelflyusb';
    % Search for and load that spectrum
    normFlag = 0;
    cameraQE = load_interpolate_spectrum([spectraPathName filesep 'cameras'],cameraQESpectrumName,nmToInterpOver,normFlag);
    
    % Multiply all the source spectra by QE of camera
    flatQESourceMat = sourceMat;
    sourceMat = sourceMat.*repmat(cameraQE,[1 numSourcesUnmix]);
    
    % Renormalize
    sourceMat = sourceMat./repmat(sum(sourceMat),[numNmToInterpOver 1]);
end

% Optional downsampling of the register absorbance stack before unmixing
% (helps computation and relieves some pressure on registering frames
% perfectly)
if downSampleFactor >1
    regAbsorbStack = imresize(regAbsorbStack,1/downSampleFactor);
end


regStackHeight = size(regAbsorbStack,1);
regStackWidth = size(regAbsorbStack,2);
numPixelsPerFrame = regStackHeight*regStackWidth;

% Make the model matrix
modelMat = sourceMat'*chromMat; % Make the linear model for each chromophore
modelMat = modelMat./(10^6); % scale down a bit so our chromophore concentrations are not really small
disp(['Condition number for model: ' num2str(cond(modelMat))]);


%% Loop through desired kernels to unmix
for kernelIdx = 1:numKernelsToUnmix
    disp(['Unmixing kernel ' num2str(kernelIdx) ' of ' num2str(numKernelsToUnmix)]);
    % reshape so we can simply loop through a pixel index
    absorbVector = reshape(regAbsorbStack(:,:,sourceNumberIndices,kernelIdx),[numPixelsPerFrame numSourcesUnmix])'; 
       
    % set any negative values to 0 before beginning non-negative least
    % squares
    absorbVector(absorbVector<0) = 0;
    
    % Solve the least squares problem since it take virtually no time
    chromVectorLSq = modelMat\absorbVector;
    
    % Do a non-negative least squares fit of the absorbance data
    chromVector = zeros(numChromsUnmix,numPixelsPerFrame);
    percentsVector = 10:10:100;
    percentsPixels = numPixelsPerFrame*percentsVector/100;
%     for pixelIdx = 1:numPixelsPerFrame
%         chromVector(:,pixelIdx) = lsqnonneg(modelMat,absorbVector(:,pixelIdx));
%         if sum(pixelIdx == percentsPixels) == 1
%             disp([num2str(percentsVector(pixelIdx == percentsPixels)) '%'])
%         end
%     end
    
    % Reshape back
    chromStackLSq = reshape(chromVectorLSq',[regStackHeight regStackWidth numChromsUnmix]);
    chromStackNNLSq = reshape(chromVector',[regStackHeight regStackWidth numChromsUnmix]);

    % Save this chromophore stacks and kernel choice
    chromLSqFileName = ['chromophores_lsq_kernel' num2str(kernelsToUnmix(kernelIdx),'%02d') '.tiff'];
    chromNNLSqFileName = ['chromophores_nnlsq_kernel' num2str(kernelsToUnmix(kernelIdx),'%02d') '.tiff'];
    save_tiff_stack(single(chromStackLSq),[dataPath filesep chromLSqFileName]);
    save_tiff_stack(single(chromStackNNLSq),[dataPath filesep chromNNLSqFileName]);
end



