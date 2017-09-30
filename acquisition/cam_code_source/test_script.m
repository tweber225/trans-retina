

bitDepth = 10;

camHandle = open_init_DCx_cam(bitDepth);

actualPixClk = set_pix_clk_DCx_cam(camHandle,41);

actualFrameRate = set_frame_rate_DCx_cam(camHandle,10);

actualExpTime = set_exp_time_DCx_cam(camHandle,16.6);

actualMasterGain = set_master_gain_DCx_cam(camHandle,1);
set_gain_boost_DCx_cam(camHandle,0);

actualBlackLevel = set_black_DCx_cam(camHandle,10); % something arbitrary here

set_ext_trig_DCx_cam(camHandle,1);

set_shutter_mode_DCx_cam(camHandle,2); % 2=global start, 1=rolling

[flashDelay, flashDuration] = set_flash_output_DCx_cam(camHandle, 0, actualExpTime);


close_DCx_cam(camHandle);