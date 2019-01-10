function BHWindow = blackman_harris(width)
% 
% Makes a radially-symmetric Nuttall-defined Blackman-Harris window
% 
% Timothy D. Weber
% Biomicroscopy Lab, BU 2017

aParams = [0.3635819,0.4891775,0.1365995,.0106411];

w = @(n,N,a) a(1) - a(2)*cos(2*pi*n/(N-1)) + a(3)*cos(4*pi*n/(N-1)) - a(4)*cos(6*pi*n/(N-1));

% Make a map of "n" to feed into analytical function above
x = (-width/2+.5):(width/2-.5);
y = x;
[xGrid,yGrid] = meshgrid(x,y);
[~, rho] = cart2pol(xGrid,yGrid);

rhoMod = -rho + (width/sqrt(2));
rhoMod = rhoMod/sqrt(2);
rhoMod(rhoMod<0) = 0;

BHWindow = w(rhoMod,width,aParams);