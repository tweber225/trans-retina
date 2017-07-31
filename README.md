# trans-retina

Tim Weber

BU Biomicroscopy Lab

Started: May 2017

Version 1: June 2017 (2 colors)

Version 2: July 2017 (1-4 colors+more features)


MATLAB code to run camera in sync with alternating LEDs (up to 4) for trans-scleral retina imaging. 
In the directory: "cam_exposure_LED_sync" is a Arduino sketch file that should syncronize exposure signals and the LED outputs.

In the future repo may include some analysis code.

MATLAB GUI (multicolor_imaging_GUI.m) hot keys:

p = Start/stop preview

c = Start/abort capture

1,2,3,4 = Toggle preview mode LED channels 1-4

shift+1,2,3,4 = Toggle capture mode LED channels 1-4

numpad keys = Type in preview mode exposure time (then hit enter)

tap shift+numpad keys = Type in capture mode exposure time (then hit enter)

right/left arrow = Increment/decrement preview mode exposure time

shift+right/left arrow = Increment/decrement capture mode exposure time

a = Autoscale gray levels in image axes

r = Reset gray levels to full range (0 to 2^cam bits - 1) in image axes

l = Lock capture mode LED choices to preview mode's choices

s = Lock capture mode camera settings to preview mode's settings

tap n+alphabet & number keys = change the file base name (then hit enter)

h = Toggle realtime histograms

m = Toggle realtime image statistics

f = Toggle realtime image flattening (on Preview Mode and the first LED channel only)




Features to add to GUI:

-Low priority: limit on number of frames for capture mode (to avoid over allocating memory)
