local checkSpectate = function()
    if not WaveShield.Config.Main.AntiSpectate then
        return
    end
    
    if not WaveShield.isSpectating and WaveShield.isNetworkInSpectatorMode then
        WaveShield.DetectPlayer(WaveShield.Detections.ANTI_SPECTATE)
    end
end)

WaveShield.RegisterDetection("spectate", checkSpectate, 5000)

exports("setSpectatorMode", function(toggle)
    WaveShield.isSpectating = toggle
end))
