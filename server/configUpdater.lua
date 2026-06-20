local blockedNetGameEvents = {
    [3002107268] = "NETWORK_GIVE_PICKUP_REWARDS_EVENT",
    [1537535389] = "PLAYER_TAUNT_EVENT",
    [2639765290] = "NETWORK_PLAY_AIRDEFENSE_FIRE_EVENT",
    [1992295566] = "BLOCK_WEAPON_SELECTION",
    [2654380799] = "NETWORK_SPECIAL_FIRE_EQUIPPED_WEAPON",
    [1167173304] = "GIVE_PICKUP_REWARDS_EVENT",
    [935852904] = "RAGDOLL_REQUEST_EVENT",
}

RegisterNetEvent("__WaveShield_internal:configUpdated")
AddEventHandler("__WaveShield_internal:configUpdated", function()
    if type(source) == "number" and source > 0 then
        DropPlayer(source, "Sync error")
        return
    end

    WaveShield.Config.Weapons.WhiteListedProjectiles = WaveShield:transformTableValuesInHashKeys(WaveShield.Config.Weapons.WhiteListedProjectiles)

    WaveShield.Config.Explosions.BlackListedExplosions = WaveShield:transformTableValuesInKeys(WaveShield.Config.Explosions.BlackListedExplosions)

    WaveShield.Config.Explosions.WhiteListedParticles = WaveShield:transformTableValuesInHashKeys(WaveShield.Config.Explosions.WhiteListedParticles)
    WaveShield.Config.Explosions.WhiteListedParticles = WaveShield:runAutoWhiteList(WaveShield.Config.Explosions.WhiteListedParticles, "Particles")

    WaveShield.Config.Entities.WhiteListedPeds = WaveShield:transformTableValuesInHashKeys(WaveShield.Config.Entities.WhiteListedPeds)
    WaveShield.Config.Entities.WhiteListedPeds = WaveShield:runAutoWhiteList(WaveShield.Config.Entities.WhiteListedPeds, "Peds")

    WaveShield.Config.Entities.WhiteListedVehicles = WaveShield:transformTableValuesInHashKeys(WaveShield.Config.Entities.WhiteListedVehicles)
    WaveShield.Config.Entities.WhiteListedVehicles = WaveShield:runAutoWhiteList(WaveShield.Config.Entities.WhiteListedVehicles, "Vehicles")

    WaveShield.Config.Entities.BlackListedVehicles = WaveShield:transformTableValuesInHashKeys(WaveShield.Config.Entities.BlackListedVehicles)
    WaveShield.Config.Entities.BlackListedPeds = WaveShield:transformTableValuesInHashKeys(WaveShield.Config.Entities.BlackListedPeds)

    WaveShield.Config.Entities.WhiteListedObjects = WaveShield:transformTableValuesInHashKeys(WaveShield.Config.Entities.WhiteListedObjects)
    WaveShield.Config.Entities.WhiteListedObjects = WaveShield:runAutoWhiteList(WaveShield.Config.Entities.WhiteListedObjects, "Props")

    WaveShield.Config.Entities.PreBlackListedObjects = WaveShield:runAutoBlackList()
    WaveShield.Config.Entities.BlackListedObjects = WaveShield:transformTableValuesInHashKeys(WaveShield.Config.Entities.BlackListedObjects)

    SetConvar("sv_filterRequestControl", "4")
    SetConvar("sv_enableNetworkedPhoneExplosions", "false")
    SetConvar("sv_enableNetworkedSounds", "false")
    SetConvar("sv_enableNetworkedScriptEntityStates", "false")
    SetConvarReplicated("game_sanitizeRagdollEvents", "true")

    SetConvar("sv_experimentalNetGameEventHandler", "true")

    local allowedCommand = IsPrincipalAceAllowed("resource.WaveShield", "command")
    if allowedCommand then
        local version = WaveShield:GetFXVersion()
        if version and version >= 16276 then
            for eventHash, eventName in pairs(blockedNetGameEvents) do
                ExecuteCommand("block_net_game_event " .. tostring(version >= 16563 and eventName or eventHash))
            end
        end
    end

    GlobalState[WaveShield.CFct1C6gobnW4qkaQUx3Xk9Q] = WaveShield.Config
    TriggerClientEvent("__WaveShield_internal:configUpdated", -1)
end)

function WaveShield:ReloadConfiguration()
    if _G.RawWaveShieldConfiguration then
        WaveShield.MakeConfiguration(_G.RawWaveShieldConfiguration)
    end
    TriggerEvent("__WaveShield_internal:configUpdated")
    WaveShield:print("Successfully reloaded the configuration.", "^2", "Config")
end

exports("ReloadConfiguration", function()
    local invoker = GetInvokingResource()
    if invoker then
        WaveShield:ReloadConfiguration()
    end
end)

for _, stateBagName in pairs({
    "_WS:LastTeleportedTimer",
    "_WS:LastCamEaseTime",
    WaveShield.HHct1C6gobnW3DkIQUxiXk9Q,
    WaveShield.HHct1C6gobnW3DkIQUxiXk9Q .. "_SV",
    WaveShield.HHct1C6gobnW3DkIQUxiXk9Q .. "_CL",
    "_WS:injctd_astp",
    "WS:playTime",
    "WS:threatScore",
    "WS:isAdmin",
    "WS:isBypass",
}) do
    AddStateBagChangeHandler(stateBagName, nil, function(bagName, key, value, reserved, replicated)
        local src = GetPlayerFromStateBagName(bagName)
        if src == 0 then return end
        if reserved ~= 0 then
            WaveShield.DetectPlayer(src, "Bypass Attempt Detected", {
                stateBagName = stateBagName,
            })
        end
    end)
end
