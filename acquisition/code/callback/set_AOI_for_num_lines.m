function actualNumberLines = set_AOI_for_num_lines(camHandle,numberLines,sensorXPixels,sensorYPixels)

% Verify whether valid number of pixels
if numberLines < 4
    numberLines = 4;
elseif numberLines > sensorYPixels
    numberLines = sensorYPixels;
end

xPos = 0;
yPos = 2*floor((sensorYPixels - numberLines)/2);
width = sensorXPixels;
height = 2*ceil(numberLines/2);
camHandle.Size.AOI.Set(xPos,yPos,width,height);

[~,~,~,~,actualNumberLines] = camHandle.Size.AOI.Get;

% Redo memory allocation 