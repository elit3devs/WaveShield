local serverId = GetPlayerServerId(PlayerId())
local playerBagName = ("player:%d"):format(serverId)

local function SafeGetLocalPlayerState(key)
    return GetStateBagValue(playerBagName, key)
end

local function SafeSetLocalPlayerState(key, value, replicated)
    local payload = msgpack.pack(value)
    return SetStateBagValue(playerBagName, key, payload, payload:len(), replicated)
end

exports("screenshot", function(webhookUrl)
    WaveShield.assert(WaveShield.TypeCheck.isString(webhookUrl), "webhookUrl: string")
    WaveShield.print("Screenshots require NUI integration to be set up.")
    return nil
end)

exports("captureLastSeconds", function(webhookUrl)
    WaveShield.assert(WaveShield.TypeCheck.isString(webhookUrl), "webhookUrl: string")
    WaveShield.print("Gameplay capture requires NUI integration to be set up.")
    return nil
end)

AddEventHandler("__WaveShield:takeScreenShot", function(webhookUrl)
end)

AddEventHandler("__WaveShield:uploadCapturedGameplay", function(webhookUrl)
end)
