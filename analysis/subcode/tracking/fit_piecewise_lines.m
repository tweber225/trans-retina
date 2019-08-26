function intersectionPoint = fit_piecewise_lines(minTrackerNonZero)


[xData, yData] = prepareCurveData( [], minTrackerNonZero );

% Set up fittype and options.
ft = fittype( 'max(a,x*m+b)', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [.1 -1 1]; % a,b,m
opts.Lower = [0 -Inf 0];
opts.Upper = [10 0 Inf];

% Fit model to data.
[fitresult, ~] = fit( xData, yData, ft, opts );


intersectionPoint = (fitresult.a-fitresult.b)/fitresult.m;
