lambertianAnglesIndices = linspace((-pi/2),(pi/2),500+1);

hgAngleIndices = linspace(-pi,pi,600+1);

[kx,ky] = meshgrid(lambertianAnglesIndices);
hardAperture = (kx.^2 + ky.^2) < (pi/2)^2;

k = sqrt(kx.^2+ky.^2);

%AS=angular spectrum, inc=incident
AS_inc = cos(k); %Lambertian angular spectrum
AS_inc(AS_inc<0) = 0;


[kxHG,kyHG] = meshgrid(hgAngleIndices);
hardApertureHG = (kxHG.^2 + kyHG.^2) < (pi/4)^2;
hg = henyey_greenstein(sqrt(kxHG.^2 + kyHG.^2),0.995).*hardApertureHG;

AS_out = conv2(AS_inc,hg./sum(hg(:)),'same');

AS_out2 = conv2(AS_out,hg./sum(hg(:)),'same');

AS_out3 = conv2(AS_out2,hg./sum(hg(:)),'same');

AS_out4 = conv2(AS_out3,hg./sum(hg(:)),'same');

AS_out5 = conv2(AS_out4,hg./sum(hg(:)),'same');

AS_out6 = conv2(AS_out5,hg./sum(hg(:)),'same');

AS_out7 = conv2(AS_out6,hg./sum(hg(:)),'same');

AS_out8 = conv2(AS_out7,hg./sum(hg(:)),'same');


plot(lambertianAnglesIndices,AS_inc(round(end/2),:))
hold on;
plot(lambertianAnglesIndices,AS_out(round(end/2),:))
plot(lambertianAnglesIndices,AS_out2(round(end/2),:))
plot(lambertianAnglesIndices,AS_out3(round(end/2),:))
plot(lambertianAnglesIndices,AS_out4(round(end/2),:))
plot(lambertianAnglesIndices,AS_out5(round(end/2),:))
plot(lambertianAnglesIndices,AS_out6(round(end/2),:))
plot(lambertianAnglesIndices,AS_out7(round(end/2),:))
plot(lambertianAnglesIndices,AS_out8(round(end/2),:))
xlim([-pi/4,pi/4])
xlabel('Angle (rad)')
ylabel('Radiant Intensity')
legend('No scattering','1 scattering event','2','3','4','5','6','7','8')


x = [0:8];
y(1) = AS_inc(round(end/2),round(end/2));
y(2) = AS_out(round(end/2),round(end/2));
y(3) = AS_out2(round(end/2),round(end/2));
y(4) = AS_out3(round(end/2),round(end/2));
y(5) = AS_out4(round(end/2),round(end/2));
y(6) = AS_out5(round(end/2),round(end/2));
y(7) = AS_out6(round(end/2),round(end/2));
y(8) = AS_out7(round(end/2),round(end/2));
y(9) = AS_out8(round(end/2),round(end/2));

OD = -log10(y);