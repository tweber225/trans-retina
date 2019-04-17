function normImg = norm_contrast(img,varargin)

if numel(varargin) == 0
    % Find min and max of image
    imgHigh = max(img(:)); 
    imgLow = min(img(:));
else
    % Then use image quantiles
    quantsHighLow = quantile(img(:),varargin{:});
    imgHigh = quantsHighLow(1);
    imgLow = quantsHighLow(2);
end
    

% Find range for image
imgRange = imgHigh-imgLow;

% Finally, normalize the image from 0 to 1
normImg = (img-imgLow)/imgRange;
