function [rawStack,tiffFileName,tiffPathName] = load_single_color_fundus(useUI,dirName,fileName)
% ANALYSIS/REGISTER_SINGLE_COLOR_FUNDUS
% Function to load in raw fundus image data for further processing. useUI
% flag enables the use of the built-in MATLAB User Interface for finding
% the desired data file. Or if MATLAB UI is not used, the user must
% manually enter valid directory and filename strings (dirName, fileName).
%
% Part 1 of standard image processing pipeline
% Timothy D. Weber
% Biomicroscopy Lab, BU 2017

disp('Opening Data')
% Get filename and directory if using the MATLAB UI, or check validity of
% manually-input directory and filenames
if useUI == 1
    [tiffFileName,tiffPathName,~] = uigetfile('*.tiff','Select First TIFF Image File');
    tiffPathName = tiffPathName(1:(end-1));
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
rawStack = zeros(tiffFileInfo(1).Height,tiffFileInfo(1).Width,numFrames,'uint16');

% Load subsequent images
disp(['Selected: ' tiffPathName filesep tiffFileName]);
disp(['Loading ' num2str(numFrames) ' frames'])
for frameIdx = 1:numFrames
    rawStack(:,:,frameIdx) = imread([tiffPathName filesep tiffFileName],frameIdx,'Info',tiffFileInfo);
end

maxPixVal = max(rawStack(:));
effectiveBitDepth = nextpow2(maxPixVal);
scaleFactor = 16-effectiveBitDepth;
disp(['Scaling raw data ' num2str(2^scaleFactor) 'X to fill 16 bit depth']);
rawStack = rawStack*2^scaleFactor;




