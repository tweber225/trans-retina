function outSpectrum = load_interpolate_spectrum(folderDir,fileNameMinusExt,nmToInterpOver,normalizePower)
% ANALYSIS/LOAD_INTERPOLATE_SPECTRUM
% Function to load a tabulated source or chromophore spectrum (in xlsx
% format) and linearly interpolate to a new set of wavelength indices
% Last argument is a flag to normalize the spectrum's area under the curve
%
% Timothy D. Weber
% Biomicroscopy Lab, BU 2017

% Load the xlsx spectrum file (first column should be wavelengths in nm,
% second column should be absorption or emission)
fullFileName = [folderDir filesep fileNameMinusExt '.xlsx'];
rawXLSData = xlsread(fullFileName);
rawWavelengths = rawXLSData(:,1);
rawSpectrum = rawXLSData(:,2);

% Calculate wavelength pitch of spectrum
wavelengthPitch = mean(diff(rawWavelengths));

% Determine moving average span width (~2.5nm resolution is good enough)
spanWidth = floor(1/wavelengthPitch)*2+1;

% Smooth out the spectrum
smoothSpectrum = smooth(rawSpectrum,spanWidth);

% Interpolate new values
outSpectrum = interp1(rawWavelengths,smoothSpectrum,nmToInterpOver);
outSpectrum = reshape(outSpectrum,[numel(outSpectrum),1]);

% If desired, normalize the power of the spectrum
if normalizePower == 1
    outSpectrum = outSpectrum/sum(outSpectrum);   
end

% Force <0 to 0
outSpectrum(outSpectrum<0) = 0;