% Script to load several spectra and calculates optical densities

% Load first spectrum set
[tiffFileName,tiffPathName,~] = uigetfile('*.txt','Select First File');
rawData = csvread([tiffPathName tiffFileName]);
numSpectraInFile = size(rawData,2)/2;
for specIdx = 1:numSpectraInFile
    spec1( = rawData(
end



