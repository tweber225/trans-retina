function rawStack = load_single_color_fundus(useUI,dirName,fileName)
% ANALYSIS/REGISTER_SINGLE_COLOR_FUNDUS
% Function to load in raw fundus image data for further processing. useUI
% flag enables the use of the built-in MATLAB User Interface for finding
% the desired data file. Or if MATLAB UI is not used, the user must
% manually enter valid directory and filename strings (dirName, fileName).
%
% Part 1 of standard image processing pipeline
% Timothy D. Weber
% Biomicroscopy Lab, BU 2017

% Get filename and directory if using the MATLAB UI, or check validity of
% manually-input directory and filenames
if useUI == 1
    [tiffFileName,tiffPathName,~] = uigetfile('*.tiff','Select First TIFF Image File');
elseif useUI == 0
    if ischar(dirName) && ischar(fileName)
        tiffFileName = fileName;
        tiffPathName = dirName;
    else
        error('Directory and filename arguments are invalid!')
    end
else
    error('useUI argument value is invalid!')
end

% Load image info to get stack's dimensions (pixels height, width, number
% of frames)
tiffFileInfo = imfinfo([tiffPathName filesep tiffFileName]);
numFrames = numel(tiffFileInfo);

% Allocate space and load first image data
rawStack = zeros(tiffFileInfo(1).Height,tiffFileInfo(1).Width,numFrames);

% Load subsequent images
disp(['Loading ' num2str(numFrames) ' frames'])
for frameIdx = 1:numFrames
    rawStack(:,:,frameIdx) = imread([tiffPathName filesep tiffFileName],frameIdx,'Info',tiffFileInfo);
end



