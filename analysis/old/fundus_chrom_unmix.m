% ANALYSIS/FUNDUS_CHROM_UNMIX
% Script to load registered absorbance fundus images and run spectral
% unmixing
%
% Timothy D. Weber
% Biomicroscopy Lab, BU 2017
%

%% Filenames
sourceList = {'940nmLEDmax', '850nmLEDmax', '780nmLEDmax', '730nmLEDmax', '660nmLEDmax'}; % Note: inclusion in spectral unmixing is determined below 
sourcesToInclude = [1,          1,             1,           1,             1];
chromList = {'HbO2', 'Hb', 'melanin', 'fat'};
chromsToInclude = [1, 1,    1,         0];
dataPath = 'C:\Users\tweber\Desktop\local data analysis\170905';
fileNameList = {'multiabsorb_kernel04.tiff',...
    'multiabsorb_kernel06.tiff', ...
    'multiabsorb_kernel14.tiff'};
fileNameList = {'multiabsorb_kernel14.tiff'};
%% Parameters
% Manual parameters
adjustSourceSpectraForHead = 1;
adjustSourceSpectraForQE = 1;
nmToInterpOver = 600:1000;

% Calculated parameters
numSources = numel(sourceList);
numChroms = numel(chromList);
numSourcesUnmix = sum(sourcesToInclude);
numChromsUnmix = sum(chromsToInclude);
numAbsImgToUnmix = numel(fileNameList);
numNmToInterpOver = numel(nmToInterpOver);

%% Absorbance unmixing
ascendingNumbers = 1:numChroms;
chromNumberIndices = ascendingNumbers(logical(chromsToInclude));
ascendingNumbers = 1:numSources;
sourceNumberIndices = ascendingNumbers(logical(sourcesToInclude));

disp('Loading spectra ...')
% Locate spectra folder string name
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

% Edit melanin's spectra slightly !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%chromMat(:,3) = 500*(nmToInterpOver'/500).^powToUseInThisCase;
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

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
        
    % Multiply all the source spectra by QE of camera
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

% Make the model matrix
modelMat = sourceMat'*chromMat; % Make the linear model for each chromophore
modelMat = modelMat./(10^6); % scale down a bit so our chromophore concentrations are not really small
disp(['Condition number for model: ' num2str(cond(modelMat))]);


%% Loop through desired absorbance images to unmix
for absImgIdx = 1:numAbsImgToUnmix
    fileName = fileNameList{absImgIdx};
    disp(['Loading ' fileNameList{absImgIdx}]);
    % Load the absorbance image
    tiffFileInfo = imfinfo([dataPath filesep fileNameList{absImgIdx}]);
    numFrames = numel(tiffFileInfo);
    regStackHeight = tiffFileInfo(1).Height;regStackWidth = tiffFileInfo(1).Width;numPixelsPerFrame = regStackHeight*regStackWidth;
    regAbsorbStack = zeros(regStackHeight,regStackWidth,numFrames);
    for frameIdx = 1:numFrames
        regAbsorbStack(:,:,frameIdx) = imread([dataPath filesep fileNameList{absImgIdx}],frameIdx,'Info',tiffFileInfo);
    end
    
    % reshape so we can simply loop through a pixel index
    absorbVector = reshape(regAbsorbStack(:,:,sourceNumberIndices),[numPixelsPerFrame numSourcesUnmix])'; 
    
    disp('Starting unmixing ...')
    % Do a non-negative least squares fit of the absorbance data
    chromVector = zeros(numChromsUnmix,numPixelsPerFrame);
    percentsVector = 10:10:100;
    percentsPixels = numPixelsPerFrame*percentsVector/100;
    for pixelIdx = 1:numPixelsPerFrame
        chromVector(:,pixelIdx) = lsqnonneg(modelMat,absorbVector(:,pixelIdx));
        if sum(pixelIdx == percentsPixels) == 1
            disp([num2str(percentsVector(pixelIdx == percentsPixels)) '%'])
        end
    end
    
    % Reshape back
    chromStack = reshape(chromVector',[regStackHeight regStackWidth numChromsUnmix]);

    % Save this chromophore stack
    chromFileName = [fileName(1:(end-5)) '-unmix-naive.tiff'];
    %chromFileName = [fileName(1:(end-5)) '-unmix' num2str(-powToUseInThisCase*100) '.tiff'];
    save_tiff_stack(single(chromStack),[dataPath filesep chromFileName]);
end





