function pointList = manual_segment_track(img)
% Function takes in an image and prompts user to manually track the center
% of a vessel. Outputs a Nx2 list (x and y coordinates) of user-selected
% points
scaleFactor = 5;
blurFactor = 10;

% First normalize the image contrast
imgMax = max(img(:));
imgMin = min(img(:));
imgRange = imgMax-imgMin;
normImg = (img-imgMin)/imgRange;

% Zoom into area of interest first
imshow(normImg)
[x,y] = getpts;
x = round(x);
y = round(y);
close

% Ask user how many pixels width to display
prompt = 'How many pixels width for the zoomed region? ';
zoomWidth = input(prompt);

% Crop the image to zoomed area
xMin = x-zoomWidth/2+1; xMax = x+zoomWidth/2;
yMin = y-zoomWidth/2+1; yMax = y+zoomWidth/2;
cropImg = normImg(yMin:yMax,xMin:xMax);

% Zoom image and flatten contrast for best visibilty
zoomedImg = imresize(cropImg,scaleFactor);
blurredImg = imgaussfilt(zoomedImg,scaleFactor*blurFactor);
flattenImg = zoomedImg./blurredImg;
imgMax = max(flattenImg(:));
imgMin = min(flattenImg(:));
imgRange = imgMax-imgMin;
flattenNormImg = (flattenImg-imgMin)/imgRange;

% Display the optimized zoomed image and get points
imshow(flattenNormImg)
[xi,yi] = getpts;
close


