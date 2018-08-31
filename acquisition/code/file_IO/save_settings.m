function handles = save_settings(handles)
set(handles.uiButtonCapture,'String','Saving Settings');drawnow


fieldNamesArray = fieldnames(handles.settings);
settingValuesArray = struct2cell(handles.settings);

settingsFilename = 'settings.txt';

fileID = fopen([handles.settings.capturePath filesep settingsFilename],'a');

for settingIdx = 1:numel(fieldNamesArray)
    switch class(settingValuesArray{settingIdx})
        case 'char'
            fprintf(fileID,'%s char %s\r\n',fieldNamesArray{settingIdx},settingValuesArray{settingIdx});
        case 'int32'
            fprintf(fileID,'%s int32 %d\r\n',fieldNamesArray{settingIdx},settingValuesArray{settingIdx});
        case 'double'
            % couple special cases
            if numel(settingValuesArray{settingIdx}) > 1 % if the setting is an array, convert to string
                fprintf(fileID,'%s doubleArray %s\r\n',fieldNamesArray{settingIdx},mat2str(settingValuesArray{settingIdx}));
            elseif settingValuesArray{settingIdx} == round(settingValuesArray{settingIdx}) % if it's an integer but double type, skip the sci notation
                fprintf(fileID,'%s double %d\r\n',fieldNamesArray{settingIdx},settingValuesArray{settingIdx});
            else
                fprintf(fileID,'%s double %.10e\r\n',fieldNamesArray{settingIdx},settingValuesArray{settingIdx});
            end
    end
end

fclose(fileID);
