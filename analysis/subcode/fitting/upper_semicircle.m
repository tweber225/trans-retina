function y = upper_semicircle(x,r,x0)

sqrtArg = r.^2 - (x-x0).^2;

sqrtArg(sqrtArg<0) = 0;

y = sqrt(sqrtArg);