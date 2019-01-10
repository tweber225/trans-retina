function polarDFT = polar_fft2(inputImage,fMin,fMax,numAngles,upSampleFactor)
% Compute "recto-polar" DFT (ie points in freq domain lying on concentric
% squares)
interpMethod = 'spline';

%% Check dimensions and class of input image
numPix = size(inputImage,1);
if numPix ~= size(inputImage,2)
    error('polar fft2 expects a square input image')
end
if ~isa(inputImage,'single')
    inputImage = single(inputImage);
end
numFrames = size(inputImage,3);


%% Edges of rectopolar DFT (v=vertical, h=horizontal)
% Calculate the number of zoomed 1d FFT's (ie edges) required
numEdges = (fMax-floor(fMin/sqrt(2)))*upSampleFactor + 1;
fVector = linspace(floor(fMin/sqrt(2)),fMax,numEdges); % location of edges to compute

% 1-D FFTs along x,y-directions 
XFT = fft(permute(inputImage,[2 1 3]),numPix*upSampleFactor,1); % FT along x 
% note: permuting the input to fft is faster than specifying dimension as
% 3rd fft argument (strangely)
XFT = permute(XFT(fVector*upSampleFactor+1,:,:),[2 3 1]); % only keep some columns, and permute st last dimension is the "edge"
YFT = fft(inputImage,numPix*upSampleFactor,1); % FT along y, again upsampled
YFT = permute(YFT(fVector*upSampleFactor+1,:,:),[2 3 1]); % only keep some rows

% Get ready to compute zoomed DFTs along each column/row
m = upSampleFactor*fMax*2; % number of points returned in each zoomed FFT
wVector = exp((-1i*2*pi*fVector/numPix)/(fMax*upSampleFactor)); % increment ammount
aVector = exp(-1i*2*pi*fVector/numPix); % starting point
vEdgesRecto = zeros(m,numEdges,numFrames,'single');
hEdgesRecto = zeros(m,numEdges,numFrames,'single');

% Loop through all the edges
for fIdx = 1:numEdges %fIdx/fVector is kinda like rho in polar coords 
    % Compute a "zoomed" FFT around DC
    % chirp Z-transform is an efficient way to do this
    vEdgesRecto(:,fIdx,:) = reshape(czt(XFT(:,:,fIdx),m,wVector(fIdx),aVector(fIdx)),[m 1 numFrames]);
    hEdgesRecto(:,fIdx,:) = reshape(czt(YFT(:,:,fIdx),m,conj(wVector(fIdx)),conj(aVector(fIdx))),[m 1 numFrames]); 
end

%% First interpolation round:
% i.e. From points arranged on line with equal slope between each to points
% arranged along same line with equal angle between each
equiSlopePoints = linspace(-1,1,m+1)'; % location of points where zoomed FFT evaluated
equiSlopePoints = equiSlopePoints(1:(end-1));
numAnglesPerEdge = numAngles/2;
angleList = -pi/4 + pi*(0:(numAnglesPerEdge))/(2*numAnglesPerEdge);
angleList = angleList(1:(end-1));
equiAnglePoints = tan(angleList)'; % points to interpolate off upsampled zoom FFT

vEdges = permute(interp1(equiSlopePoints,vEdgesRecto,equiAnglePoints,interpMethod),[2 1 3]);
hEdges = permute(interp1(equiSlopePoints,hEdgesRecto,equiAnglePoints,interpMethod),[2 1 3]);

%% Second interpolation round:
% i.e. From equiangluar points along edges (of concentric squares) to full
% polar
polarDFT = zeros(length(fMin:fMax),numAngles,numFrames,'single');
fQuery = (fMin:fMax)';
 
for angleIdx = 1:(numAngles/2)   
    R = (fVector*sqrt(1+equiAnglePoints(angleIdx)^2))';
       
    polarDFT(:,angleIdx,:) = interp1(R,vEdges(:,angleIdx,:),fQuery,interpMethod);
    polarDFT(:,numAngles/2+angleIdx,:) = interp1(R,hEdges(:,angleIdx,:),fQuery,interpMethod);
end
  
