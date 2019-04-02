function [fitresult, gof] = fit_linear_and_neg_gaussian(x, y)
%FIT_LINEAR_AND_NEG_GAUSSIAN(X,Y)
% Creates a fit of the x,y data to a linear function (mx+b) and a Gaussian.

% Find number of points in cross section
numPoints = numel(x);

% Define constraints
aMin = 0; % intercept cannot be negative as we have positive only signals
aMax = 2^16; % max level on camera
bMin = -Inf;
bMax = Inf;
cMin = -Inf;
cMax = -1;
dMin = 2; % tracking vessels of diameter > 2 pixels
dMax = numPoints/2; % can't be larger than half the cross section
eMin = -numPoints/4; % center must be in the center half of the cross section
eMax = numPoints/4; % center must be in the center half of the cross section

% Define starting guess
aGuess = mean(y);
bGuess = 0;
cGuess = -mean(y)/100;
dGuess = numPoints/4;
eGuess = 0;

%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( x, y );

% Set up fittype and options.
ft = fittype( 'a + b*x + c*exp(-4*0.6931471806*((x-e)./d)^2)', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [aMin bMin cMin dMin eMin];
opts.StartPoint = [aGuess bGuess cGuess dGuess eGuess];
opts.Upper = [aMax bMax cMax dMax eMax];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

% % Plot fit with data.
% %figure( 'Name', 'untitled fit 1' );
% h = plot( fitresult, xData, yData );
% legend( h, 'y vs. x', 'untitled fit 1', 'Location', 'NorthEast' );
% % Label axes
% xlabel x
% ylabel y
% grid on


