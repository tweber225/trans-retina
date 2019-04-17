function segmentArray = segment_ID_to_array(segmentID)
% Function that takes a segment ID (ie string: '2-9-10') an converts to a
% doubles array (ie [2 9 10]) for easier numeric manipulation in MATLAB

% First replace dashes with spaces
segmentID = strrep(segmentID,'-',' ');

% Then split the string into an array
segmentArray = str2num(segmentID);