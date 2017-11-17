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

% Input LED-source channels
sourceList = {'850nmLED', '780nmLED', '730nmLED', '660nmLED', '940nmLED'};
dataPath = 'C:\Users\tweber\Desktop\local data analysis\170905';
captureFileNameList = {'170905_subject001_capture001', ...
    '170905_subject001_capture002', ...
    '170905_subject001_capture003', ...
    '170905_subject001_capture004', ...
    '170905_subject001_capture005', ...
    '170905_subject001_capture006'};
fileNameList = {'170905_subject001_capture001_850nm-absorb.tiff', ...
    '170905_subject001_capture002_780nm-absorb.tiff', ...
    '170905_subject001_capture003_780nm-absorb.tiff', ...
    '170905_subject001_capture004_730nm-absorb.tiff', ...
    '170905_subject001_capture005_660nm-absorb.tiff', ...
    '170905_subject001_capture006_660nm-absorb.tiff'};
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

% Crop to minimum frame width
for sourceIdx = 1:numSources
    currFrameWidth = size(absStackArray{sourceIdx},1);
    cropFromEachSide = (currFrameWidth-minFrameWidth)/2;
    absStackArray{sourceIdx} = absStackArray{sourceIdx}((1+cropFromEachSide):(end-cropFromEachSide),(1+cropFromEachSide):(end-cropFromEachSide),:);
end


%% Load source spectra
analysisPathName = regexp(cd,filesep,'split');
sourcePathName = [strjoin(analysisPathName{1:(end-1)}) filesep 'spectra' filesep 'sources'];

% Load all the spectra into a cell array of structures for each spectra
% (wavelength, absorbance pair)
for sourceIdx = 1:numSources
    sourceSpectra{chromIdx} = load([sourcePathName sourceList{chromIdx} '.mat'],'waveLen','emission');
end

% Down-sample/interpolate to 1nm sampling from 600 to 1000nm


%% Load chromophore spectra
chromophorePathName = [strjoin(analysisPathName{1:(end-1)}) filesep 'spectra' filesep 'chromophores'];

% Load all the spectra into a cell array of structures for each spectra
% (wavelength, absorbance pair)
for chromIdx = 1:numChroms
    chromSpectra{chromIdx} = load([chromophorePathName chromList{chromIdx} '.mat'],'waveLen','absorbance');
end

% Down-sample/interpolate to 1nm sampling from 600 to 1000nm



%% Register each absorption stack

