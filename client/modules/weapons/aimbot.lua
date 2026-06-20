local degreesToRadians = math.pi / 180

local RotationToDirection = function(rotation)
	local radiansZ = rotation.z * degreesToRadians
    local radiansX = rotation.x * degreesToRadians
    local num = math.abs(math.cos(radiansX))
    
    return vector3(
        -math.sin(radiansZ) * num,
        math.cos(radiansZ) * num,
        math.sin(radiansX)
    )
end)

local silentAimConfig = {
    maxTrajectoryDeviation = 2.0,     -- Max meters between expected hit and actual hit
    maxScreenDeviation = 70,         -- Max pixels between crosshair and hit point (increased)
    
    minDetectionDistance = 4.0,       -- Minimum distance to perform checks
    maxDetectionDistance = 250.0,     -- Maximum distance to check
    
    shotValidityWindow = 50,         -- ms after shot to consider impact valid
    
    minShotsForPattern = 3,           -- Minimum shots to detect patterns
    
    excludedWeaponGroups = {
        [GetHashKey("GROUP_SHOTGUN")] = true,
        [GetHashKey("GROUP_SNIPER")] = true,
        [GetHashKey("GROUP_THROWN")] = true,
        [GetHashKey("GROUP_HEAVY")] = true,
        [GetHashKey("GROUP_MELEE")] = true
    },
}

local silentAimData = {
    lastShotTime = 0,
    shotFired = false,
    shotData = nil, -- Store camera data when shot is fired
    screenCenter = { x = 0, y = 0 },
    
    lastCameraRotation = nil,
    lastMovementTime = 0,
    mouseVelocity = 0,

    recentHits = {},
    totalSuspiciousShots = 0,
}

local function detectRapidMouseMovement(currentRotation)
    local currentTime = WaveShield.Native.GetGameTimer()
    silentAimData.mouseVelocity = 0
    if silentAimData.lastCameraRotation then
        local timeDelta = currentTime - silentAimData.lastMovementTime
        if timeDelta > 0 and timeDelta < 500 then -- Within 500ms
            local rotationDelta = #(currentRotation - silentAimData.lastCameraRotation)
            silentAimData.mouseVelocity = rotationDelta / (timeDelta / 1000) -- degrees per second
        end
    end
    
    silentAimData.lastCameraRotation = currentRotation
    silentAimData.lastMovementTime = currentTime
    
    return silentAimData.mouseVelocity
end

local calculateExpectedHitPoint = function(shotData, impactDistance)
    if not shotData or not shotData.cameraCoords or not shotData.cameraDirection then 
        return nil 
    end
    
    return vector3(
        shotData.cameraCoords.x + (shotData.cameraDirection.x * impactDistance),
        shotData.cameraCoords.y + (shotData.cameraDirection.y * impactDistance),
        shotData.cameraCoords.z + (shotData.cameraDirection.z * impactDistance)
    )
end)

local analyzeTrajectoryDeviation = function(impactCoords, shotData)
    local impactDistance = #(shotData.cameraCoords - impactCoords)
    local expectedHitPoint = calculateExpectedHitPoint(shotData, impactDistance)
    
    if not expectedHitPoint then return false, 0 end
    
    local trajectoryDeviation = #(expectedHitPoint - impactCoords)
    
    local threshold = silentAimConfig.maxTrajectoryDeviation
    
    local isSuspicious = trajectoryDeviation > threshold

    return isSuspicious, trajectoryDeviation
end)

local analyzeScreenDeviation = function(impactCoords, shotData)
    if not shotData or not impactCoords then return false, 0 end
    
    local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(impactCoords.x, impactCoords.y, impactCoords.z)
    
    if not onScreen then return false, 0 end
    
    local screenWidth, screenHeight = GetActiveScreenResolution()
    local impactScreenX = screenX * screenWidth
    local impactScreenY = screenY * screenHeight
    silentAimData.screenCenter.x = screenWidth / 2
    silentAimData.screenCenter.y = screenHeight / 2

    local deltaX = impactScreenX - silentAimData.screenCenter.x
    local deltaY = impactScreenY - silentAimData.screenCenter.y
    local screenDeviation = math.sqrt(deltaX * deltaX + deltaY * deltaY)
    
    local distanceToImpact = #(shotData.cameraCoords - impactCoords)
    
    local threshold = silentAimConfig.maxScreenDeviation
    
    local isSuspicious = screenDeviation > threshold
    return isSuspicious, screenDeviation
end)

local updateSuspiciousPatterns = function(isSuspicious)
    local currentTime = WaveShield.Native.GetGameTimer()
    
    for i = #silentAimData.recentHits, 1, -1 do
        if currentTime - silentAimData.recentHits[i].time > 30000 then
            table.remove(silentAimData.recentHits, i)
        end
    end
    
    table.insert(silentAimData.recentHits, {
        time = currentTime,
        suspicious = isSuspicious
    })
    
    if isSuspicious then
        silentAimData.totalSuspiciousShots = silentAimData.totalSuspiciousShots + 1
    end
    
    local recentSuspicious = 0
    for _, hit in WaveShield.Lua.ipairs(silentAimData.recentHits) do
        if hit.suspicious then
            recentSuspicious = recentSuspicious + 1
        end
    end
    
    return recentSuspicious >= silentAimConfig.minShotsForPattern
end)

local shouldMonitorWeapon = function(weaponHash)
    if not weaponHash or weaponHash == WaveShield.Native.GetHashKey("WEAPON_UNARMED") then
        return false
    end
    
    local weaponGroup = GetWeapontypeGroup(weaponHash)
    if silentAimConfig.excludedWeaponGroups[weaponGroup] then
        return false
    end
    
    local damageType = GetWeaponDamageType(weaponHash)
    return damageType == 3 -- Bullet damage only
end)

local validateShotLegitimacy = function(victim, impactCoords, weaponHash)
    local shooterCoords = GetEntityCoords(WaveShield.playerPed)
    local victimCoords = GetEntityCoords(victim)
    local distanceToVictim = #(shooterCoords - victimCoords)
    
    if distanceToVictim < silentAimConfig.minDetectionDistance then
        return true, "too_close"
    end
    
    if distanceToVictim > silentAimConfig.maxDetectionDistance then
        return true, "too_far"
    end
    
    if not shouldMonitorWeapon(weaponHash) then
        return true, "excluded_weapon"
    end

    local mouseVelocity = silentAimData.shotData and silentAimData.shotData.mouseVelocity or 0
    
    if mouseVelocity > 100 then
        return true, "rapid_movement_excluded", {
            mouseVelocity = mouseVelocity,
            reason = "Shot excluded due to rapid mouse movement"
        }
    end
    
    local suspiciousTrajectory, trajectoryDeviation = analyzeTrajectoryDeviation(impactCoords, silentAimData.shotData)
    
    local suspiciousScreen, screenDeviation = analyzeScreenDeviation(impactCoords, silentAimData.shotData)
    
    local isSuspicious = suspiciousTrajectory or suspiciousScreen
    
    local hasPattern = updateSuspiciousPatterns(isSuspicious)
    
    if suspiciousTrajectory and trajectoryDeviation > (silentAimConfig.maxTrajectoryDeviation * 1.5) then
        return false, {
            reason = "instant_trajectory_violation",
            trajectoryDeviation = trajectoryDeviation,
            threshold = silentAimConfig.maxTrajectoryDeviation * 1.5,
            distance = distanceToVictim,
            screenDeviation = screenDeviation,
            mouseVelocity = mouseVelocity,
        }
    end
    
    if suspiciousScreen and screenDeviation > (silentAimConfig.maxScreenDeviation * 3.0) then
        return false, {
            reason = "instant_screen_violation",
            screenDeviation = screenDeviation,
            threshold = silentAimConfig.maxScreenDeviation * 3.0,
            distance = distanceToVictim,
            trajectoryDeviation = trajectoryDeviation,
            mouseVelocity = mouseVelocity,
        }
    end
    
    if hasPattern then
        return false, {
            reason = "pattern_detection",
            suspiciousShots = silentAimData.totalSuspiciousShots,
            recentSuspicious = #silentAimData.recentHits,
            trajectoryDeviation = trajectoryDeviation,
            screenDeviation = screenDeviation,
            distance = distanceToVictim,
            mouseVelocity = mouseVelocity,
        }
    end
    
    if isSuspicious and distanceToVictim > 30 then
        if (trajectoryDeviation and trajectoryDeviation > silentAimConfig.maxTrajectoryDeviation * 0.7) and
           (screenDeviation and screenDeviation > silentAimConfig.maxScreenDeviation * 0.7) then
            return false, {
                reason = "distance_based_violation",
                trajectoryDeviation = trajectoryDeviation,
                screenDeviation = screenDeviation,
                distance = distanceToVictim,
                mouseVelocity = mouseVelocity,
            }
        end
    end
    
    return true, "legitimate_shot"
end)

local function isPedAWitness(witnesses, ped)
    if not witnesses then return false end
    
    for k, v in WaveShield.Lua.pairs(witnesses) do
        if v == ped or v == 0 then
            return true
        end
    end
    return false
end

AddEventHandler("CEventGunShot", function(witnesses, shooter)
    if shooter ~= WaveShield.playerPed then return end
    if WaveShield.Native.IsEntityDead(shooter) then return end
    if GetPedParachuteState(shooter) > 0 then return end
    if GetRenderingCam() ~= -1 then return end

    local timer = WaveShield.Native.GetGameTimer()
    if timer - silentAimData.lastShotTime == 0 then
        return
    end

    local hold, weaponHash = WaveShield.Native.GetCurrentPedWeapon(WaveShield.playerPed, true)
    if not hold and (not WaveShield.Native.HasPedGotWeapon(WaveShield.playerPed, weaponHash, false) or weaponHash == -1569615261) and (WaveShield.Native.IsPlayerFreeForAmbientTask(WaveShield.playerId) or not WaveShield.Native.IsAimCamActive()) then
        if WaveShield.Config.Weapons.AntiSpoofedBullets then
            WaveShield.DetectPlayer(WaveShield.Detections.ANTI_SPOOFED_BULLETS, {
                reason = "Invalid Weapon",
                debug = ("%s:%s"):format(hold, weaponHash),
            })
        end
        silentAimData.shotFired = false
        return
    end

    if not WaveShield.Config.Beta.AntiSilentAim then return end
    if not shouldMonitorWeapon(weaponHash) then return end

    silentAimData.lastShotTime = timer
    silentAimData.shotFired = true
    
    local cameraCoords = WaveShield.Native.GetGameplayCamCoord()
    local cameraRotation = WaveShield.Native.GetGameplayCamRot()
    
    detectRapidMouseMovement(cameraRotation)

    silentAimData.shotData = {
        cameraCoords = cameraCoords,
        cameraRotation = cameraRotation,
        cameraDirection = RotationToDirection(cameraRotation),
        mouseVelocity = silentAimData.mouseVelocity
    }
end))

AddEventHandler("CEventGunShotBulletImpact", function(witnesses, shooter)
    if not WaveShield.Config.Beta.AntiSilentAim then return end
    if shooter ~= WaveShield.playerPed then return end
    if not silentAimData.shotFired then return end
    if GetPedParachuteState(shooter) > 0 then return end
    if GetRenderingCam() ~= -1 then return end

    local currentTime = WaveShield.Native.GetGameTimer()
    if currentTime - silentAimData.lastShotTime >= silentAimConfig.shotValidityWindow then 
        silentAimData.shotFired = false
        return 
    end

    if WaveShield.Native.IsPedDeadOrDying(shooter, true) or IsPedRagdoll(shooter) then
        silentAimData.shotFired = false
        return
    end

    local hold, weaponHash = WaveShield.Native.GetCurrentPedWeapon(WaveShield.playerPed, true)
    if not hold then
        silentAimData.shotFired = false
        return
    end

    local success, impactCoords = GetPedLastWeaponImpactCoord(shooter)
    if not success then
        WaveShield.DetectPlayer(WaveShield.Detections.ANTI_SILENT_AIM, {
            reason = "Bullet Impact Manipulation",
        })
        silentAimData.shotFired = false
        return
    elseif success and impactCoords == vector3(0.0, 0.0, 0.0) then
        WaveShield.DetectPlayer(WaveShield.Detections.ANTI_SILENT_AIM, {
            reason = "Bullet Impact Manipulation #2",
        })
        silentAimData.shotFired = false
        return
    end

    local victim, victimDistance = getClosestPed(impactCoords, 3.0)
    if not victim or not IsPedAPlayer(victim) or IsPedInAnyVehicle(victim, false) then
        silentAimData.shotFired = false
        return
    end

    if not HasEntityBeenDamagedByWeapon(victim, weaponHash, 0) then
        silentAimData.shotFired = false
        return
    end

    local lastDamagedTime = GetTimeOfLastPedWeaponDamage(victim, weaponHash)
    if currentTime - lastDamagedTime > silentAimConfig.shotValidityWindow then 
        silentAimData.shotFired = false
        return
    end

    ClearPedLastWeaponDamage(victim)
    ClearEntityLastWeaponDamage(victim)

    local isLegitimate, detectionData = validateShotLegitimacy(victim, impactCoords, weaponHash)

    if not isLegitimate then
        local shooterCoords = GetEntityCoords(shooter)
        local victimCoords = GetEntityCoords(victim)
        local distanceToVictim = #(shooterCoords - victimCoords)
        
        detectionData.distance = distanceToVictim
        
        WaveShield.DetectPlayer(WaveShield.Detections.ANTI_SILENT_AIM, detectionData)
    end

    silentAimData.shotFired = false
end))

WaveShield.CreateThread(function()
    local minDeltaToTrigger = 0.005
    local previousCamRot = WaveShield.Native.GetGameplayCamRot(2)
    local previousCamHeading = GetGameplayCamRelativeHeading()
    local lastFov = GetGameplayCamFov() 
    local lastInput = 0
    local steadyFrames = 0
    local strikeCount = 0
    local lastWeaponBlocked = 0
    local lastInCollision = 0
    local lastChangedWeapon = 0
    local lastWeapon = WaveShield.Native.GetHashKey("WEAPON_UNARMED")

    local aimbotStrike = WaveShield.StrikesSystem.createStrikeSystem(
        "AntiAimBot",
        5,
        function(playerId)
            WaveShield.DetectPlayer(WaveShield.Detections.ANTI_AIM_BOT, {
                debug = math.abs(WaveShield.Native.GetGameplayCamRot(2).z - previousCamRot.z),
            })
        end,
        5000
    )

    while true do
        if WaveShield.Config.Weapons.AntiAimBot then
            local weaponHash = WaveShield.Native.GetSelectedPedWeapon(WaveShield.playerPed)
            local wait = 100
            local timer = WaveShield.Native.GetGameTimer()
            
            if WaveShield.Native.IsAimCamActive() and GetPedConfigFlag(WaveShield.playerPed, 78, true) and not IsPedInCover(WaveShield.playerPed, 0) and timer - lastWeaponBlocked > 1000 and timer - lastChangedWeapon > 1000 and timer - lastInCollision > 1000 and
                not (IsGameplayCamShaking() and WaveShield.Native.IsPedInAnyVehicle(WaveShield.playerPed, false)) and
                (not IsGameplayCamShaking() or
                    (GetFollowPedCamViewMode() ~= 4 or
                        not IsPlayerFreeAiming(WaveShield.playerId)
                    )
                ) and IsUsingKeyboard(0) and not IsEntityInAir(WaveShield.playerPed)
            then
                local weaponGroup = GetWeapontypeGroup(weaponHash)
                if weaponGroup ~= -1212426201 and weaponGroup ~= -1569042529 then
                    local camRot = WaveShield.Native.GetGameplayCamRot(2)
                    local camHeading = GetGameplayCamRelativeHeading()
                    local ix = GetDisabledControlNormal(0, 1)
                    local iy = GetDisabledControlNormal(0, 2)
                    local currentFov = GetGameplayCamFov()
                    local fovDiff = math.abs(currentFov - lastFov)

                    if fovDiff < 0.05 then
                        steadyFrames = steadyFrames + 1
                    else
                        steadyFrames = 0
                    end

                    if previousCamRot and steadyFrames > 3 then
                        local yawDelta = math.abs(camRot.z - previousCamRot.z)
                        local camHeadingDelta = math.abs(camHeading - previousCamHeading)
                        local input = math.abs(ix) + math.abs(iy)

                        if yawDelta > minDeltaToTrigger and camHeadingDelta == 0.0 and input == 0.0 and lastInput == 0.0 then
                            strikeCount = strikeCount + 1
                        else
                            strikeCount = 0
                        end

                        lastInput = input
                    else
                        strikeCount = 0
                    end

                    if strikeCount >= 10 then
                        aimbotStrike()
                        strikeCount = 0
                    end

                    lastFov = currentFov
                    previousCamRot = camRot
                    previousCamHeading = camHeading
                    wait = 0
                else
                    wait = 1000
                end
            end

            if GetIsTaskActive(WaveShield.playerPed, 299) then
                lastWeaponBlocked = timer
            end

            if #GetCollisionNormalOfLastHitForEntity(WaveShield.playerPed) > 0 then
                lastInCollision = timer
            end
            
            if lastWeapon ~= weaponHash then
                lastChangedWeapon = timer
            end

            lastWeapon = weaponHash

            WaveShield.Wait(wait)
        else
            WaveShield.Wait(10000)
        end
    end
end))