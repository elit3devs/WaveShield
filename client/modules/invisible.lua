local invisibleStrike = WaveShield.StrikesSystem.createStrikeSystem(
    "AntiInvisible",
    2,
    function(playerId)
        WaveShield.DetectPlayer(WaveShield.Detections.ANTI_INVISIBLE)
    end,
    15000
)

local checkInvisible = function()
    if not WaveShield.Config.Main.AntiInvisible then
        return
    end

    if WaveShield.isVisible and not WaveShield.hasChangedPedModel and not WaveShield.playerRevived and not IsEntityVisibleToScript(WaveShield.playerPed) and not IsEntityAttached(WaveShield.playerPed) and ((GetNetworkTime() - (WaveShield.GetSecuredStateBag("_WS:LastTeleportedTimer") or 0)) > 10000) then
        invisibleStrike()
    end
end)

WaveShield.RegisterDetection("invisible", checkInvisible, 10000)

exports("isVisible", function(toggle)
    WaveShield.isVisible = NumberToBoolean(toggle)
end))