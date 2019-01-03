function [actualNumCols,actualNumRows] = set_AOI_for_num_cols_rows(handles,requestedNumCols,requestedNumRows)

% Verify whether requested columns and rows is valid number
% Number rows and lines must be even (requirement of my GUI rather than
% the camera)
requestedNumCols = 2*round(requestedNumCols/2);
requestedNumRows = 2*round(requestedNumRows/2);

% Make sure neither the number of cols or rows exceeds min/max
if requestedNumCols < handles.settings.minWidth 
    requestedNumCols = handles.settings.minWidth;
elseif requestedNumCols > handles.settings.sensorWidth
    requestedNumCols = handles.settings.sensorWidth;
end
if requestedNumRows < handles.settings.minHeight 
    requestedNumRows = handles.settings.minHeight;
elseif requestedNumRows > handles.settings.sensorHeight;
    requestedNumRows = handles.settings.sensorHeight;
end

% Compute AOI x start location (y is automatically set)
xPos = handles.settings.sensorWidth/2 - requestedNumCols/2 +1;

% Set AOI
rc = AT_SetInt(handles.camHandle,'AOIWidth',requestedNumCols);
AT_CheckWarning(rc);
rc = AT_SetInt(handles.camHandle,'AOILeft',xPos);
AT_CheckWarning(rc);
rc = AT_SetInt(handles.camHandle,'AOIHeight',requestedNumRows);
AT_CheckWarning(rc);
rc = AT_SetBool(handles.camHandle,'VerticallyCentreAOI',1); % should automatically set y position
AT_CheckWarning(rc);

% Get AOI positions
[rc,actualNumCols] = AT_GetInt(handles.camHandle,'AOIWidth');
AT_CheckWarning(rc);
[rc,actualNumRows] = AT_GetInt(handles.camHandle,'AOIHeight');
AT_CheckWarning(rc);

% Redo memory allocation 