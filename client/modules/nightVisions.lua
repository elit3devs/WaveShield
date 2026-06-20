local checkNightVisions = function()
    if not WaveShield.Config.Main.AntiNightVisions then
        return
    end

    if not IsPedInAnyHeli(WaveShield.playerPed) and WaveShield.isGamePlayCamRendering then
        if GetUsingseethrough() then
            WaveShield.DetectPlayer("Thermal Vision Detected")
            return
        elseif GetUsingnightvision() then
            WaveShield.DetectPlayer(WaveShield.Detections.ANTI_NIGHT_VISIONS)
            return
        end
    end
end)

WaveShield.RegisterDetection("nightVisions", checkNightVisions, 10000)-- b3JpZ2luYWwgb3duZXIgb2YgdGhpcyBzb3VyY2UgaXMgRk1B
