function [hyperList, regOpt] = register_single_sequence(frameStack,regOpt)
% Outputs list of frameshifts and cross correlation peak values

%% Class conversion
frameStack = single(frameStack);

%% ESTIMATE SIGNAL BW
% Compute 2D-FT over (square) cropped version of stack (1st 256 only)
sizeHypStack = size(frameStack); extraCols = sizeHypStack(2)-sizeHypStack(1);
if sizeHypStack(3) < 256
    endFrame = sizeHypStack(3);
else
    endFrame = 256;
end
if regOpt.regBWRadius < 1
    bhWin = blackman_harris(sizeHypStack(1));
    FTStack = fft2(bhWin(:,:,ones(1,endFrame)).*frameStack(:,(extraCols/2+1):(end-extraCols/2),1:endFrame));
else
    FTStack = zeros(sizeHypStack(1),sizeHypStack(2));
end

BWMask = select_img_bandwidth(FTStack,regOpt);
clear FTStack % clear it to allow more memory for rotation detection
% .. and also since it will be obsolete after rotating the stack


%% DETECT ROTATION
[rotList,rotXCPeaks] = detect_rotation(BWMask,frameStack(:,(extraCols/2+1):(end-extraCols/2),:),regOpt);


%% ROTATE STACK INTO PLACE
rotatedStack = rotate_stack(frameStack,rotList,regOpt);
clear frameStack

%% DETECT TRANSLATION
[transList,transXCPeaks] = detect_translation(BWMask,rotatedStack(:,(extraCols/2+1):(end-extraCols/2),:),regOpt);


hyperList.rotHList = rotList;
hyperList.transHList = transList;
hyperList.rotPeakHList = rotXCPeaks;
hyperList.transPeakHList = transXCPeaks;
