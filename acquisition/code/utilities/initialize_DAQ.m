function daqHandle = initialize_DAQ(numPins)

daqHandle = daq.createSession('ni');

portLineString = ['Port0/Line0:' num2str(numPins-1)];
addDigitalChannel(daqHandle,'Dev1',portLineString,'OutputOnly');

digitalOutputScan = zeros([1 numPins]);

outputSingleScan(daqHandle,digitalOutputScan);

devices = daq.getDevices;

% DAQ Initialized
disp(['DAQ initialized (' devices(1).Description ')'])


