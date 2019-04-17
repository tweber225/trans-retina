function [fitresult, xData, yData, zData, gof] = fit_surface_and_neg_cyl_gaussian(x,y,z)
% Creates a fit of the f(x,y) data to a 2d linear surface (3 parameters)
% and a cylindrical gaussian, extruded along to x direction, specifically:
%
%      z     =   (a + b*x + c*y)  *  ( 1 + d*exp(-4*ln(2)*(y - e)^2 / f^2) )
% [image data]  [illum. nonunif.]     [cyl. gaussian with uniform illum.]
%
% Parameters:
% a - illumination intensity (ie I_0)
% b - illumination nonuniformity along x
% c - illumination nonuniformity along y
% d - amplitude of Gaussian (if negative, 1+d is transmission)
% e - center of the Gaussian
% f - full width at half maximum (FWHM)

% Find number of points in cross section
numXPoints = numel(x);
numYPoints = numel(y);

% Define constraints
aMin = 0; % intercept cannot be negative as we have positive only signals
aMax = 2^16; % max level of camera
bMin = -Inf; % Slopes (b and c) are not limited
bMax = Inf;
cMin = -Inf;
cMax = Inf;
dMin = -1; % Can't absorb more strongly than 0% transmission
dMax = 0; % Can't negative absorb (ie emit light)
eMin = -numYPoints/8; % center must be in the center quarter of the cross section
eMax = numYPoints/8; % center must be in the center quarter of the cross section
fMin = 1; % Vessels are assumed to be at least a pixel in width
fMax = numYPoints/2; % No vessels are wider than half the cross section length

% Define starting guess
aGuess = mean(z(:));
bGuess = 0;
cGuess = 0;
dGuess = -0.05;
eGuess = 0;
fGuess = 6;

%% Fitting
[xData, yData, zData] = prepareSurfaceData( x, y, z );

% Set up fittype and options.
ft = fittype( '(a + b*x + c*y)*(1+d*exp(-4*log(2)*((y-e)/f)^2))', 'independent', {'x', 'y'}, 'dependent', 'z' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [aMin bMin cMin dMin eMin fMin];
opts.StartPoint = [aGuess bGuess cGuess dGuess eGuess fGuess];
opts.Upper = [aMax bMax cMax dMax eMax fMax];

[fitresult, gof] = fit( [xData, yData], zData, ft, opts );



