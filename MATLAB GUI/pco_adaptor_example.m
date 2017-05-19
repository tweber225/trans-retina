function images = pco_adaptor_example(triggermode,binningh,binningv,convf,exptime,pixelclk,imcount)
%record and extract images with imaq adaptor
%
%   [images] = pco_adaptor_example(triggermode,binningh,binningv,convf,exptime,pixelclk,imcount)
%
% * Input parameters :
%       triggermode        trigger mode to be set ('immediate' or 'manual')
%       binningh           horizontal binning
%       binningv           vertical binning
%       convf              conversion factor
%       exptime            exposure time in us
%       pixelclk           pixelclock
%       imcount            number of images to acquire
%
% * Output parameters :
%       images             stack with acquired images
%
%display information about the adaptor and connected devices
%get available properties and their possible values
%set property values and trigger mode
%start preview, acquire images, stop preview
%display single image
%readout the acquired images and reset the adaptor
%

if(~exist('triggermode','var'))
    triggermode = 'immediate';
end

if(~exist('binningh','var'))
    binningh = '1';
end

if(~exist('binningv','var'))
    binningv = '1';
end

if(~exist('convf','var'))
    convf = 0;
end

if(~exist('exptime','var'))
    exptime = 5000;
end

if(~exist('pixelclk','var'))
    pixelclk = 0;
end

if(~exist('imcount','var'))
    imcount = 10;
end

%Get information about installed adaptors
imaqhwinfo

%Get information about the PCOCameraAdaptor
imaqhwinfo('pcocameraadaptor')

%Get information about the first device of the adaptor
imaqhwinfo('pcocameraadaptor',0)

%Create video input object
vid = videoinput('pcocameraadaptor', 0);

%Create adaptor source
src = getselectedsource(vid);

%% Genaral properties
%Get current settings
get(vid)

%Show properties set options
set(vid)

%Set logging to memory
vid.LoggingMode = 'memory';

%Set trigger mode
triggerconfig(vid, triggermode);

%Set frames per trigger
vid.FramesPerTrigger = imcount;

%% Device properties
%Get current settings
get(src)

%Show properties set options
set(src)

%Set horizontal binnig
src.B1BinningHorizontal = binningh;

%Set vertical binning
src.B2BinningVertical = binningv;

%Set conversion factor if specified
if convf ~= 0
src.CFConversionFactor_e_count = convf;
end

%Set Delay time unit
src.D1DelayTime_unit = 'us';

%Set Exposure time unit
src.E1ExposureTime_unit = 'us';

%Set exposure time
src.E2ExposureTime = exptime;

%Set Pixelclock if specified
if pixelclk ~=0
src.PCPixelclock_Hz = pixelclk;
end

%Set timestamp mode
src.TMTimestampMode = 'BinaryAndAscii';

%% Image acquisition
%Start preview
%preview(vid);

%Stop preview
%stoppreview(vid);

%Start acquisition
start(vid);

if strcmp(triggermode,'manual')
%Force trigger command
trigger(vid);
end

%% Extract data
% Get single image
simage = getsnapshot(vid);
imshow(simage);

%Read out all images and remove them from memory buffer
images = getdata(vid);

%% Reset adaptor
imaqreset;