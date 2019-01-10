function settingsOut = load_settings(capturePath)

% open the file
fid = fopen(fullfile(capturePath,'settings.txt'));

% scan first two columns, second column gives the data type
A = textscan(fid,'%s %s %*[^\n]');
fieldNames = A{1};
dataTypes = A{2};

% now reopen file to go back to beginning
fid = fopen(fullfile(capturePath,'settings.txt'));

% Loop through each entry
for fieldIdx = 1:numel(fieldNames)
    switch dataTypes{fieldIdx}
        case 'char'
            fieldFormat = '%*s %*s %[^\n]';
            singleSettingData = textscan(fid,fieldFormat,1);
            settingsData{fieldIdx} = singleSettingData{1}{1}(1:(end-1));
        case 'int32'
            fieldFormat = '%*s %*s %d%*[^\n]';
            singleSettingData = textscan(fid,fieldFormat,1);
            settingsData{fieldIdx} = singleSettingData{1};
        case 'double'
            fieldFormat = '%*s %*s %f%*[^\n]';
            singleSettingData = textscan(fid,fieldFormat,1);
            settingsData{fieldIdx} = singleSettingData{1};
        case 'doubleArray'
            fieldFormat = '%*s %*s %[^\n]';
            singleSettingData = textscan(fid,fieldFormat,1);
            arrayData = singleSettingData{1}{1}(2:(end-2));
            settingsData{fieldIdx} = str2num(arrayData);
    end
end

% Make structure to output
settingsOut = cell2struct(settingsData',fieldNames);