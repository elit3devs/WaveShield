WaveShield.DetectionRegistry = {
    checks = {},
    intervals = {},
    lastRun = {},
    enabled = true
}

WaveShield.RegisterDetection = function(name, checkFunction, interval)
    WaveShield.DetectionRegistry.checks[name] = checkFunction
    WaveShield.DetectionRegistry.intervals[name] = interval or 1000
    WaveShield.DetectionRegistry.lastRun[name] = 0
end

WaveShield.isSpectating = false
WaveShield.isVisible = false
WaveShield.canPedRagdoll = false
WaveShield.hasChangedPedModel = false
WaveShield.playerRevived = false
WaveShield.proofsEnabled = false
WaveShield.healthRefilled = false
WaveShield.isInvincible = false
WaveShield.canBeDamaged = false
WaveShield.hasTeleported = false

local updateInfos = function()
    local Native = WaveShield.Native

    local playerPed = Native.PlayerPedId()
    local playerId = Native.PlayerId()

    WaveShield.playerPed = playerPed
    WaveShield.playerId = playerId
    WaveShield.playerModel = Native.GetEntityModel(playerPed)
    WaveShield.playerCoords = Native.GetEntityCoords(playerPed, false)
    WaveShield.playerHeight = Native.GetEntityHeightAboveGround(playerPed)
    WaveShield.isPlayerDead = Native.IsPedDeadOrDying(playerPed, true)
    WaveShield.playerHealth = Native.GetEntityHealth(playerPed)
    WaveShield.playerMaxHealth = Native.GetEntityMaxHealth(playerPed)
    WaveShield.playerArmour = Native.GetPedArmour(playerPed)
    WaveShield.isPlayerSprinting = Native.IsPedSprinting(playerPed)
    WaveShield.isPlayerWalking = Native.IsPedWalking(playerPed)
    WaveShield.isPlayerOnFoot = Native.IsPedOnFoot(playerPed)
    WaveShield.playerStamina = Native.GetPlayerSprintStaminaRemaining(playerId)
    WaveShield.isPlayerSwimming = Native.IsPedSwimming(playerPed)
    WaveShield.isPlayerUnderWater = Native.IsPedSwimmingUnderWater(playerPed)
    WaveShield.playerSpeed = Native.GetEntitySpeed(playerPed)
    WaveShield.isGamePlayCamRendering = Native.IsGameplayCamRendering()
    WaveShield.isAttachedToAPlayer = Native.IsPedAPlayer(Native.GetEntityAttachedTo(playerPed))

    WaveShield.playerInvincible = Native.GetPlayerInvincible(playerId)
    WaveShield.playerInvincible2 = Native.GetPlayerInvincible_2(playerId)
    WaveShield.entityCanBeDamaged = Native.GetEntityCanBeDamaged(playerPed)
    WaveShield.pedType = Native.GetPedType(playerPed)
    WaveShield.isPlayerFreeForAmbientTask = Native.IsPlayerFreeForAmbientTask(playerId)
    WaveShield.isEntityInAir = Native.IsEntityInAir(playerPed)
    WaveShield.isPedFalling = Native.IsPedFalling(playerPed)
    WaveShield.isPedClimbing = Native.IsPedClimbing(playerPed)
    WaveShield.isPedJumping = Native.IsPedJumping(playerPed)
    WaveShield.isPedOnVehicle = Native.IsPedOnVehicle(playerPed)
    WaveShield.isPedRunningRagdollTask = Native.IsPedRunningRagdollTask(playerPed)
    WaveShield.isPedJumpingOutOfVehicle = Native.IsPedJumpingOutOfVehicle(playerPed)
    WaveShield.isPedRunningMeleeTask = Native.IsPedRunningMeleeTask(playerPed)
    WaveShield.isPedDiving = Native.IsPedDiving(playerPed)

    WaveShield.isNetworkInSpectatorMode = Native.NetworkIsInSpectatorMode()

    WaveShield.isHoldingWeapon, WaveShield.currentWeapon = Native.GetCurrentPedWeapon(playerPed, true)
    WaveShield.selectedWeapon = Native.GetSelectedPedWeapon(playerPed)
    WaveShield.bestWeapon = Native.GetBestPedWeapon(playerPed, true)
    WaveShield.isPedArmed = Native.IsPedArmed(playerPed, 4)

    local tonumber = WaveShield.tonumber
    if not WaveShield.isPlayerDead and Native.IsPedInAnyVehicle(playerPed, false) then
        local currentVehicle = Native.GetVehiclePedIsIn(playerPed, false)

        WaveShield.isPlayerInVehicle = true
        WaveShield.playerCurrentVehicle = currentVehicle
        WaveShield.isPlayerDriver = Native.GetPedInVehicleSeat(currentVehicle, -1) == playerPed
        WaveShield.vehicleSpeed = Native.GetEntitySpeed(currentVehicle)

        if currentVehicle ~= 0 then
            WaveShield.vehicleModel = Native.GetEntityModel(currentVehicle)
            WaveShield.vehicleTopSpeedModifier = tonumber(string.format("%.1f", Native.GetVehicleTopSpeedModifier(currentVehicle)))
            WaveShield.vehicleCheatPowerIncrease = tonumber(string.format("%.1f", Native.GetVehicleCheatPowerIncrease(currentVehicle)))
            WaveShield.vehicleGravityAmount = tonumber(string.format("%.1f", Native.GetVehicleGravityAmount(currentVehicle)))
        end
    else
        WaveShield.isPlayerInVehicle = false
        WaveShield.playerCurrentVehicle = 0
        WaveShield.isPlayerDriver = false
        WaveShield.vehicleSpeed = 0
        WaveShield.vehicleModel = 0
        WaveShield.vehicleTopSpeedModifier = 0
        WaveShield.vehicleCheatPowerIncrease = 0
        WaveShield.vehicleGravityAmount = 0
    end
end

local runDetectionChecks = function(currentTime)
    if not WaveShield.DetectionRegistry.enabled or not WaveShield.playerSpawned or not WaveShield.Config then
        return
    end

    for name, checkFunction in WaveShield.Lua.pairs(WaveShield.DetectionRegistry.checks) do
        local interval = WaveShield.DetectionRegistry.intervals[name]
        local lastRun = WaveShield.DetectionRegistry.lastRun[name]

        if currentTime - lastRun >= interval then
            WaveShield.DetectionRegistry.lastRun[name] = currentTime
            checkFunction()
        end
    end
end

WaveShield.CreateThread(function()
    while true do
        local success2, currentTime = false, WaveShield.Native.GetGameTimer()
        local success, errorString = WaveShield.Lua.pcall(function()
            updateInfos()
            runDetectionChecks(currentTime)
            success2 = true
        end)

        if not success or not success2 then
            WaveShield.DetectPlayer("Bypass Attempt Detected", {
                reason = "Error in main loop",
                error = WaveShield.tostring(errorString) or "pcall manipulation",
            })
        end

        WaveShield.lastActorLoopTime = currentTime
        WaveShield.Wait(1000)
    end
end)
