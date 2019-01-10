% Script to load Thorlabs OSA .txt spectra files

[spectraFileName, spectraPathName] = uigetfile('*.txt','Pick Spectra File');
rawFileData1 = csvread([spectraPathName spectraFileName]);
numSpectraInFile = size(rawFileData1,2)/2;

spectraData = rawFileData1(:,2:2:numSpectraInFile*2);
wavelengths = rawFileData1(:,1);

% Load background
[spectraFileName, spectraPathName] = uigetfile('*.txt','Pick Background');
rawFileData2 = csvread([spectraPathName spectraFileName]);

backgroundData = rawFileData2(:,2);

% Subtract background from each
bgCorrSpectra = spectraData - repmat(backgroundData,[1 numSpectraInFile]);

%% Smooth out the background-corrected spectra
movingAvgSpectra = bgCorrSpectra;
regressSpectra = bgCorrSpectra;
percentsForRegression = [1 1 0.8 2.5]/100;
for sIdx = 1:numSpectraInFile
    movingAvgSpectra(:,sIdx) = smooth(bgCorrSpectra(:,sIdx),13);
    regressSpectra(:,sIdx) = smooth(bgCorrSpectra(:,sIdx),percentsForRegression(sIdx),'rlowess');
end
plot(wavelengths,bgCorrSpectra,'c.');hold on
plot(wavelengths,movingAvgSpectra,'b.');
plot(wavelengths,regressSpectra,'k')
title('LED transmission through head')
xlabel('Wavelength (nm)')

%% Compare to measured spectrum before head
% load 730nm LED data
[spectraFileName, spectraPathName] = uigetfile('*.txt','Load 730nm LED');
rawFileData = csvread([spectraPathName spectraFileName]);
singleLEDSpec = rawFileData(:,8);
bgSpec = rawFileData(:,10);
smoothSpec = smooth(singleLEDSpec-bgSpec,13);
norm730 = smoothSpec./sum(smoothSpec);

% load 780nm LED data
[spectraFileName, spectraPathName] = uigetfile('*.txt','Load 780nm LED');
rawFileData = csvread([spectraPathName spectraFileName]);
singleLEDSpec = rawFileData(:,8);
bgSpec = rawFileData(:,10);
smoothSpec = smooth(singleLEDSpec-bgSpec,13);
norm780 = smoothSpec./sum(smoothSpec);

% load 850nm LED data
[spectraFileName, spectraPathName] = uigetfile('*.txt','Load 850nm LED');
rawFileData = csvread([spectraPathName spectraFileName]);
singleLEDSpec = rawFileData(:,8);
bgSpec = rawFileData(:,10);
smoothSpec = smooth(singleLEDSpec-bgSpec,13);
norm850 = smoothSpec./sum(smoothSpec);

% load 940nm LED data
[spectraFileName, spectraPathName] = uigetfile('*.txt','Load 940nm LED');
rawFileData = csvread([spectraPathName spectraFileName]);
singleLEDSpec = rawFileData(:,8);
bgSpec = rawFileData(:,10);
smoothSpec = smooth(singleLEDSpec-bgSpec,13);
norm940 = smoothSpec./sum(smoothSpec);

% Normalize transmission specs, first set everything to 0 outside 640 and
% 1000nm
normRegressSpectra = regressSpectra;
normRegressSpectra(wavelengths<640 | wavelengths>1000,:) = 0;
normRegressSpectra = normRegressSpectra./(repmat(sum(normRegressSpectra),[numel(wavelengths) 1]));

%% Plot comparison


% !!--- Also Could load data variables here ---!!

figure;
plot(wavelengths,normRegressSpectra,'b--');hold on
plot(wavelengths,norm730,'k',wavelengths,norm780,'k',wavelengths,norm850,'k',wavelengths,norm940,'k')
xlabel('Wavelength (nm)')
title('Black solid: before head, Blue dotted: After transmission')

%% Plot OD's
b1 = [675 765];
b2 = [711 830];
b3 = [795 900];
b4 = [863 977];

selector1 = wavelengths>b1(1) & wavelengths<b1(2);
selector2 = wavelengths>b2(1) & wavelengths<b2(2);
selector3 = wavelengths>b3(1) & wavelengths<b3(2);
selector4 = wavelengths>b4(1) & wavelengths<b4(2);
wl1 = wavelengths(selector1);
wl2 = wavelengths(selector2);
wl3 = wavelengths(selector3);
wl4 = wavelengths(selector4);
dat1 = -log(bgCorrSpectra(selector1,3)./norm730(selector1));
offset = -.2;
dat2 = offset-log(bgCorrSpectra(selector2,2)./norm780(selector2));
offset = offset+1.3;
dat3 = offset-log(bgCorrSpectra(selector3,1)./norm850(selector3));
offset = offset-.5;
dat4 = offset-log(bgCorrSpectra(selector4,4)./norm940(selector4));

plot(wl1,(dat1),'.');hold on
plot(wl2,(dat2),'.');
plot(wl3,(dat3),'.');
plot(wl4,(dat4),'.');

% combine this data
allWl = [wl1;wl2;wl3;wl4];
allDat = [dat1;dat2;dat3;dat4];
plot(allWl,smooth(allWl,allDat,.04,'rlowess'),'k.');
hold off
xlabel('Wavelength (nm)')
ylabel('Relative absorbance')
title('Stitched together relative absorbance spectrum through head')

