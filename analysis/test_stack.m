I = imread('cameraman.tif');

unregStack = zeros(256,256,1024);
rotDeg = zeros(1024,1);
frameIdx = 1;

for degIdx = linspace(0,360,1024)
    rotDeg(frameIdx) = degIdx+randn;
    unregStack(:,:,frameIdx) = imrotate(I,rotDeg(frameIdx),'crop','bilinear');
    frameIdx = frameIdx+1;
end

% show these images in a movie
figure;
for frameIdx = 1:1024
    imagesc(unregStack(:,:,frameIdx));
    title(num2str(rotDeg(frameIdx)));
    drawnow;
    pause(.04);
    
end

