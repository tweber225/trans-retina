I = imread('cameraman.tif');

unregStack = zeros(256,256,1024);
rotDeg = zeros(1024,1);
frameIdx = 1;

for degIdx = linspace(0,360,1024)
    rotDeg(frameIdx) = degIdx+0.2*randn;
    unregStack(:,:,frameIdx) = imrotate(I,rotDeg(frameIdx),'crop','bilinear');
    frameIdx = frameIdx+1;
end
rotDeg(1) = 0;
unregStack(:,:,1) = I;

% show these images in a movie
figure;
for frameIdx = 1:1024
    imagesc(unregStack(39:218,39:218,frameIdx));
    title(num2str(rotDeg(frameIdx)));
    drawnow;
    pause(0);
    
end

