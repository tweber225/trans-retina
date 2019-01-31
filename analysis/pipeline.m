function pipeline(filePathName,options)
% ANALYSIS/PIPELINE
% [explanation]
%
% Timothy D. Weber
% Biomicroscopy Lab, BU 2018

%% INITIALIZATION
addpath(genpath('file_IO'));
addpath(genpath('subcode'));


%% LOAD DATA
[rawHypStack,settingsStruct] = load_tiff_sequence(filePathName);
numChannels = sum(settingsStruct.channelsEnable);


%% DEFECT CORRECTIONS (DUST OR HOT PIXELS)
% -to do-
correctedHypStack = rawHypStack; clear rawHypStack

tic
%% REGISTRATION
regOpt.skipRotation = 0; % flag to skip rotational registration
regOpt.regBWRadius = 0; % specify the radius of DFT frequencies to use, set to <1 to use selector
regOpt.refFrameNumber = 40;
regOpt.maxAngle = 80e-3; % mrad
regOpt.angleRes = 0.05e-3; % mrad - rotational precision
regOpt.rhoMin = 8; % min pixel radius range to use in rotation detection
regOpt.polDFTUpSampleFactor = 5; % Seems to give abs error <1% based on ...
%... small tests against an explicitly computed DFT at polar points
regOpt.polDFTChunkSize = 64; % Frames to polar-fft at once, 64 seems to be optimal on TDW's desktop
regOpt.minRhoTrans = 8;
regOpt.subPixelPrecision = 1/64; % sub-pixel translation precision
regOpt.pixelZoomRange = 1.5; % range of pixels in which to zoom in around course estimate of peak
regOpt.transChunkSize = 128; % # frames to detect translation in at once
regOpt.rotRegSmoothSpan = 24;
regOpt.transRegSmoothSpan = 6;
regOpt.dateComputed = string(datetime);

hyperList(numChannels).rotHList = zeros(settingsStruct.framesetsToCapture);
hyperList(numChannels).transHList = zeros(settingsStruct.framesetsToCapture,2);
hyperList(numChannels).rotPeakHList = zeros(settingsStruct.framesetsToCapture);
hyperList(numChannels).transPeakHList = zeros(settingsStruct.framesetsToCapture);


for cIdx = 1:numChannels
    disp(['Registering channel ' num2str(cIdx) ' of ' num2str(numChannels)]);
    %[rotHList(:,cIdx),transHList(:,:,cIdx),rotPeakHList(:,cIdx),transPeakHList(:,cIdx),regOpt] = register_single_sequence(correctedHypStack(:,:,:,cIdx),regOpt);
    [hyperList(cIdx),regOpt] = register_single_sequence(correctedHypStack(:,:,:,cIdx),regOpt);
end

% Fuse individual channel registration results
fusedList = fuse_reg_paths(hyperList,regOpt);

% Shift frames into final registered positions
registeredHypStack = transform_hyper_stack(correctedHypStack,fusedList,regOpt);

toc
%% SAVING REGISTRATION RESULTS
save_reg_results(registeredHypStack,filePathName,regOpt,settingsStruct,hyperList,fusedList)

