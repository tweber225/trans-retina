function [actualBitDepth,actualPixelEncoding] = set_preamp_bitdepth_encoding(camHandle,targetPreAmp)

% Use the SDK's simple pre amp gain control feature wrapper to set bit
% depth and gain
rc = AT_SetEnumString(camHandle,'SimplePreAmpGainControl',targetPreAmp);
AT_CheckWarning(rc);

% Set pixel encoding based on pre-amp setting
switch targetPreAmp
    case '12-bit (high well capacity)'
        targetBitDepth = 12;
        targetPixelEncoding = 'Mono12Packed';
    case '12-bit (low noise)'
        targetBitDepth = 12;
        targetPixelEncoding = 'Mono12Packed';
    case '16-bit (low noise & high well capacity)'
        targetBitDepth = 16;
        targetPixelEncoding = 'Mono16';
end
rc = AT_SetEnumString(camHandle,'PixelEncoding',targetPixelEncoding);
AT_CheckWarning(rc);

% Report set bitdepths, this is valid if no warnings appear!
actualBitDepth = targetBitDepth; % We use this number routinely elsewhere for display levels
actualPixelEncoding = targetPixelEncoding;


