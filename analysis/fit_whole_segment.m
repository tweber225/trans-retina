function [fitresult, xData, yData, zData, gof] = fit_whole_segment(z, x, I)
% Creates a fit of the I = f(z,x) data to the product of a polynomial
% function and an extruded circular cross-section vessel causing light
% extinction. z is the axial distance along the vessel segment, x is the
% cross section dimension. Specifically, fit the equation:
%
%     I    =   (a + b*z + c*z^2 + d*z^3 + e*x)  *  exp(-u*2*sqrt(r^2 - (x-x0)^2))
% [image data]     [inhomogeneous illum.]               [vessel extinction]
% 
% - the quantity sqrt(r^2 - x^2), call this: L for pathlength, is
% limitied to >= 0 parameter a equals extinction coefficient.
%

% Find number of points in cross section
numCrossSectionPoints = numel(x);

% Define constraints
aMin = 0; % Signals are positive-only light intensities
aMax = 2^16; % Max is the max level of 16 bit images
bMin = -Inf; % 1st order axial term
bMax = Inf;
cMin = -Inf; % 2nd order axial term
cMax = Inf;
dMin = -Inf; % 3rd order axial term
dMax = Inf;
eMin = -Inf; % 1st order axial term
eMax = Inf;

uMin = 0; % Can't have negative absorption
uMax = Inf;

rMin = 1; % tracking vessels of radius > 1 pixels
rMax = numCrossSectionPoints/2; % can't have radius larger than half the cross section

y0Min = -1.5;
y0Max = 1.5;

% Define starting guess
aGuess = 0; % average of the cross section data
bGuess = 0;
cGuess = 0;
dGuess = 0;
eGuess = 0;
uGuess = 0.01;
rGuess = 1;
y0Guess = 0;

%% Fitting
[xData, yData, zData] = prepareSurfaceData( z, x, I ); % Careful here as we swap axes x,y,z

% Set up fittype and options.
ft = fittype( '(a + b*x + c*x^2 + d*x^3 + e*y)*exp(-u*2*upper_semicircle(y,r,y0))', 'independent', {'x', 'y'}, 'dependent', 'z' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Robust = 'Bisquare';
opts.Lower = [aMin bMin cMin dMin eMin rMin uMin y0Min];
opts.StartPoint = [aGuess bGuess cGuess dGuess eGuess rGuess uGuess y0Guess];
opts.Upper = [aMax bMax cMax dMax eMax rMax uMax y0Max];

% Run the fit
[fitresult, gof] = fit( [xData, yData], zData, ft, opts );


