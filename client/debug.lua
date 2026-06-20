local debugEventName = WaveShield.EncryptString("__WaveShield:debug", WaveShield.Substitution)
local debugEventName2 = WaveShield.EncryptString("__WaveShield:debug_executions", WaveShield.Substitution)

RegisterCommand("+ws_debug", function()
    WaveShield.debug.short_executions = not WaveShield.debug.short_executions
    WaveShield.print("DEBUG: " .. tostring(WaveShield.debug.short_executions))
    SafeSetLocalPlayerState(("player:%d"):format(GetPlayerServerId(PlayerId())), WaveShield.debug.short_executions, true)
end)

RegisterCommand("+ws_debug_executions", function()
    WaveShield.debug.executions = not WaveShield.debug.executions
end)

RegisterNetEvent(debugEventName, function()
    WaveShield.debug.short_executions = not WaveShield.debug.short_executions
    WaveShield.print("DEBUG: " .. tostring(WaveShield.debug.short_executions))
end)

RegisterNetEvent(debugEventName2, function()
    WaveShield.debug.executions = not WaveShield.debug.executions
end)
