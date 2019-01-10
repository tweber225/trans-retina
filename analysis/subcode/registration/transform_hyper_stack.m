function registeredHypStack = transform_hyper_stack(inputHypStack,fusedList,regOpt)

numChannels = size(inputHypStack,4);
numFrames = size(inputHypStack,3);

rotHypList = fusedList.rot;
transHypList = fusedList.trans;


registeredHypStack = zeros(size(inputHypStack),'single');
% Loop through channels
for cIdx = 1:numChannels
    disp(['Transforming channel ' num2str(cIdx)])
    % Loop through the frames
    for frameIdx = 1:numFrames
        if regOpt.skipRotation == 1
            rotFrame = inputHypStack(:,:,frameIdx,cIdx);
        else
            % Rotate frame
            rotFrame = imrotate(inputHypStack(:,:,frameIdx,cIdx),-rad2deg(rotHypList(frameIdx,cIdx)),'bilinear','crop');
        end
        % Translate frame
        registeredHypStack(:,:,frameIdx,cIdx) = imtranslate(rotFrame,-transHypList(frameIdx,:,cIdx));
    end

end