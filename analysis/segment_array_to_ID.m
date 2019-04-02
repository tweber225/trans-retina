function segmentID = segment_array_to_ID(segmentArray)
% Function that takes a segment array (ie [2 9 10]) an converts to a
% string (ie '2-9-10') 

% Convert the doubles array to a string
rawString = num2str(segmentArray);

% Remove extra spaces and replace with a dash
segmentID =  regexprep(rawString,' +','-');

