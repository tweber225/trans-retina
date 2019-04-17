function spectraInterpolated = load_interpolate_spec(fileLocation,wavelengthsRequested)

% Read the data from excel sheet file
data = xlsread(fileLocation);

% First column is wavelength
wavelengthsSupplied = data(:,1);

% Subsequent columns are spectra -- some spots will be NaN because they are
% blank. This is because the particular wavelength is a max/min for another
% spectrum, but not necessarily all of them
spectraSupplied = data(:,2:end);
numSpectraSupplied = size(spectraSupplied,2);

% Interpolate spectra at each wavelength requested
spectraInterpolated = zeros(length(wavelengthsRequested),numSpectraSupplied);
for specIdx = 1:numSpectraSupplied
    x = wavelengthsSupplied(~isnan(spectraSupplied(:,specIdx)));
    v = spectraSupplied(~isnan(spectraSupplied(:,specIdx)),specIdx);
    
    % Remove any duplicates, which interp1 requires
    pointIdx = 1;
    while pointIdx <= length(x)
        duplicateList = (x(pointIdx) == x(1:length(x) ~= pointIdx));
        duplicateList = [duplicateList(1:(pointIdx-1));0;duplicateList(pointIdx:end)];
        x = x(~duplicateList);
        v = v(~duplicateList);
        pointIdx = pointIdx+1;
    end
    
    spectraInterpolated(:,specIdx) = interp1(x,v,wavelengthsRequested,'spline');
    
end


