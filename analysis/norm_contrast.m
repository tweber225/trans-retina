function normImg = norm_contrast(img)

% Find min and max of image
imgMax = max(img(:)); 
imgMin = min(img(:));

% Find range for image
imgRange = imgMax-imgMin;

% Finally, normalize the image from 0 to 1
normImg = (img-imgMin)/imgRange;
