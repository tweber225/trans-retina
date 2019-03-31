function save_reg_results(registeredHypStack,filePathName,regOpt,settingsStruct,hyperList,fusedList)

savePathName = [filePathName filesep 'analysis'];
disp(['Saving registered frames and records to: ' savePathName ])

numChannels = size(registeredHypStack,4);
oneToSix = 1:6;
cVector = oneToSix(logical(settingsStruct.channelsEnable));

% Save registered images, one channel at a time, convert to 16 bit range
for cIdx = 1:numChannels
    channelSaveName = [savePathName filesep 'channel' num2str(cVector(cIdx)) 'registered.tiff'];
    saveastiff(uint16(2^(16-settingsStruct.bitDepth)*registeredHypStack(:,:,:,cIdx)),channelSaveName);
end

% Save registration settings + info, ie
%-registration options (struct)
%-cross correlation peak values
%-plots of x/y translation & rotation
save([savePathName filesep 'registration_info.mat'],'regOpt','fusedList','hyperList');

% Plot only the 1st channel's fused xy trans and rot
t = (1/settingsStruct.framesetRate)*(0:settingsStruct.framesetsToCapture-1);
figure;plotyy(t,fusedList.trans(:,:,1),t,fusedList.rot(:,1))
xlabel('Time (sec)')
ylabel('Translation / Rotation (yellow)')
title('Detected Translation / Rotation')
saveas(gcf,[savePathName filesep 'trans_rot.png'])

figure;plotyy(t,hyperList(1).transPeakHList,t,hyperList(1).rotPeakHList)
xlabel('Time (sec)')
ylabel('Peak Height')
title('1st Channel Cross Correlation Peak Height')
legend('Translation','Rotation')
saveas(gcf,[savePathName filesep 'xc_peaks.png'])



