function save_vessel_network(segments,filePathName)
% Function to take in a structure of vessel segments (ie "segments") that
% is of length N (N the number of segments in the network) and with fields
% "ID" (segment hierarchy code), "xPoints" and "yPoints" coordinates of the
% vessel path. Saves each segment to its own line of a text file

% Get total number of segments
numSegments = numel(segments);

% Open/create file to save vessel network data
fileID = fopen(filePathName,'w');

% Loop through all the vessel segments append data to new lines
for segmentIdx = 1:numSegments
    % Print the ID code
    IDString = segments(segmentIdx).ID;
    fprintf(fileID,'%s ',IDString);
    
    % Print coordinates for each point
    numPoints = numel(segments(segmentIdx).xPoints);
    for pointIdx = 1:numPoints
        xPoint = num2str(segments(segmentIdx).xPoints(pointIdx));
        yPoint = num2str(segments(segmentIdx).yPoints(pointIdx));
        coordinateString = ['(' xPoint ',' yPoint ')'];
        fprintf(fileID,'%s;',coordinateString);
    end
    
    % When finished with segment data, add a new line
    fprintf(fileID,'\n');
    
end

fclose(fileID);

