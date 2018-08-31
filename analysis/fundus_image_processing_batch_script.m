% ANALYSIS/FUNDUS_IMAGE_PROCESSING_BATCH SCRIPT
% Script to automatically run several registration, flattening, and
% absorbance processing pipelines
%
% Timothy D. Weber
% Biomicroscopy Lab, BU 2017

% Define files to run
% dataPath = 'C:\Users\tweber\Desktop\local data analysis\170905';
% captureFileNameList = {'170905_subject001_capture001', ... %850
%     '170905_subject001_capture003', ... % 780
%     '170905_subject001_capture004', ... % 730
%     '170905_subject001_capture005', ... % 660
%     '170905_subject001_capture006'}; % 940
% fileNameList = {'170905_subject001_cropcapture001_850nm.tiff', ...
%     '170905_subject001_cropcapture003_780nm.tiff', ...
%     '170905_subject001_cropcapture004_730nm.tiff', ...
%     '170905_subject001_cropcapture005_660nm.tiff', ...
%     '170905_subject001_cropcapture006_660nm.tiff'}; % actually 940
dataPath = 'C:\Users\tweber\Desktop\local data analysis\170905';
captureFileNameList = {'170905_subject001_capture006', ... %940
    '170905_subject001_capture003', ... % 780
    '170905_subject001_capture004', ... % 730
    '170905_subject001_capture005', ... % 660
    '170905_subject001_capture001'}; % 850
fileNameList = {'average', ...
    'average', ...
    'average', ...
    'average', ...
    'average'};

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
    stableAvgFrameFileName = [newFileName '.tiff']; % Should be a single-precision float
    stableAvgFrameFileNameMask = [newFileName '_mask.tiff'];
    newPathName = [dataPath filesep captureFileNameList{pipeIdx}];
    fundus_image_absorbance_alt
end
