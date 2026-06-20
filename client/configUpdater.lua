AddStateBagChangeHandler("WaveShieldConfiguration", 'global', function()
    WaveShield.DetectPlayer("Bypass Attempt Detected", {
        reason = "#ICU"
    })
end)

AddStateBagChangeHandler(GlobalState.CFct1C6gobnW4qkaQUx3Xk9Q, 'global', function(bagName, key, value, reserved, replicated)
    if replicated == true then
        WaveShield.DetectPlayer("Bypass Attempt Detected", {
            reason = "Unauthorized configuration update"
        })
        return
    end

    if not value or WaveShield.type(value) ~= "table" then
        WaveShield.DetectPlayer("Bypass Attempt Detected", {
            reason = "Invalid configuration type"
        })
        return
    end

    if not value.Main or not value.Entities or not value.Weapons or not value.Beta or not value.Premium then return end

    WaveShield.Config = value
end)
