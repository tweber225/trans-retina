function [xCenter,yCenter,ODRad,ODPointsX,ODPointsY] = label_optic_disc(fundusImg)

imshow(norm_contrast(fundusImg))
[xOD,yOD] = getpts;

% average to find the center
xCenter = mean(xOD);
yCenter = mean(yOD);

ODRad = mean(sqrt((xOD-xCenter).^2 + (yOD-yCenter).^2));

ODPointsX = xCenter + ODRad*cos(linspace(0,2*pi,36));
ODPointsY = yCenter + ODRad*sin(linspace(0,2*pi,36));

close