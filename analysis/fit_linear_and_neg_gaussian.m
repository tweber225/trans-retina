function [fitresult, gof] = fit_linear_and_neg_gaussian(x, y)
%FIT_LINEAR_AND_NEG_GAUSSIAN(X,Y)
% Creates a fit of the x,y data to a linear function (mx+b) and a Gaussian.
%
% Linear function's intercept is assumed to be positive.
% Gaussian function's center is assumed to be in the domain of the data
% Gaussian's amplitude is assumed to be negative


%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( x, y );

% Set up fittype and options.
ft = fittype( 'a + b*x + c*exp(-4*0.6931471806*((x-e)./d)^2)', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [0 -Inf -Inf 0 min(x)];
opts.StartPoint = [1 1 -.1 1 max(x)/2];
opts.Upper = [Inf Inf 0 Inf max(x)];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

% Plot fit with data.
%figure( 'Name', 'untitled fit 1' );
h = plot( fitresult, xData, yData );
legend( h, 'y vs. x', 'untitled fit 1', 'Location', 'NorthEast' );
% Label axes
xlabel x
ylabel y
grid on


