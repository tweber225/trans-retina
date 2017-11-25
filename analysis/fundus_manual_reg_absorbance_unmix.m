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

%% Parameters
fixedSource = 2; % 850nm LED is sharpest
doManualRegistration = 1;
makeNewRegistrationControlPoints = 0;
doControlPointCorrelationTuning = 1;

% Transforms to consider
nonreflectivesimilarity = 1;
affine = 1;
projective = 1;
poly2 = 1;
poly3 = 1;
poly4 = 1;

% Input chromophores
chromList = {'HbO2', 'Hb', 'melanin'};
numChroms = numel(chromList);

% Select particular filter kernels absorbance images to use for
% registration and to unmix
kernelsToUseRegistration = [3,6,10]; numKernelsToUseRegistration = numel(kernelsToUseRegistration);
kernelsToUnmix = [1,2,3,4,6,8,10,14,18,24];

% Calculated parameters
numSources = numel(sourceList);
numTransTypes = sum([nonreflectivesimilarity;affine;projective;poly2;poly3;poly4]);


%% Registration
if doManualRegistration == 1
    % Load unregistered-absorbance frames
    for sourceIdx = 1:numSources
        tiffPathFileName = [dataPath filesep captureFileNameList{sourceIdx} filesep fileNameList{sourceIdx}];
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
                % Normalize frames to show in control point select tool
                normFixed = absStackArray{fixedSource}(:,:,kernelsToUseRegistration(kernelIdx));
                normFixed = normFixed/(0.5*max(normFixed(:)));
                normMoving = absStackArray{sourceIdx}(:,:,kernelsToUseRegistration(kernelIdx));
                normMoving = normMoving/(0.5*max(normMoving(:)));
                % Gather the new control points
                [selectedMovingPoints,selectedFixedPoints] = cpselect(normMoving,normFixed,'Wait',true);
                controlPointCellArray{kernelIdx,sourceIdx}.movingPoints = selectedMovingPoints;
                controlPointCellArray{kernelIdx,sourceIdx}.fixedPoints = selectedFixedPoints;
            end
        end
        
        % Save these points
        save([dataPath filesep 'control_points.mat'],'controlPointCellArray');
    else
        % Otherwise load control points generated and saved before
        % (variable=controlPointCellArray)
        load([dataPath filesep 'control_points.mat'],'controlPointCellArray')
    end
    
    % optional: cpcorr (to fine tune, or not to fine tune)
    if doControlPointCorrelationTuning == 1
        
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
                selectionMade = 0;
                while selectionMade == 0
                    for transIdx = 1:numTransTypes
                        movingFrame = absStackArray{sourceIdx}(:,:,kernelsToUseRegistration(kernelIdx));
                        fixedFrame = absStackArray{fixedSource}(:,:,kernelsToUseRegistration(kernelIdx));
                        % Warp the moving frame
                        regFrame = imwarp(movingFrame,imref2d(size(movingFrame)),tForm{transIdx},'OutputView',imref2d(size(fixedFrame)));
                        imshowpair(regFrame,fixedFrame);title(num2str(transIdx))
                        drawnow;pause(2);
                    end
                    prompt = 'Which transform was best? (1,2,3,etc) (0=repeat)';
                    bestTransType = input(prompt);

                    if bestTransType ~= 0, selectionMade = 1; end
                end %while loop--review
            end %conditional to skip registering the same fixed frame to itself
        end % Loop through registration kernels
    end %loop through sources-applying transforms
end %conditional to enable manual registration


%% Absorbance unmixing
% Current shortcomings of this approach: 1.) QE of camera is not considered
% (declines from about 525nm Si CCD (or after 700nm with e2v's EV76C661).
% 2.) Absorption along the way to back of the eye (& homogenous melanin
% layer at RPE) is not considered (overall will tend to boost longer
% wavelengths). It's possible these two will cancel each other's effects
% out, but to some extend there will be some error.

% Make spectra folder string name
nmToInterpOver = 600:1000;numNmToInterpOver = numel(nmToInterpOver);
analysisPathNameArray = regexp(cd,'\','split');
transRetinaPathName = strjoin(analysisPathNameArray(1:(end-1)),'\');
spectraPathName = [transRetinaPathName filesep 'spectra'];
% Load chromophores
chromMat = zeros(numNmToInterpOver,numChroms);
normFlag = 0; % Don't normalize the chromophores absorption
for chromIdx = 1:numChroms
    chromMat(:,chromIdx) = load_interpolate_spectrum([spectraPathName filesep 'chromophores'],chromList{chromIdx},nmToInterpOver,normFlag);
end

% Load source spectra
sourceMat = zeros(numNmToInterpOver,numSources);
normFlag = 1; % Do normalize source emissions
for sourceIdx = 1:numSources
    sourceMat(:,sourceIdx) = load_interpolate_spectrum([spectraPathName filesep 'sources'],sourceList{sourceIdx},nmToInterpOver,normFlag);
end

% Unmixing: Fit the absorbance data to model of mixed chromophores








