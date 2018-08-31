function set_min_gain(camHandle)

boostEnable = false;
targetMasterGain = 0;

camHandle.Gain.Hardware.Boost.SetEnable(boostEnable);
camHandle.Gain.Hardware.Scaled.SetMaster(targetMasterGain);