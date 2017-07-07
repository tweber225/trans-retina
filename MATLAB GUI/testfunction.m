


% --- Executes on button press in commRTHistogram.
function commRTHistogram_Callback(hObject, eventdata, handles)
% Get the new state of RT (=Real-time) Histogram setting
handles.settingsStruct.commRTHistogram = get(handles.commRTHistogram,'Value');
if handles.settingsStruct.commRTHistogram == 1 % If it is now on, check whether...
    %... we are in quad mode
    if handles.settingsStruct.selectLEDsQuadViewOn == 1
        % then we need to show all the quad view histogram axes that are
        % required
        if handles.LEDsToEnable(1) == 1
            handles.histHandLEDQuad1.Visible = 'on';
            handles.LEDQuad1Hist.Visible = 'on';
        end
        if handles.LEDsToEnable(2) == 1
            handles.histHandLEDQuad2.Visible = 'on';
            handles.LEDQuad2Hist.Visible = 'on';
        end
        if handles.LEDsToEnable(3) == 1
            handles.histHandLEDQuad3.Visible = 'on';
            handles.LEDQuad3Hist.Visible = 'on';
        end
        if handles.LEDsToEnable(4) == 1
            handles.histHandLEDQuad4.Visible = 'on';
            handles.LEDQuad4Hist.Visible = 'on';
        end
    else %otherwise we're not in quad view
        handles.histHandLED1.Visible = 'on';
        handles.LED1Hist.Visible = 'on';
        if sum(handles.LEDsToEnable,2) == 2
            handles.histHandLED2.Visible = 'on';
            handles.LED2Hist.Visible = 'on';
        end
    end
else % Otherwise, we just un-checked RT Histograms, so hide all hist axes
    handles.histHandLEDQuad1.Visible = 'off';
    handles.LEDQuad1Hist.Visible = 'off';
    handles.histHandLEDQuad2.Visible = 'off';
    handles.LEDQuad2Hist.Visible = 'off';
    handles.histHandLEDQuad3.Visible = 'off';
    handles.LEDQuad3Hist.Visible = 'off';
    handles.histHandLEDQuad4.Visible = 'off';
    handles.LEDQuad4Hist.Visible = 'off';
    handles.histHandLED1.Visible = 'off';
    handles.LED1Hist.Visible = 'off';
    handles.histHandLED1.Visible = 'off';
    handles.LEDd1Hist.Visible = 'off';
end
guidata(hObject, handles);