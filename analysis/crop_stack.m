function [croppedStack,cropRange] = crop_stack(inputStack,usePrevCrop,tiffPathName)

% If usePrevCrop flag is false, then have the MATLAB UI guide user through
% setting up the crop
if usePrevCrop == 0
    figure;
    % Pull out the first frame
    firstFrame = double(inputStack(:,:,1));

    % Scale this frame for the cropping UI
    croppingFrame = (firstFrame-min(firstFrame(:)))/(max(firstFrame(:))-min(firstFrame(:)));

    % Use MATLAB's UI to find crop region
    [~,rLims] = imcrop(croppingFrame); 

    % Make even number of pixels per dimension and square
    minDim = min(rLims(3),rLims(4));
    frameEdge = 2*ceil(minDim/2);
    x1 = round(rLims(1));
    x2 = round(rLims(1)+frameEdge)-1;
    y1 = round(rLims(2));
    y2 = round(rLims(2)+frameEdge)-1;
    
    close;
    
elseif usePrevCrop == 1 % otherwise, check whether a crop parameters file exists
    upOneDirCells = regexp(tiffPathName,filesep,'split');
    upOneDir = strjoin(upOneDirCells(1:(end-1)),filesep);
    if exist(fullfile(upOneDir,'cropParams.mat'),'file') == 2
        load(fullfile(upOneDir,'cropParams.mat'),'cropRange');
        x1 = cropRange(1);
        x2 = cropRange(2);
        y1 = cropRange(3);
        y2 = cropRange(4);
        disp('Using saved crop parameters')
    else % If the cropping parameters don't exist then we need to use UI
        figure;
        % Pull out the first frame
        firstFrame = double(inputStack(:,:,1));

        % Scale this frame for the cropping UI
        croppingFrame = (firstFrame-min(firstFrame(:)))/(max(firstFrame(:))-min(firstFrame(:)));

        % Use MATLAB's UI to find crop region
        [~,rLims] = imcrop(croppingFrame); 

        % Make even number of pixels per dimension and square
        minDim = min(rLims(3),rLims(4));
        frameEdge = 2*ceil(minDim/2);
        x1 = round(rLims(1));
        x2 = round(rLims(1)+frameEdge)-1;
        y1 = round(rLims(2));
        y2 = round(rLims(2)+frameEdge)-1;
        
        close;
    end
else
    error('Incorrect cropping argument');
end

% Implement cropping
croppedStack = inputStack(y1:y2,x1:x2,:);

% Return cropping values
cropRange = [x1,x2,y1,y2];

% Save the cropping range if usePrevCrop flag is positive
if (usePrevCrop == 1) && (~(exist(fullfile(upOneDir,'cropParams.mat'),'file') == 2))
    disp('Saving cropping range')
    save(fullfile(upOneDir,'cropParams.mat'),'cropRange');
end

