function [fitresult, xData, yData, gof] = fit_linear_and_circle(x, I)
% Creates a fit of the I = f(x) data to a linear function (mx+b) and a
% circular cross-section vessel causing light extinction. Specifically the equation:
%
%     I       =    (m*x + b)      *   exp(-(a/r)*2*sqrt(r^2 - (x-x0)^2))
% [image data]  [inhomog. illum.]       [vessel extinction]
% 
% quantity sqrt(r^2 - (x-x0)^2), call L for pathlength, is limitied to >= 0
% parameter a equals extinction coefficient

% Find number of points in cross section
numPoints = numel(x);

% Define constraints
mMin = -Inf; % No limit on the slope, but should be small, couple hundred possibly
mMax = Inf;
bMin = 0; % Signals are positive-only light intensities
bMax = 2^16; % Max is the max level of 16 bit images
aMin = 0; % Vessel can't have negative extinction (ie light emission)
aMax = Inf;
rMin = 1; % tracking vessels of radisu > 1 pixels
rMax = numPoints/2; % can't have radius larger than half the cross section
x0Min = -numPoints/8; % center must be in the center quarter of the cross section
x0Max = numPoints/8;

% Define starting guess
mGuess = 0;
bGuess = mean(I); % average of the cross section data
aGuess = 0.1;
rGuess = 5;
x0Guess = 0;

%% Fitting
[xData, yData] = prepareCurveData( x, I );

% Set up fittype and options.
ft = fittype( '(m*x + b)*exp(-(a/r)*2*upper_semicircle(x,r,x0))', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [aMin bMin mMin rMin x0Min];
opts.StartPoint = [aGuess bGuess mGuess rGuess x0Guess];
opts.Upper = [aMax bMax mMax rMax x0Max];

% Run the fit
[fitresult, gof] = fit( xData, yData, ft, opts );


