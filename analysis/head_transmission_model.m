function headTransFunc = head_transmission_model(nmToInterpOver,HbMassConc,O2Sat,BloodVolFrac,WaterVolFrac,FatVolFrac,MelanosomeVolFrac)
HbMW = 64458; % g/mol

% Model spectra directory
analysisPathNameArray = regexp(cd,'\','split');
transRetinaPathName = strjoin(analysisPathNameArray(1:(end-1)),'\');
spectraPathName = [transRetinaPathName filesep 'spectra'];
modelSpectraDir = [spectraPathName filesep 'head transmission model'];

% Load water spectrum
normFlag = 0;
mu_aWater = load_interpolate_spectrum(modelSpectraDir,'water',nmToInterpOver,0);

% Load blood spectra
epsilonHbO2 = load_interpolate_spectrum(modelSpectraDir,'HbO2',nmToInterpOver,0);
epsilonHb = load_interpolate_spectrum(modelSpectraDir,'HbO2',nmToInterpOver,0);

% Convert from molar extinction to absorption coefficient
mu_aHbO2 = (log(10)*HbMassConc/HbMW)*epsilonHbO2;
mu_aHb = (log(10)*HbMassConc/HbMW)*epsilonHb;

% Load fat spectrum
mu_aFat = load_interpolate_spectrum(modelSpectraDir,'fat',nmToInterpOver,0);

% Load melanosome spectrum
mu_aMelanosome = load_interpolate_spectrum(modelSpectraDir,'melanosome',nmToInterpOver,0);


% Load approximate scattering spectrum
mu_sPrime = load_interpolate_spectrum(modelSpectraDir,'head scattering',nmToInterpOver,0);




