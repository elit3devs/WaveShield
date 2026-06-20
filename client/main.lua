local isServerSide = IsDuplicityVersion()
local _exports = exports

WaveShield.Native = {
    PlayerPedId = PlayerPedId,
    PlayerId = PlayerId,
    GetEntityModel = GetEntityModel,
    GetEntityCoords = GetEntityCoords,
    GetEntityHeightAboveGround = GetEntityHeightAboveGround,
    IsPedDeadOrDying = IsPedDeadOrDying,
    GetEntityHealth = GetEntityHealth,
    GetEntityMaxHealth = GetEntityMaxHealth,
    GetPedArmour = GetPedArmour,
    IsPedSprinting = IsPedSprinting,
    IsPedWalking = IsPedWalking,
    IsPedOnFoot = IsPedOnFoot,
    GetPlayerSprintStaminaRemaining = GetPlayerSprintStaminaRemaining,
    IsPedSwimming = IsPedSwimming,
    IsPedSwimmingUnderWater = IsPedSwimmingUnderWater,
    GetEntitySpeed = GetEntitySpeed,
    IsGameplayCamRendering = IsGameplayCamRendering,
    IsPedAPlayer = IsPedAPlayer,
    GetEntityAttachedTo = GetEntityAttachedTo,
    GetPlayerInvincible = GetPlayerInvincible,
    GetPlayerInvincible_2 = GetPlayerInvincible_2,
    GetEntityCanBeDamaged = GetEntityCanBeDamaged,
    GetPedType = GetPedType,
    IsPlayerFreeForAmbientTask = IsPlayerFreeForAmbientTask,
    IsEntityInAir = IsEntityInAir,
    IsPedFalling = IsPedFalling,
    IsPedClimbing = IsPedClimbing,
    IsPedJumping = IsPedJumping,
    IsPedOnVehicle = IsPedOnVehicle,
    IsPedRunningRagdollTask = IsPedRunningRagdollTask,
    IsPedJumpingOutOfVehicle = IsPedJumpingOutOfVehicle,
    IsPedRunningMeleeTask = IsPedRunningMeleeTask,
    IsPedDiving = IsPedDiving,
    NetworkIsInSpectatorMode = NetworkIsInSpectatorMode,
    GetCurrentPedWeapon = GetCurrentPedWeapon,
    GetSelectedPedWeapon = GetSelectedPedWeapon,
    GetBestPedWeapon = GetBestPedWeapon,
    IsPedArmed = IsPedArmed,
    IsPedInAnyVehicle = IsPedInAnyVehicle,
    GetVehiclePedIsIn = GetVehiclePedIsIn,
    GetPedInVehicleSeat = GetPedInVehicleSeat,
    GetVehicleTopSpeedModifier = GetVehicleTopSpeedModifier,
    GetVehicleCheatPowerIncrease = GetVehicleCheatPowerIncrease,
    GetVehicleGravityAmount = GetVehicleGravityAmount,
    GetGameplayCamCoord = GetGameplayCamCoord,
    GetGroundZFor_3dCoord = GetGroundZFor_3dCoord,
    GetHashKey = GetHashKey,
    HasPedGotWeapon = HasPedGotWeapon,
    IsAimCamActive = IsAimCamActive,
    GetWeaponObjectFromPed = GetWeaponObjectFromPed,
    GetGameTimer = GetGameTimer,
}

WaveShield.Lua = {
    pairs = pairs,
    ipairs = ipairs,
    pcall = pcall,
    type = type,
    tostring = tostring,
    tonumber = tonumber,
    next = next,
    rawget = rawget,
    rawset = rawset,
    select = select,
    unpack = table.unpack,
}

WaveShield.debug = {
    short_executions = false,
    executions = false,
    stuff = false,
    getinfo = debug.getinfo,
}

WaveShield.tonumber = tonumber
WaveShield.tostring = tostring
WaveShield.LoadResourceFile = LoadResourceFile
WaveShield.print = function(...)
    print("[WaveShield]", ...)
end

WaveShield.assert = assert

WaveShield.StrikesSystem = {}
WaveShield.StrikesSystem.createStrikeSystem = function(name, maxStrikes, onMaxStrikes, resetAfter)
    local strikes = 0
    local lastStrikeTime = 0
    return function(playerId, ...)
        local currentTime = GetGameTimer()
        if currentTime - lastStrikeTime > (resetAfter or 10000) then
            strikes = 0
        end
        strikes = strikes + 1
        lastStrikeTime = currentTime
        if strikes >= maxStrikes then
            strikes = 0
            onMaxStrikes(playerId, ...)
        end
    end
end

local serverId = GetPlayerServerId(PlayerId())
local playerBagName = ("player:%d"):format(serverId)

local function SafeGetLocalPlayerState(key)
    return GetStateBagValue(playerBagName, key)
end

local function SafeSetLocalPlayerState(key, value, replicated)
    local payload = msgpack.pack(value)
    return SetStateBagValue(playerBagName, key, payload, payload:len(), replicated)
end

_G.SafeGetLocalPlayerState = SafeGetLocalPlayerState
_G.SafeSetLocalPlayerState = SafeSetLocalPlayerState

function WaveShield.TriggerServerEvent(eventName, ...)
    local args = {...}
    TriggerServerEvent(eventName, table.unpack(args))
end

function WaveShield.SendNUIMessage(data)
end

WaveShield.DetectPlayer = function(detection, details)
    local reason = type(detection) == "string" and detection or (detection and detection.message) or "Unknown"
    WaveShield.TriggerServerEvent("__WaveShield:reportDetection", reason, details or {})
end

RegisterNetEvent("__WaveShield:reportDetection")

local function signedToUnsigned(num)
    if not num or type(num) ~= "number" then return 0 end
    if num >= 0 then return num end
    return 4294967296 + num
end
_G.signedToUnsigned = signedToUnsigned

local function NumberToBoolean(value)
    if value == 1 or value == true then return true end
    if value == 0 or value == false then return false end
    return false
end
_G.NumberToBoolean = NumberToBoolean

WaveShield.CreateThread(function()
    while not GlobalState[WaveShield.CFct1C6gobnW4qkaQUx3Xk9Q or ""] do
        WaveShield.Wait(100)
    end
    WaveShield.Config = GlobalState[WaveShield.CFct1C6gobnW4qkaQUx3Xk9Q]
    WaveShield:print("WaveShield client initialized.")
end)

RegisterNetEvent("__WaveShield:hasTeleported")
RegisterNetEvent("__WaveShield:hasAddedAmmo")
RegisterNetEvent("__WaveShield:takeScreenShot")
RegisterNetEvent("__WaveShield:giveWeapon")
RegisterNetEvent("__WaveShield:removeWeapon")
RegisterNetEvent("__WaveShield:removeAllWeapons")
RegisterNetEvent("__WaveShield:CheckSpoofedBullets")
RegisterNetEvent("__WaveShield:NewResourcesData")
RegisterNetEvent("__WaveShield:debug")
RegisterNetEvent("__WaveShield:debug_executions")

RegisterNetEvent("__WaveShield_internal:configUpdated")
AddEventHandler("__WaveShield_internal:configUpdated", function()
    local config = GlobalState[GlobalState.CFct1C6gobnW4qkaQUx3Xk9Q or ""]
    if config then
        WaveShield.Config = config
    end
end)

exports("isRunning", function()
    return true, WaveShield.Native.GetGameTimer(), WaveShield.lastActorLoopTime or 0
end)
