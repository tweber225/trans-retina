function BHWindow = blackman_harris_window(width)
% ANALYSIS/BLACKMAN_HARRIS_WINDOW
% Makes a radially-symmetric 
% 
% Part 3b of standard image processing pipeline
% Timothy D. Weber
% Biomicroscopy Lab, BU 2017


w = @(n,N) 0.35875 - 0.48829*cos(2*pi*n/(N-1)) + 0.14128*cos(4*pi*n/(N-1)) - 0.01168*cos(6*pi*n/(N-1));

% Make a map of "n" to feed into analytical function above
x = (-width/2+.5):(width/2-.5);
y = x;
[xGrid,yGrid] = meshgrid(x,y);
[~, rho] = cart2pol(xGrid,yGrid);

rho = -(rho-(width/2-.5));
rho(rho<0) = 0;

BHWindow = w(rho,width);