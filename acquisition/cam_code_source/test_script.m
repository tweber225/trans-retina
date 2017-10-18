

bitDepth = 10;

camHandle = open_init_DCx_cam(bitDepth);

actualPixClk = set_pix_clk_DCx_cam(camHandle,41);

actualFrameRate = set_frame_rate_DCx_cam(camHandle,30);

actualExpTime = set_exp_time_DCx_cam(camHandle,20);

actualMasterGain = set_master_gain_DCx_cam(camHandle,1);
set_gain_boost_DCx_cam(camHandle,0);

actualBlackLevel = set_black_DCx_cam(camHandle,255); % something arbitrary here

set_ext_trig_DCx_cam(camHandle,1);

set_shutter_mode_DCx_cam(camHandle,2); % 2=global start, 1=rolling

[flashDelay, flashDuration] = set_flash_output_DCx_cam(camHandle, 0, actualExpTime);

set_binning_DCx_cam(camHandle,1);
set_hotpixel_mode_DCx_cam(camHandle,1);


% Make an image memory and pass pointer to it
[pImgMem, imgId] = allocate_single_img_DCx_cam(camHandle,1024,1280,16);
tic;
prevToc = toc;
for idx = 1:100
    snap_single_img_DCx_cam(camHandle);
    I = bitshift(read_single_img_DCx_cam(camHandle, pImgMem, imgId)',-2);
    imagesc(I);
    tocNow = toc;
    disp(1/(tocNow-prevToc));
    prevToc = tocNow;
end

deallocate_single_img_DCx_cam(camHandle, pImgMem, imgId);

close_DCx_cam(camHandle);

imagesc(I);