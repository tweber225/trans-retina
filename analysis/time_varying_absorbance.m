% ANALYSIS/TIME_VARYING_ABSORBANCE
% Script to load registered frame stack, crop, flatten, and convert stack
% to relative absorbance.
%
% 1. Load registered frame stack
% 2. For each frame: flatten, convert to absorbance.
% 3. Save processed data
% 
% Timothy D. Weber
% Biomicroscopy Lab, BU 2018

%% Parameters and filenames
kernelRad = 20; % Kernel width to use in smooth-local max filter
showPreview = 0; % To show absorbance calc results during the processing
estimateEnvelop = 0;
stackPath = 'C:\Users\tweber\Desktop\local data analysis\170905\170905_subject001_capture001';
stackFileName = '170905_subject001_capture001_850nm-fullReg.tiff';
maskFileName = 'average_mask.tiff';

%% 1.) Load registered frame stack and cropping binary mask
stackFullPathFilename = [stackPath filesep stackFileName];
stackFileInfo = imfinfo(stackFullPathFilename);
numFrames = numel(stackFileInfo);
regStack = zeros(stackFileInfo(1).Height,stackFileInfo(1).Width,numFrames);
disp('Loading stack...')
for frameIdx = 1:numFrames
    regStack(:,:,frameIdx) = imread(stackFullPathFilename,frameIdx,'Info',stackFileInfo);
end
weightFrame = double(imread([stackPath filesep maskFileName]) ~= 0);


%% 2.) Image flattening and absorbance calculation
% Make grid to use for envelope
[xGr, yGr] = meshgrid(1:stackFileInfo(1).Width,1:stackFileInfo(1).Height);

%% Loop through frames
absorbanceStack = zeros(stackFileInfo(1).Height,stackFileInfo(1).Width,numFrames);
for frameIdx = 1:numFrames
    disp(['Processing frame #' num2str(frameIdx)]);
    % b.) Compute envelop and divide out envelope
    warning('off','all');
    if estimateEnvelop == 1
        [curve, goodness, output] = fit([xGr(:) yGr(:)],reshape(regStack(:,:,frameIdx),[stackFileInfo(1).Height*stackFileInfo(1).Width,1]),'poly33','Weights',weightFrame(:));
        illumEnvelope = reshape(feval(curve,[xGr(:) yGr(:)]),size(xGr));
    else
        illumEnvelope = ones(stackFileInfo(1).Height,stackFileInfo(1).Width);
    end    
    flatFrame = regStack(:,:,frameIdx)./illumEnvelope;
    warning('on','all');

    % c.) Repeat filtering with different regression fitting spans
    if (showPreview==1) && (frameIdx==1), figure; end
    
    % Process with smooth-local maximum filter, to estimate incident light
    % intensity
    smoothMaxFrame = smooth_max_filter(flatFrame,kernelRad);

    % Compute log of ratio to get absorbance
    absImg = real(1*log10(smoothMaxFrame./flatFrame));
    absorbanceStack(:,:,frameIdx) = absImg;
    if showPreview == 1
        whiteValue = quantile(absImg(:),0.8);
        blackValue = quantile(absImg(:),0.3);
        imagesc(absImg,[blackValue whiteValue]);
        colormap gray;title(['Frame #' num2str(frameIdx)]);drawnow;
    end

end

%% 3.) Save absorbance stack
absorbanceStackFileName = [stackFileName(1:(end-5)) '-absorb.tiff'];
save_tiff_stack(single(real(absorbanceStack)),[stackPath filesep absorbanceStackFileName]);

