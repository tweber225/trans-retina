function segments = load_vessel_network(filePathName)
% Function to load a text file containing path information for a vessel
% network. Each line is a different segment. See "save_vessel_network" for
% more information on the "segments" structure.

% Open the specified file
fileID = fopen(filePathName,'r');

% Scan each line
c = textscan(fileID,'%s %s\n');

% Count the number of segments
numSegments = numel(c{1});

% Loop through each segment
for segmentIdx = 1:numSegments
    % Note the ID
    segments(segmentIdx).ID = c{1}{segmentIdx};
    
    % Parse the point data and put into structure
    rawPointData = c{2}{segmentIdx};
    scannedPointData = sscanf(rawPointData,'(%f,%f);');
    scannedPointData = reshape(scannedPointData,[2 numel(scannedPointData)/2])';
    segments(segmentIdx).xPoints = scannedPointData(:,1);
    segments(segmentIdx).yPoints = scannedPointData(:,2);
    
end

% Close the file
fclose(fileID);
