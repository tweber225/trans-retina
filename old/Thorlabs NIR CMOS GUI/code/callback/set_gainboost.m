function actualGainboost = set_gainboost(camHandle,targetGainboost)

camHandle.Gain.Hardware.Boost.SetEnable(targetGainboost);
[~,actualGainboost] = camHandle.Gain.Hardware.Boost.GetEnable;
