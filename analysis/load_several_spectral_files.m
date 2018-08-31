% Script to load Thorlabs OSA .txt spectra files
analysisPathNameArray = regexp(cd,'\','split');
transRetinaPathName = strjoin(analysisPathNameArray(1:(end-1)),'\');
sourceSpectraPathName = [transRetinaPathName filesep 'spectra'];

[spectraFileName, spectraPathName] = uigetfile('*.txt','Pick 660nm LED file');
rawFileData = csvread([spectraPathName spectraFileName]);
maxPow = rawFileData(:,8);
backgroundData = rawFileData(:,10);
wavelengths = rawFileData(:,1);
nmToInterpOver = wavelengths;
our660 = maxPow - backgroundData;
smooth660 = smooth(our660,7);
nour660 = smooth660/sum(smooth660);
TL660 = load_interpolate_spectrum([sourceSpectraPathName filesep 'sources'],'660nmLED',nmToInterpOver,0);
smoothTL660 = smooth(TL660,7);
nTL660 = smoothTL660/sum(smoothTL660);

[spectraFileName, spectraPathName] = uigetfile('*.txt','Pick 730nm LED file');
rawFileData = csvread([spectraPathName spectraFileName]);
maxPow = rawFileData(:,8);
backgroundData = rawFileData(:,10);
wavelengths = rawFileData(:,1);
our730 = maxPow - backgroundData;
smooth730 = smooth(our730,7);
nour730 = smooth730/sum(smooth730);
TL730 = load_interpolate_spectrum([sourceSpectraPathName filesep 'sources'],'730nmLED',nmToInterpOver,0);
smoothTL940 = smooth(TL730,7);
nTL730 = smoothTL940/sum(smoothTL940);

[spectraFileName, spectraPathName] = uigetfile('*.txt','Pick 780nm LED file');
rawFileData = csvread([spectraPathName spectraFileName]);
maxPow = rawFileData(:,8);
backgroundData = rawFileData(:,10);
wavelengths = rawFileData(:,1);
our780 = maxPow - backgroundData;
smooth780 = smooth(our780,7);
nour780 = smooth780/sum(smooth780);
TL780 = load_interpolate_spectrum([sourceSpectraPathName filesep 'sources'],'780nmLED',nmToInterpOver,0);
smoothTL780 = smooth(TL780,7);
nTL780 = smoothTL780/sum(smoothTL780);

[spectraFileName, spectraPathName] = uigetfile('*.txt','Pick 850nm LED file');
rawFileData = csvread([spectraPathName spectraFileName]);
maxPow = rawFileData(:,8);
backgroundData = rawFileData(:,10);
wavelengths = rawFileData(:,1);
our850 = maxPow - backgroundData;
smooth850 = smooth(our850,7);
nour850 = smooth850/sum(smooth850);
TL850 = load_interpolate_spectrum([sourceSpectraPathName filesep 'sources'],'850nmLED',nmToInterpOver,0);
smoothTL850 = smooth(TL850,7);
nTL850 = smoothTL850/sum(smoothTL850);

[spectraFileName, spectraPathName] = uigetfile('*.txt','Pick 940nm LED file');
rawFileData = csvread([spectraPathName spectraFileName]);
maxPow = rawFileData(:,8);
backgroundData = rawFileData(:,10);
wavelengths = rawFileData(:,1);
our940 = maxPow - backgroundData;
smooth940 = smooth(our940,7);
nour940 = smooth940/sum(smooth940);
TL940 = load_interpolate_spectrum([sourceSpectraPathName filesep 'sources'],'940nmLED',nmToInterpOver,0);
smoothTL940 = smooth(TL940,7);
nTL940 = smoothTL940/sum(smoothTL940);

% Plot comparisons
plot(nmToInterpOver,nTL660,'k--',nmToInterpOver,nTL730,'k--',nmToInterpOver,nTL780,'k--',nmToInterpOver,nTL850,'k--',nmToInterpOver,nTL940,'k--')
hold on;
plot(wavelengths,nour660,'b',wavelengths,nour730,'b',wavelengths,nour780,'b',wavelengths,nour850,'b',wavelengths,nour940,'b');
xlabel('Wavelength (nm)')
ylabel('Power (normalized)')
title('Dotted: Thorlabs LED Spectra, Solid: Measured LED spectra')
