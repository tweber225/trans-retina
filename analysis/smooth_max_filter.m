function maxBlurAvgFrame = smooth_max_filter(inputFrame,filterRadius)
% ANALYSIS/SMOOTH_MAX_FILTER
% Filters input frame by finding the maximum around each pixel (in
% circlular area domain of radius filterRadius). Then it blurs the results with a
% Gaussian filter of the same radius. The combined effect is a "smooth
% maximum" filter.
%
% Part 5 of standard image processing pipeline
% Timothy D. Weber
% Biomicroscopy Lab, BU 2017

disp(['Smooth max filtering with radius = ' num2str(filterRadius) ' pixels']);

% Make binary neighborhood mask for filter function
radNumbers = (-filterRadius:filterRadius);
[x,y] = meshgrid(radNumbers,radNumbers);
filtDomain = ((x.^2 + y.^2) <= filterRadius^2);
maxOrder = sum(filtDomain(:));

% Execute maximum filtration
maxImg = ordfilt2(inputFrame,maxOrder,filtDomain);

% Execute Guassian-blurring
maxBlurAvgFrame = imgaussfilt(maxImg,filterRadius,'FilterDomain','spatial');