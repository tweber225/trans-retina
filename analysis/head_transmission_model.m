function headTransFunc = head_transmission_model(sourceDistance,nmToInterpOver,HbMassConc,O2Sat,bloodVolFrac,waterVolFrac,fatVolFrac,melanosomeVolFrac)
% Note: rodent cortext SO2 60-70, go with 67 for humans
% blood volume fraction ~3.5
% Water volume ~70
% Fat (anyone's guess, not too critical) ~5%
% Melanosome volume fraction rough guess ~.03%


HbMW = 64458; % g/mol

% Model spectra directory
analysisPathNameArray = regexp(cd,'\','split');
transRetinaPathName = strjoin(analysisPathNameArray(1:(end-1)),'\');
spectraPathName = [transRetinaPathName filesep 'spectra'];
modelSpectraDir = [spectraPathName filesep 'head transmission model'];

% Load water spectrum
mu_aWater = load_interpolate_spectrum(modelSpectraDir,'water',nmToInterpOver,0);

% Load blood spectra
epsilonHbO2 = load_interpolate_spectrum(modelSpectraDir,'HbO2',nmToInterpOver,0);
epsilonHb = load_interpolate_spectrum(modelSpectraDir,'Hb',nmToInterpOver,0);

% Convert from molar extinction to absorption coefficient
mu_aHbO2 = (log(10)*HbMassConc/HbMW)*epsilonHbO2;
mu_aHb = (log(10)*HbMassConc/HbMW)*epsilonHb;

% Load fat spectrum
mu_aFat = load_interpolate_spectrum(modelSpectraDir,'fat',nmToInterpOver,0);

% Load melanosome spectrum
mu_aMelanosome = load_interpolate_spectrum(modelSpectraDir,'melanosome',nmToInterpOver,0);

% Compute the total absorption coefficient function
bloodContrib = bloodVolFrac*O2Sat*mu_aHbO2 + bloodVolFrac*(1-O2Sat)*mu_aHb;
waterContrib = waterVolFrac*mu_aWater;
fatContrib = fatVolFrac*mu_aFat;
melanosomeContrib = melanosomeVolFrac*mu_aMelanosome;
mu_a = bloodContrib + waterContrib + fatContrib + melanosomeContrib;


% Load approximate scattering spectrum
mu_sPrime = load_interpolate_spectrum(modelSpectraDir,'head scatter',nmToInterpOver,0);

% % Plot mu_a and mu_s' subplots
% figure;subplot(2,1,1);plot(nmToInterpOver,mu_a);
% subplot(2,1,2);plot(nmToInterpOver,mu_sPrime);
% 
% 
% % Compute mu_eff and plot it
% mu_eff = sqrt(3*mu_a.*(mu_a+mu_sPrime));
% figure;plot(nmToInterpOver,mu_eff);
% title('\mu_{effective}');xlabel('Wavelength (nm)');ylabel('cm^{-1}')


% Plot transmission function for specific geometries
% 3D from point source, homogenous infinite medium, and detection at some
% distance away, r

T_sphere = @(r,mu_a,mu_sPrime) (3*(mu_a+mu_sPrime)/(4*pi*r)).*exp(-3*r*(mu_a+mu_sPrime).*mu_a);
% figure
% plot(nmToInterpOver,T_sphere(2.75,mu_a,mu_sPrime))
% title('T_{sphere}(\lambda)');xlabel('Wavelength (nm)');ylabel(' ')

headTransFunc = T_sphere(sourceDistance,mu_a,mu_sPrime);




