function [imgXCenter,imgYCenter,imgRad,imgXPoints,imgYPoints] = label_image_edge(fundusImg)

backGroundLevel = 101;
cropFactor = 0.98;

binaryImg = (fundusImg > (backGroundLevel*1.25));

% Compute centroid of binarized image
imgXCenter = sum(sum(binaryImg,1).*(1:size(fundusImg,2)),2)/sum(sum(binaryImg,1));
imgYCenter = sum(sum(binaryImg,2).*(1:size(fundusImg,1))',1)/sum(sum(binaryImg,2));

% Compute area of binarized image and estimate radius
imgRad = sqrt(sum(binaryImg(:))/pi)*cropFactor;


imgXPoints = imgXCenter + imgRad*cos(linspace(0,2*pi,72));
imgYPoints = imgYCenter + imgRad*sin(linspace(0,2*pi,72));
