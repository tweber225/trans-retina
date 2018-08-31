
% Loop through several different melanin power laws
powsToUse = -1.5:-.05:-4.5;
numPowsToUse = numel(powsToUse);

for powIdx = 1:numPowsToUse
    powToUseInThisCase = powsToUse(powIdx);
    fundus_chrom_unmix

end


%% Load all the files and save each chromophore channel into a stack
% Loop through all the case
dataPath = 'C:\Users\tweber\Desktop\local data analysis\170905';
numChroms = 3;
powsToUse = -1.5:-.05:-4.5;
numPowsToUse = numel(powsToUse);
chromStack = zeros(266,338,numChroms,numPowsToUse);

for powIdx = 1:numPowsToUse
    disp(powIdx)
    powToUseInThisCase = powsToUse(powIdx);
    chromFileName = [fileName(1:(end-5)) '-unmix' num2str(-powToUseInThisCase*100) '.tiff'];
    tiffFileInfo = imfinfo([dataPath filesep chromFileName]);
    for frameIdx = 1:numChroms
        chromStack(:,:,frameIdx,powIdx) = imread([dataPath filesep chromFileName],frameIdx,'Info',tiffFileInfo);
        chromStack(:,:,frameIdx,powIdx) = chromStack(:,:,frameIdx,powIdx)./max(max(chromStack(:,:,frameIdx,powIdx)));
    end
end
% Save the 3 channels
save_tiff_stack(single(squeeze(chromStack(:,:,1,:))),[dataPath filesep 'varied_mel_pow_HbO2.tiff']);
save_tiff_stack(single(squeeze(chromStack(:,:,2,:))),[dataPath filesep 'varied_mel_pow_Hb.tiff']);
save_tiff_stack(single(squeeze(chromStack(:,:,3,:))),[dataPath filesep 'varied_mel_pow_mel.tiff']);