function [xCenter,yCenter,rad,pointsX,pointsY] = label_fovea(fundusImg)

imshow(norm_contrast(fundusImg))
[x,y] = getpts;

% average to find the center
xCenter = mean(x);
yCenter = mean(y);

rad = mean(sqrt((x-xCenter).^2 + (y-yCenter).^2));

pointsX = xCenter + rad*cos(linspace(0,2*pi,36));
pointsY = yCenter + rad*sin(linspace(0,2*pi,36));

close