function [fitresult, xData, yData, zData, gof] = fit_chunk(z, x, I)
% Creates a fit of the I = f(z,x) data to the product of a polynomial
% function and an extruded circular cross-section vessel causing light
% extinction. z is the axial distance along the vessel segment, x is the
% cross section dimension. Specifically, fit the equation:
%
%     I        =       1      *    exp(-u*2*sqrt(r^2 - (x-x0)^2))
% [image data] [homogeneous illum.]     [vessel extinction]
% 
% - the quantity sqrt(r^2 - x^2), call this: L for pathlength, is
% limitied to >= 0 parameter a equals extinction coefficient.
%

% Find number of points in cross section
numCrossSectionPoints = numel(x);

% Define constraints
uMin = 0; % Can't have negative absorption
uMax = Inf;

rMin = 1; % tracking vessels of radius > 1 pixels
rMax = numCrossSectionPoints/2; % can't have radius larger than half the cross section

y0Min = -1.5;
y0Max = 1.5;

% Define starting guess
uGuess = 0.01;
rGuess = 1;
y0Guess = 0;

%% Fitting
[xData, yData, zData] = prepareSurfaceData( z, x, I ); % Careful here as we swap axes x,y,z

% Set up fittype and options.
ft = fittype( 'exp(-u*2*upper_semicircle(y,r,y0)) + 0*x', 'independent', {'x', 'y'}, 'dependent', 'z' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Robust = 'Bisquare';
opts.Lower = [rMin uMin y0Min];
opts.StartPoint = [rGuess uGuess y0Guess];
opts.Upper = [rMax uMax y0Max];

% Run the fit
[fitresult, gof] = fit( [xData, yData], zData, ft, opts );


