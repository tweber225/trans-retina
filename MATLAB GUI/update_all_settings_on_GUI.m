function handles = update_all_settings_on_GUI(handles)
% Function sets all the GUI settings to those listed in handles.settingStruct

% PREVIEW SETTINGS
set(handles.prevExpTime,'String',handles.settingsStruct.prevExpTime);
set(handles.prevBinSize,'Value',handles.settingsStruct.prevBinSize);
set(handles.prevPixClock,'Value',handles.settingsStruct.prevPixClock);
set(handles.prevGain,'Value',handles.settingsStruct.prevGain);

% CAPTURE SETTINGS
set(handles.capExpTime,'String',handles.settingsStruct.capExpTime);
set(handles.capBinSize,'Value',handles.settingsStruct.capBinSize);
set(handles.capPixClock,'Value',handles.settingsStruct.capPixClock);
set(handles.capGain,'Value',handles.settingsStruct.capGain);
set(handles.capNumFrames,'String',handles.settingsStruct.capNumFrames);
set(handles.capLockSettings,'Value',handles.settingsStruct.capLockSettings);

% COMMON SETTINGS
set(handles.commIRMode,'Value',handles.settingsStruct.commIRMode);
set(handles.commAutoScale,'Value',handles.settingsStruct.commAutoScale);
set(handles.commXShift,'String',handles.settingsStruct.commXShift);
set(handles.commRTStats,'Value',handles.settingsStruct.commRTStats);
set(handles.commRTHistogram,'Value',handles.settingsStruct.commRTHistogram);
set(handles.commStatHistInCenter,'Value',handles.settingsStruct.commStatHistInCenter);

% SELECT LEDS SETTINGS
set(handles.selectLEDsEnable1,'Value',handles.settingsStruct.prevLEDsEnable1);
set(handles.selectLEDsEnable2,'Value',handles.settingsStruct.prevLEDsEnable2);
set(handles.selectLEDsEnable3,'Value',handles.settingsStruct.prevLEDsEnable3);
set(handles.selectLEDsEnable4,'Value',handles.settingsStruct.prevLEDsEnable4);
set(handles.capLEDsEnable1,'Value',handles.settingsStruct.capLEDsEnable1);
set(handles.capLEDsEnable2,'Value',handles.settingsStruct.capLEDsEnable2);
set(handles.capLEDsEnable3,'Value',handles.settingsStruct.capLEDsEnable3);
set(handles.capLEDsEnable4,'Value',handles.settingsStruct.capLEDsEnable4);
showLEDString = {['1: ' handles.settingsStruct.constLED1CenterWavelength]; ['2: ' handles.settingsStruct.constLED2CenterWavelength]; ['3: ' handles.settingsStruct.constLED3CenterWavelength]; ['4: ' handles.settingsStruct.constLED4CenterWavelength]};
set(handles.selectLEDsShow,'String',showLEDString);
set(handles.selectLEDsShow,'Value',handles.settingsStruct.selectLEDsShow);
set(handles.selectLEDsLabel1,'String',['LED1:' handles.settingsStruct.constLED1CenterWavelength]);
set(handles.selectLEDsLabel2,'String',['LED2:' handles.settingsStruct.constLED2CenterWavelength]);
set(handles.selectLEDsLabel3,'String',['LED3:' handles.settingsStruct.constLED3CenterWavelength]);
set(handles.selectLEDsLabel4,'String',['LED4:' handles.settingsStruct.constLED4CenterWavelength]);
% A few checks on the initial parameters
if handles.LEDsToEnable(handles.settingsStruct.selectLEDsShow) == 0 %if the requested LED to show on big axis is not enabled, then switch it
    if handles.LEDsToEnable(1) == 1
        set(handles.selectLEDsShow,'Value',1);
        handles.settingsStruct.selectLEDsShow = 1;
    elseif handles.LEDsToEnable(2) == 1
        set(handles.selectLEDsShow,'Value',2);
        handles.settingsStruct.selectLEDsShow = 2;
    elseif handles.LEDsToEnable(3) == 1
        set(handles.selectLEDsShow,'Value',3);
        handles.settingsStruct.selectLEDsShow = 3;
    elseif handles.LEDsToEnable(4) == 1
        set(handles.selectLEDsShow,'Value',4);
        handles.settingsStruct.selectLEDsShow = 4;
    end
end
if sum(handles.LEDsToEnable,2) == 0
    set(handles.selectLEDsShow,'Value',1)
    set(handles.selectLEDsEnable1,'Value',1);
    handles.LEDsToEnable(1) = 1;
    handles.settingsStruct.selectLEDsEnable1 = 1;
end
set(handles.selectLEDsLockCap,'Value',handles.settingsStruct.selectLEDsLockCap);

% SAVE SETTINGS
set(handles.saveBaseName,'String',handles.settingsStruct.saveBaseName);
set(handles.saveSettings,'Value',handles.settingsStruct.saveSettings);
set(handles.saveFrameTimes,'Value',handles.settingsStruct.saveFrameTimes);

% INDICATORS
set(handles.LEDQuad1StatsIndicator,'String',['LED 1: ' handles.settingsStruct.constLED1CenterWavelength ', Min: ------, Max: ------, % Sat: ------']);
set(handles.LEDQuad2StatsIndicator,'String',['LED 2: ' handles.settingsStruct.constLED2CenterWavelength ', Min: ------, Max: ------, % Sat: ------']);
set(handles.LEDQuad3StatsIndicator,'String',['LED 3: ' handles.settingsStruct.constLED3CenterWavelength ', Min: ------, Max: ------, % Sat: ------']);
set(handles.LEDQuad4StatsIndicator,'String',['LED 4: ' handles.settingsStruct.constLED4CenterWavelength ', Min: ------, Max: ------, % Sat: ------']);
if handles.settingsStruct.selectLEDsQuadViewOn == 0
    allLEDChoices = {handles.settingsStruct.constLED1CenterWavelength handles.settingsStruct.constLED2CenterWavelength handles.settingsStruct.constLED3CenterWavelength handles.settingsStruct.constLED4CenterWavelength};
    requestedLEDChoices = allLEDChoices(logical(handles.LEDsToEnable));
    if sum(handles.LEDsToEnable,2) == 2
        set(handles.LED1ColorIndicator,'String',['LED 1: ' requestedLEDChoices{1}]);
        set(handles.LED2ColorIndicator,'String',['LED 2: ' requestedLEDChoices{2}]);
    end
    if sum(handles.LEDsToEnable,2) == 1
        set(handles.LED1ColorIndicator,'String',['LED 1: ' requestedLEDChoices{1}]);
    end
end
