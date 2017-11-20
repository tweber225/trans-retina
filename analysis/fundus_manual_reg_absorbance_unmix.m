
% If enabled, do manual registration
% Also if enabled, do manual control point selection

% Select particular filter kernels absorbance images to use (rather than
% the whole stack)

% Loop through this registering to 850nm LED
[selectedMovingPoints,selectedFixedPoints] = cpselect(movingFrame,fixedFrame,'Wait',true);

% optional: cpcorr (to fine tune, or not to fine tune)

% various estimations of the geometric transform


% review options and select the best fit for each channel

% For each channel, loop through different options

% Make selection, or loop through again?
