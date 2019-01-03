function start_sensor_cooling(camHandle)

% Enable cooling
rc = AT_SetBool(camHandle,'SensorCooling',1);
AT_CheckWarning(rc);

% Not sure what the next part does (if anything), but manual consistently
% includes it
[rc,temperatureControlCount] = AT_GetEnumCount(camHandle,'TemperatureControl');
AT_CheckWarning(rc);
%rc = AT_SetEnumIndex(camHandle,'TemperatureControl',temperatureControlCount-1);
%AT_CheckWarning(rc);

% Cooling will automatically stabilize in a few seconds