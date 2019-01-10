% read in dataset
%I = double(imread('cameraman.tif'));
%I = repmat(I,[4 4 32]);
%I = phantom(256);
I = randn([512 512 1]);
%I(1,:) = 10;
%I = imrotate(padarray(I,[64 64],0,'both'),-20,'bilinear','crop');
%I = I';

%figure;imagesc(fftshift(log(abs(fft2(I)))))

tic;
fastPol = polar_fft2(I,5,20,20*8,5);
toc;

tic;
slowPol = direct_polar_dft(I,5,20,20*8);
toc;
imagesc([abs(fastPol) (abs(fastPol-slowPol)) abs(slowPol)])
% 
% figure;imagesc(fftshift(abs(fft((fastPol).*conj(fastPol),[length(fastPol*1)],2)),2),[0 8e3]);colorbar
% figure;imagesc(fftshift(abs(fft((slowPol).*conj(slowPol),[length(fastPol*1)],2)),2),[0 8e3]);colorbar


% Report difference
disp(sum(abs(fastPol(:)-slowPol(:)))/sum(abs(slowPol(:))))

%%
for rotIdx = -40:40
    
    Irot = imrotate(padarray(I,[64 64],0,'both'),rotIdx,'bilinear','crop');
    
    subplot(1,2,1)
    imagesc(abs(polar_fft2(Irot,10,50,180,4)));drawnow;
    subplot(1,2,2)
    imagesc((abs(fftshift(fft2(Irot)))));drawnow
    
end





