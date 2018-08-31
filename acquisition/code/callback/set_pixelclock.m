function actualPixelclock = set_pixelclock(camHandle,targetPixelclock)
% Sets pixel clock (in MHz), returns actual pixel clock

% Make sure target is in range
[~,minPixelclock,maxPixelclock,~] = camHandle.Timing.PixelClock.GetRange;
if targetPixelclock < minPixelclock
    targetPixelclock = minPixelclock;
elseif targetPixelclock > maxPixelclock
    targetPixelclock = maxPixelclock;
end

camHandle.Timing.PixelClock.Set(targetPixelclock);
[~,actualPixelclock] = camHandle.Timing.PixelClock.Get;