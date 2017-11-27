% ANALYSIS/FUNDUS_IMAGE_PROCESSING_BATCH SCRIPT
% Script to automatically run several registration, flattening, and
% absorbance processing pipelines
%
% Timothy D. Weber
% Biomicroscopy Lab, BU 2017

% Define files to run
dataPath = 'C:\Users\tweber\Desktop\local data analysis\170905';
captureFileNameList = {'170905_subject001_capture001', ...
    '170905_subject001_capture002', ...
    '170905_subject001_capture003', ...
    '170905_subject001_capture004', ...
    '170905_subject001_capture005', ...
    '170905_subject001_capture006'};
fileNameList = {'170905_subject001_capture001_850nm.tiff', ...
    '170905_subject001_capture002_780nm.tiff', ...
    '170905_subject001_capture003_780nm.tiff', ...
    '170905_subject001_capture004_730nm.tiff', ...
    '170905_subject001_capture005_660nm.tiff', ...
    '170905_subject001_capture006_660nm.tiff'};

% Loop through processing (registration) pipeline calls
numFilesToRun = numel(fileNameList);
% 
% for pipeIdx = 1:numFilesToRun
%     newFileName = fileNameList{pipeIdx};
%     newPathName = [dataPath filesep captureFileNameList{pipeIdx}];
%     fundus_image_processing_pipeline
% end


% Loop through absorbance processing scripts
for pipeIdx = 1:numFilesToRun
    newFileName = fileNameList{pipeIdx};
    stableAvgFrameFileName = [newFileName(1:(end-5)) '-stableAvg.tiff']; % Should be a single-precision float
    newPathName = [dataPath filesep captureFileNameList{pipeIdx}];
    fundus_image_absorbance
end
