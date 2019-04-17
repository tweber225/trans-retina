function p = henyey_greenstein(theta,g)
% The classic Henyey-Greenstein phase function normalized such that
% integral over 4 pi steradians is unity.

num = 1-g^2;
denom = (1 + g^2 - 2*g*cos(theta)).^(3/2);

p = (1/(4*pi))*num./denom;