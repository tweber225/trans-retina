% Script to load Thorlabs OSA .txt spectra files

[spectraFileName, spectraPathName] = uigetfile('*.txt','Pick Spectra File #1');
rawFileData = csvread([spectraPathName spectraFileName]);
numSpectraInFile = size(rawFileData,2)/2-1;

spectraData = rawFileData(:,2:2:numSpectraInFile*2);
backgroundData = rawFileData(:,(numSpectraInFile+1)*2);
wavelengths = rawFileData(:,1);


% %% Do something with the spectrum below here
% % Subtract off background
% bgCorrSpectra = spectraData - repmat(backgroundData,[1 numSpectraInFile]);
% 
% % Smooth out each background-corrected spectrum
% wavelengthPitch = mean(diff(wavelengths));
% smoothSpan = floor(.5/wavelengthPitch)*2+1; % smooth to ~1nm resolution
% smoothSpectra = bgCorrSpectra;
% for sIdx = 1:numSpectraInFile
%     smoothSpectra(:,sIdx) = smooth(bgCorrSpectra(:,sIdx),smoothSpan);
% end
% 
% % Interpolate into standard range
% nmToInterpOver = 580:.5:1050;
% corrSpectra = zeros(numel(nmToInterpOver),numSpectraInFile);
% for sIdx = 1:numSpectraInFile
%     corrSpectra(:,sIdx) = interp1(wavelengths,smoothSpectra(:,sIdx),nmToInterpOver);
% end
% 
% % Blank a certain range to 0
% centerWL = input('What is the nominal center wavelength?');
% minWL = input('Wavelength range, Minimum to use:');
% maxWL = input('Wavelength range, Maximum to use:');
% corrSpectra((nmToInterpOver<minWL | nmToInterpOver>maxWL),:) = 0;
% 
% % normalize integrated power to 1
% powSum = sum(corrSpectra);
% normSpectra = corrSpectra./repmat(powSum,[numel(nmToInterpOver) 1]);
% 
% % Compute mean wavelength
% meanWavelength = sum(repmat(nmToInterpOver',[1 numSpectraInFile]).*normSpectra);
% 
% % Plot results
% plot(nmToInterpOver,normSpectra)
% legend(['3/6 Power (Mean Wavelength = ' num2str(meanWavelength(1)) 'nm)'], ...
% ['4/6 Power (Mean Wavelength = ' num2str(meanWavelength(2)) 'nm)'], ...
% ['5/6 Power (Mean Wavelength = ' num2str(meanWavelength(3)) 'nm)'], ...
% ['6/6 Power (Mean Wavelength = ' num2str(meanWavelength(4)) 'nm)']);
% xlabel('Wavelength (nm)');
% title([num2str(centerWL) 'nm LED at different currents']);
% axis tight
% 
% %% Compare effect on chromophores - HbO2, Hb, and  Melanin
% analysisPathNameArray = regexp(cd,'\','split');
% transRetinaPathName = strjoin(analysisPathNameArray(1:(end-1)),'\');
% spectraPathName = [transRetinaPathName filesep 'spectra'];
% HbO2 = load_interpolate_spectrum([spectraPathName filesep 'chromophores'],'HbO2',nmToInterpOver,0);
% Hb = load_interpolate_spectrum([spectraPathName filesep 'chromophores'],'Hb',nmToInterpOver,0);
% melanin = load_interpolate_spectrum([spectraPathName filesep 'chromophores'],'melanin',nmToInterpOver,0);
% 
% HbO2EffAbs = sum(repmat(HbO2,[1 numSpectraInFile]).*normSpectra)./sum(normSpectra);
% HbEffAbs = sum(repmat(Hb,[1 numSpectraInFile]).*normSpectra)./sum(normSpectra);
% melaninEffAbs = sum(repmat(melanin,[1 numSpectraInFile]).*normSpectra)./sum(normSpectra);
% 
% % Compute percent error if we assume the max power
% HbO2PercErr = 100*(HbO2EffAbs - HbO2EffAbs(end))./HbO2EffAbs(end);
% HbPercErr = 100*(HbEffAbs - HbEffAbs(end))./HbEffAbs(end);
% melaninPercErr = 100*(melaninEffAbs - melaninEffAbs(end))./melaninEffAbs(end);
% powSum;

% %% Do something with the spectrum below here
% % Subtract off background
% bgCorrSpectra = spectraData - repmat(backgroundData,[1 numSpectraInFile]);
% 
% % Smooth out each background-corrected spectrum
% wavelengthPitch = mean(diff(wavelengths));
% smoothSpan = floor(.5/wavelengthPitch)*2+1; % smooth to ~1nm resolution
% smoothSpectra = bgCorrSpectra;
% for sIdx = 1:numSpectraInFile
%     smoothSpectra(:,sIdx) = smooth(bgCorrSpectra(:,sIdx),smoothSpan);
% end
% 
% % Interpolate into standard range
% nmToInterpOver = 580:.5:1000;
% corrSpectra = zeros(numel(nmToInterpOver),numSpectraInFile);
% for sIdx = 1:numSpectraInFile
%     corrSpectra(:,sIdx) = interp1(wavelengths,smoothSpectra(:,sIdx),nmToInterpOver);
% end
% 
% % Blank a certain range to 0
% centerWL = input('What is the nominal center wavelength?');
% minWL = input('Wavelength range, Minimum to use:');
% maxWL = input('Wavelength range, Maximum to use:');
% corrSpectra((nmToInterpOver<minWL | nmToInterpOver>maxWL),:) = 0;
% 
% % normalize integrated power to 1
% powSum = sum(corrSpectra);
% normSpectra = corrSpectra./repmat(powSum,[numel(nmToInterpOver) 1]);
% 
% % Compute mean wavelength
% meanWavelength = sum(repmat(nmToInterpOver',[1 numSpectraInFile]).*normSpectra);
% 
% % Plot results
% plot(nmToInterpOver,normSpectra)
% legend(['90Hz (33% duty) (Mean Wavelength = ' num2str(meanWavelength(1)) 'nm)'], ...
% ['CW (Mean Wavelength = ' num2str(meanWavelength(2)) 'nm)']);
% xlabel('Wavelength (nm)');
% title([num2str(centerWL) 'nm LED pulsed vs CW']);
% axis tight
% 



%% Do something with the spectrum below here
% Subtract off background
bgCorrSpectra = spectraData - repmat(backgroundData,[1 numSpectraInFile]);

% Smooth out each background-corrected spectrum
wavelengthPitch = mean(diff(wavelengths));
smoothSpan = floor(.5/wavelengthPitch)*2+1; % smooth to ~1nm resolution
smoothSpectra = bgCorrSpectra;
for sIdx = 1:numSpectraInFile
    smoothSpectra(:,sIdx) = smooth(bgCorrSpectra(:,sIdx),smoothSpan);
end

ODEye = log(smoothSpectra(:,2)./smoothSpectra(:,1));
plot(wavelengths,ODEye)
xlabel('Wavelength');
ylabel('Relative OD of head and eye')

% normalize integrated power to 1
powSum = sum(smoothSpectra);
normSpectra = smoothSpectra./repmat(powSum,[numel(wavelengths) 1]);

% plot norm spectra
plot(wavelengths,normSpectra)

