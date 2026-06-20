local checkSuperJump = function()
    if not WaveShield.Config.Main.AntiSuperJump then
        return
    end

    if IsPedDoingBeastJump(WaveShield.playerPed) then
        WaveShield.DetectPlayer(WaveShield.Detections.ANTI_SUPER_JUMP, {
            reason = "Beast Jump",
        })
        return
    end
end)

WaveShield.RegisterDetection("superJump", checkSuperJump, 2000)