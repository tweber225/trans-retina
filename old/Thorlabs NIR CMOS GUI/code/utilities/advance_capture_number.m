function handles = advance_capture_number(handles)
% advances the capture number and capture folder name until reaching one
% that does not exist
folderFound = 0;
while folderFound == 0
    captureFolderName = [handles.settings.fileBaseName '_capture' num2str(handles.settings.captureNumber,'%03d')]; %ie subject001_capture001
    handles.settings.capturePath = [handles.settings.fullPathName filesep captureFolderName];    
    if exist(handles.settings.capturePath,'dir') == 7
        handles.settings.captureNumber = handles.settings.captureNumber+1;
    else
        folderFound = 1; % exit loop with settings.capturePath and settings.captureNumber set
    end
end
set(handles.uiDisplayCaptureNumber,'String',num2str(handles.settings.captureNumber,'%03d'));