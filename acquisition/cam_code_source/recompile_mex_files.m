
includeDir = '-IC:\Program Files\Thorlabs\Scientific Imaging\DCx Camera Support\Develop\Include';
libDir = '-LC:\Program Files\Thorlabs\Scientific Imaging\DCx Camera Support\Develop\Lib';
libFile = '-luc480_64';

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
