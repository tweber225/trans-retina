function actualBitdepth = set_bitdepth(camHandle,targetBitDepth)

if targetBitDepth == 8
    camHandle.PixelFormat.Set(uEye.Defines.ColorMode.Mono8);
else
    camHandle.PixelFormat.Set(uEye.Defines.ColorMode.Mono10);
end

[~,iDSPixelFormat] = camHandle.PixelFormat.Get;
if iDSPixelFormat == uEye.Defines.ColorMode.Mono8
    actualBitdepth = 8;
elseif iDSPixelFormat == uEye.Defines.ColorMode.Mono10
    actualBitdepth = 10;
end

% to do: change up frame memories if necessary