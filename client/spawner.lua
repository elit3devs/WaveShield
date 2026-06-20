local function IsPlayerUnderground()
    local pCoords = WaveShield and WaveShield.playerCoords ~= nil and WaveShield.playerCoords or GetEntityCoords(PlayerPedId())
    local ground, posZ = WaveShield.Native.GetGroundZFor_3dCoord(pCoords.x, pCoords.y, pCoords.z + 1.0, false)
    if not ground then
        ground, posZ = WaveShield.Native.GetGroundZFor_3dCoord(pCoords.x, pCoords.y, pCoords.z + 999.0, false)
    end
    if ground then
        local distFromGround = pCoords.z - posZ
        return distFromGround < 0, math.abs(distFromGround)
    end
    return false
end

local function HasPlayerSpawned()
    local model = WaveShield.Native.GetEntityModel(WaveShield.playerPed or PlayerPedId())
    local coords = WaveShield.Native.GetEntityCoords(WaveShield.playerPed or PlayerPedId())

    if model == 0 then return false end
    if model == GetHashKey("player_zero") then return false end
    if model == GetHashKey("player_one") then return false end
    if model == GetHashKey("player_two") then return false end
    if #(vector3(0.0, 0.0, 0.0) - coords) < 10 then return false end
    if IsScreenFadingOut() or IsScreenFadingIn() then return false end
    if #(WaveShield.Native.GetGameplayCamCoord() - coords) > 10 then return false end
    if not NetworkIsSessionActive() or not NetworkIsSessionStarted() then return false end
    if IsNuiFocused() then return false end
    if not HasCollisionLoadedAroundEntity(WaveShield.playerPed or PlayerPedId()) then return false end
    if IsPlayerSwitchInProgress() then return false end
    if not IsEntityOnScreen(WaveShield.playerPed or PlayerPedId()) then return false end
    if IsPlayerUnderground() then return false end
    if not IsEntityVisibleToScript(WaveShield.playerPed or PlayerPedId()) then return false end
    if not IsEntityVisible(WaveShield.playerPed or PlayerPedId()) then return false end
    return true
end

WaveShield.CreateThread(function()
    while not WaveShield.playerPed do WaveShield.Wait(100) end

    while not HasPlayerSpawned() do
        WaveShield.Wait(500)
    end
    WaveShield.Wait(5000)
    WaveShield.playerSpawned = true
end)
