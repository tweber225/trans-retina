# trans-retina

Tim Weber

BU Biomicroscopy Lab

May 2017



MATLAB code to run camera in sync with alternating LEDs (up to 4) for trans-scleral retina imaging. 
In the directory: "cam_exposure_LED_sync" is a Arduino sketch file that should syncronize exposure signals and the LED outputs

In the future repo may include some analysis code.



Features to add to GUI:

-manual black/white level settings

-separate enable buttons for capture mode set of LEDs (ie different LEDs for Preview and Capture Modes)

-limit on number of frames for capture mode (to avoid over allocating memory, otherwise we need to do some quick calculations before starting with knowledge of the available memory, 4 channels, full res >4.3GB)

-predicted acquisition duration time
