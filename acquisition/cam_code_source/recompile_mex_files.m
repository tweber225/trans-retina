
includeDir = '-IC:\Program Files\Thorlabs\Scientific Imaging\DCx Camera Support\Develop\Include';
libDir = '-LC:\Program Files\Thorlabs\Scientific Imaging\DCx Camera Support\Develop\Lib';
libFile = '-luc480_64';

% Essential camera initialization, closing, parameter-setting functions
mex('-v','open_init_DCx_cam.cpp',includeDir,libDir,libFile);
mex('-v','close_DCx_cam.cpp',includeDir,libDir,libFile);
mex('-v','set_pix_clk_DCx_cam.cpp',includeDir,libDir,libFile);
mex('-v','set_frame_rate_DCx_cam.cpp',includeDir,libDir,libFile);
mex('-v','set_exp_time_DCx_cam.cpp',includeDir,libDir,libFile);
mex('-v','set_master_gain_DCx_cam.cpp',includeDir,libDir,libFile);
mex('-v','set_gain_boost_DCx_cam.cpp',includeDir,libDir,libFile);
mex('-v','set_ext_trig_DCx_cam.cpp',includeDir,libDir,libFile);
mex('-v','set_black_DCx_cam.cpp',includeDir,libDir,libFile);
mex('-v','set_shutter_mode_DCx_cam.cpp',includeDir,libDir,libFile);
mex('-v','set_flash_output_DCx_cam.cpp',includeDir,libDir,libFile);
mex('-v','set_binning_DCx_cam.cpp',includeDir,libDir,libFile);
mex('-v','set_binning_DCx_cam.cpp',includeDir,libDir,libFile);
mex('-v','set_hotpixel_mode_DCx_cam.cpp',includeDir,libDir,libFile);


% Allocating and taking single image
mex('-v','allocate_single_img_DCx_cam.cpp',includeDir,libDir,libFile);
mex('-v','deallocate_single_img_DCx_cam.cpp',includeDir,libDir,libFile);
mex('-v','read_single_img_DCx_cam.cpp',includeDir,libDir,libFile);
mex('-v','snap_single_img_DCx_cam.cpp',includeDir,libDir,libFile);

% Test various things
mex('-v','test_function.cpp',includeDir,libDir,libFile);
