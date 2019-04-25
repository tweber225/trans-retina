function trans_refl_comparison(captureFilePath)
% Function that fits vessel networks to model and compares reflection
% (channel 1) vs transmission (channel 2)
addpath(genpath('file_IO'));
addpath(genpath('subcode'));

% Load average images
analysisPath = [captureFilePath filesep 'analysis'];
reflFilePath = [analysisPath filesep 'channel1averaged.tif'];
transFilePath = [analysisPath filesep 'channel2averaged.tif'];
refl = loadtiff(reflFilePath);
trans = loadtiff(transFilePath);

% Load the segments
segments = load_vessel_network([captureFilePath filesep 'analysis' filesep 'network.txt']);

% Subtract sensor background for the images
backgroundLevel = 1603; % check this a priori
transCorrected = double(trans-backgroundLevel);
reflCorrected = double(refl-backgroundLevel);

% Fit the transmission image
[~,transFit] = fit_vessel_network(segments,transCorrected,'channel2',analysisPath);

% Fit the reflection image
[interpSegments,reflFit] = fit_vessel_network(segments,reflCorrected,'channel1',analysisPath);

%% Save results
saveFileName = [analysisPath filesep 'trans_refl_fits.mat'];
save(saveFileName,'interpSegments','transFit','reflFit');

