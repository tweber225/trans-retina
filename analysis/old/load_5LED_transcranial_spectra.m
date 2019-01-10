% Script to load Thorlabs OSA .txt spectra files

[spectraFileName, spectraPathName] = uigetfile('*.txt','Pick Spectra File');
rawFileData = csvread([spectraPathName spectraFileName]);
numSpectraInFile = size(rawFileData,2)/2-1;

spectraData = fliplr(rawFileData(:,2:2:numSpectraInFile*2));
wavelengths = rawFileData(:,1);

% background is the last spectrum
backgroundData = rawFileData(:,(numSpectraInFile+1)*2);

% Subtract background from each
bgCorrSpectra = spectraData - repmat(backgroundData,[1 numSpectraInFile]);

% Add 660nm spectrum
[spectraFileName, spectraPathName] = uigetfile('*.txt','Pick Spectra File');
rawFileData = csvread([spectraPathName spectraFileName]);
spectrumData = rawFileData(:,4);
backgroundData = rawFileData(:,6);
bgCorrSpectra = [spectrumData-backgroundData,bgCorrSpectra];

% Add 940nm spectrum
[spectraFileName, spectraPathName] = uigetfile('*.txt','Pick Spectra File');
rawFileData = csvread([spectraPathName spectraFileName]);
spectrumData = rawFileData(:,2);
backgroundData = rawFileData(:,4);
bgCorrSpectra = [bgCorrSpectra,spectrumData-backgroundData];


%% Smooth out the background-corrected spectra
numSpectraInFile = 5;
movingAvgSpectra = bgCorrSpectra;
regressSpectra = bgCorrSpectra;
percentsForRegression = [1.5 2.5 1 1 2]/100;
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
smoothFactor = 1;
% load 660nm LED data
[spectraFileName, spectraPathName] = uigetfile('*.txt','Load 660nm LED');
rawFileData = csvread([spectraPathName spectraFileName]);
singleLEDSpec = rawFileData(:,8);
bgSpec = rawFileData(:,10);
smoothSpec = smooth(singleLEDSpec-bgSpec,smoothFactor);
normIncSpectra(:,1) = smoothSpec./sum(smoothSpec);

% load 730nm LED data
[spectraFileName, spectraPathName] = uigetfile('*.txt','Load 730nm LED');
rawFileData = csvread([spectraPathName spectraFileName]);
singleLEDSpec = rawFileData(:,8);
bgSpec = rawFileData(:,10);
smoothSpec = smooth(singleLEDSpec-bgSpec,smoothFactor);
normIncSpectra(:,2) = smoothSpec./sum(smoothSpec);

% load 780nm LED data
[spectraFileName, spectraPathName] = uigetfile('*.txt','Load 780nm LED');
rawFileData = csvread([spectraPathName spectraFileName]);
singleLEDSpec = rawFileData(:,8);
bgSpec = rawFileData(:,10);
smoothSpec = smooth(singleLEDSpec-bgSpec,smoothFactor);
normIncSpectra(:,3) = smoothSpec./sum(smoothSpec);

% load 850nm LED data
[spectraFileName, spectraPathName] = uigetfile('*.txt','Load 850nm LED');
rawFileData = csvread([spectraPathName spectraFileName]);
singleLEDSpec = rawFileData(:,8);
bgSpec = rawFileData(:,10);
smoothSpec = smooth(singleLEDSpec-bgSpec,smoothFactor);
normIncSpectra(:,4) = smoothSpec./sum(smoothSpec);

% load 940nm LED data
[spectraFileName, spectraPathName] = uigetfile('*.txt','Load 940nm LED');
rawFileData = csvread([spectraPathName spectraFileName]);
singleLEDSpec = rawFileData(:,8);
bgSpec = rawFileData(:,10);
smoothSpec = smooth(singleLEDSpec-bgSpec,smoothFactor);
normIncSpectra(:,5) = smoothSpec./sum(smoothSpec);

%% Normalize transmission spectra, but first set a few ranges to 0
normRegressSpectra = regressSpectra;
normRegressSpectra(wavelengths<630 | wavelengths>715,1) = 0;
normRegressSpectra(wavelengths<680 | wavelengths>770,2) = 0;
normRegressSpectra(wavelengths<708 | wavelengths>847,3) = 0;
normRegressSpectra(wavelengths<753 | wavelengths>915,4) = 0;
normRegressSpectra(wavelengths<785 | wavelengths>975,5) = 0;
normRegressSpectra = normRegressSpectra./(repmat(sum(normRegressSpectra),[numel(wavelengths) 1]));

%% Plot comparison
% !!--- Also Could load data variables here ---!!
figure;
plot(wavelengths,normRegressSpectra,'b--');hold on
plot(wavelengths,normIncSpectra,'k')
xlabel('Wavelength (nm)')
title('Black solid: before head, Blue dotted: After transmission')
figure;

%% Plot OD's
b1 = [640 698];
b2 = [692 748];
b3 = [742 815];
b4 = [805 882];
b5 = [870 965];

selector1 = wavelengths>b1(1) & wavelengths<b1(2);
selector2 = wavelengths>b2(1) & wavelengths<b2(2);
selector3 = wavelengths>b3(1) & wavelengths<b3(2);
selector4 = wavelengths>b4(1) & wavelengths<b4(2);
selector5 = wavelengths>b5(1) & wavelengths<b5(2);

wl1 = wavelengths(selector1);
wl2 = wavelengths(selector2);
wl3 = wavelengths(selector3);
wl4 = wavelengths(selector4);
wl5 = wavelengths(selector5);

dat1 = -log(bgCorrSpectra(selector1,1)./normIncSpectra(selector1,1));
offset = -2.7;
dat2 = offset-log(bgCorrSpectra(selector2,2)./normIncSpectra(selector2,2));
offset = offset+0.5;
dat3 = offset-log(bgCorrSpectra(selector3,3)./normIncSpectra(selector3,3));
offset = offset+1;
dat4 = offset-log(bgCorrSpectra(selector4,4)./normIncSpectra(selector4,4));
offset = offset+1.15;
dat5 = offset-log(bgCorrSpectra(selector5,5)./normIncSpectra(selector5,5));

plot(wl1,(dat1),'.');hold on
plot(wl2,(dat2),'.');
plot(wl3,(dat3),'.');
plot(wl4,(dat4),'.');
plot(wl5,(dat5),'.');

% combine this data
allWl = [wl1;wl2;wl3;wl4;wl5];
allDat = [dat1;dat2;dat3;dat4;dat5];
plot(allWl,smooth(allWl,allDat,.04,'rloess'),'k.');
hold off
xlabel('Wavelength (nm)')
ylabel('Relative absorbance')
title('Stitched together relative absorbance spectrum through head')

%%
plot(wl1,(dat1+.5),'.');hold on
plot(wl2(180:(end-20)),(dat2(180:(end-20))+.25),'.');
plot(wl3,(dat3),'.');
plot(wl4(1:end-100),(dat4(1:end-100)),'.');

plot(jwl1,(jdat1+1.3),'.');
plot(jwl2,(jdat2+2.4),'.');
plot(jwl3,(jdat3+2.7),'.');
plot(jwl4,(jdat4+2.83),'.');
plot(jwl5,(jdat5+2.83),'.');

allallWl = [wl1;wl2;wl3;wl4(1:end-100);jwl1;jwl2;jwl3;jwl4;jwl5];
allallDat = [dat1+.5;dat2+.25;dat3;dat4(1:end-100);jdat1+1.3;jdat2+2.4;jdat3+2.7;jdat4+2.83;jdat5+2.83];

% gather all the data and put into rlowess
smoothedData = smooth(allallWl,allallDat,.025,'rlowess');
uniqueWl = unique(allallWl);
uniqueSpec = uniqueWl;
for idx = 1:numel(uniqueWl)
    uniqueSpec(idx) = mean(smoothedData(allallWl == uniqueWl(idx)));
end
    
plot(uniqueWl,uniqueSpec,'k.');

extrapInterpRange = 600:1000;
interpSpec = interp1(uniqueWl,uniqueSpec,extrapInterpRange,'spline','extrap');
plot(extrapInterpRange,interpSpec,'k.');

hold off


%% Try to renormalize incident LEDs by spectrum and compare

transLinear = exp(-real(interpSpec'));

numSpectraInFile = 5;
for sIdx = 1:numSpectraInFile
    interpedNormLEDs(:,sIdx) = interp1(wavelengths,normIncSpectra(:,sIdx),extrapInterpRange)';
end
reNormedLEDs = interpedNormLEDs.*repmat(transLinear,[1 numSpectraInFile]);
reNormedLEDs = reNormedLEDs./repmat(sum(reNormedLEDs),[numel(extrapInterpRange) 1]);

figure; % Show simulated transmission LEDs (normalized)
scaleFactor = numel(wavelengths)/numel(extrapInterpRange);
plot(extrapInterpRange,reNormedLEDs/((2/3)*scaleFactor),'k'); hold on;
plot(wavelengths,normIncSpectra,'g');
plot(wavelengths,normRegressSpectra,'b--');
xlabel('Wavelength (nm)');
ylabel('Intensity (normalized)')
title('Gray solid: Measured LEDs, Black solid: Simulated transmission, Dashed: Measured transmission')
hold off




