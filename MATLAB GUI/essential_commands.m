% Necessary from "pco_adaptor_example.m"

%Create video input object
vid = videoinput('pcocameraadaptor', 0);

%Create adaptor source
src = getselectedsource(vid);

%Set logging to memory
vid.LoggingMode = 'memory';



%Set binning
src.B1BinningHorizontal = 1;
src.B2BinningVertical = 1;

%gain
src.CFConversionFactor_e_count = 1.00;

% exposure time unit - just keep as microseconds
src.E1ExposureTime_unit = 'ms';

%Set exposure time
src.E2ExposureTime = 100;

%Set Pixelclock 
src.PCPixelclock_Hz = 12e6;
