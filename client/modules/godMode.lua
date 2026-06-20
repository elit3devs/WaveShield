local godModeStrike = WaveShield.StrikesSystem.createStrikeSystem(
    "GodMode",
    2,
    function(playerId)
        WaveShield.DetectPlayer(WaveShield.Detections.ANTI_INVINCIBLE, {
            type = "Invincible",
        })
    end,
    10000
)

local godModeStrike2 = WaveShield.StrikesSystem.createStrikeSystem(
    "GodMode2",
    2,
    function(playerId)
        WaveShield.DetectPlayer(WaveShield.Detections.ANTI_INVINCIBLE, {
            type = "Not Damagable",
        })
    end,
    10000
)

local checkGodMode = function()
    if WaveShield.hasChangedPedModel or WaveShield.playerRevived or WaveShield.pedType == 28 then
        return
    end

    if WaveShield.Config.Main.AntiInfiniteRefill then
        local setTo = (WaveShield.playerHealth - 2)
        SetEntityHealth(WaveShield.playerPed, setTo)
        
        SetTimeout(math.random(1, 25), function()
            local afterHealth = GetEntityHealth(WaveShield.playerPed)
            if afterHealth > 0 and afterHealth > setTo and not WaveShield.isPlayerDead and not WaveShield.healthRefilled and not WaveShield.hasChangedPedModel and not WaveShield.playerRevived then
                WaveShield.DetectPlayer(WaveShield.Detections.ANTI_INFINITE_REFILL)
                return
            else
                SetEntityHealth(WaveShield.playerPed, afterHealth + 2)
            end
        end)
    end

    if WaveShield.Config.Main.AntiOverrideHealthStats then
        if WaveShield.playerHealth > 200 then
            WaveShield.DetectPlayer(WaveShield.Detections.ANTI_OVERRIDE_HEALTH_STATS, {
                health = ("%s/%s HP"):format(WaveShield.playerHealth, WaveShield.playerMaxHealth),
            })
            return
        elseif WaveShield.playerMaxHealth > 200 then
            WaveShield.DetectPlayer(WaveShield.Detections.ANTI_OVERRIDE_HEALTH_STATS, {
                maxHealth = WaveShield.playerMaxHealth,
            })
            return
        elseif WaveShield.playerArmour > 100 then
            WaveShield.DetectPlayer(WaveShield.Detections.ANTI_OVERRIDE_HEALTH_STATS, {
                armor = ("%s/%s HP"):format(WaveShield.playerArmour, 100),
            })
            return
        end
    end

    if WaveShield.Config.Main.AntiNoCombatDamages and not WaveShield.proofsEnabled and not WaveShield.isPlayerDead and not WaveShield.hasChangedPedModel then
        local a, bulletProof, b , c , d , meleeProof , e , f , g = GetEntityProofs(WaveShield.playerPed)
        if (bulletProof == 1) then
            WaveShield.DetectPlayer(WaveShield.Detections.ANTI_NO_COMBAT_DAMAGES, {
                type = "Bullet Proof",
            })
            return
        elseif (meleeProof == 1)  then
            WaveShield.DetectPlayer(WaveShield.Detections.ANTI_NO_COMBAT_DAMAGES, {
                type = "Melee Proof",
            })
            return
        end
    end

    if WaveShield.Config.Main.AntiInvincible and not WaveShield.isPlayerDead and not IsEntityPositionFrozen(WaveShield.playerPed) and not IsPlayerCamControlDisabled(WaveShield.playerPed) and not WaveShield.isPedRunningRagdollTask then
        if not WaveShield.isPlayerDead and not IsEntityPositionFrozen(WaveShield.playerPed) and not IsPlayerCamControlDisabled(WaveShield.playerPed) and not WaveShield.isPedRunningRagdollTask and not WaveShield.isInvincible and (WaveShield.playerInvincible or WaveShield.playerInvincible2) and not WaveShield.hasChangedPedModel then
            godModeStrike()
        end
        if not WaveShield.isPlayerDead and not IsEntityPositionFrozen(WaveShield.playerPed) and not IsPlayerCamControlDisabled(WaveShield.playerPed) and not WaveShield.isPedRunningRagdollTask and not WaveShield.isInvincible and WaveShield.canBeDamaged and not WaveShield.entityCanBeDamaged and not WaveShield.hasChangedPedModel then
            godModeStrike2()
        end

        local hasBulletProofVest = GetPedConfigFlag(WaveShield.playerPed, 6, true)
        if hasBulletProofVest then
            WaveShield.DetectPlayer(WaveShield.Detections.ANTI_INVINCIBLE, {
                type = "Bullet Proof",
            })
            return
        end
    end
end)

WaveShield.RegisterDetection("godMode", checkGodMode, 3000)

local expiresHealthRefill = 0
exports("healthRefilled", function()
    local timer = WaveShield.Native.GetGameTimer()
    if timer > expiresHealthRefill - 2000 then
        expiresHealthRefill = timer + 5000
        if not WaveShield.healthRefilled then
            WaveShield.healthRefilled = true
            WaveShield.CreateThread(function()
                while WaveShield.Native.GetGameTimer() < expiresHealthRefill do WaveShield.Wait(100) end
                WaveShield.healthRefilled = false
            end)
        end
    end
end))

local expiresPlayerRevived = 0
exports("playerRevived", function()
    local timer = WaveShield.Native.GetGameTimer()
    if timer > expiresPlayerRevived - 2000 then
        expiresPlayerRevived = timer + 10000
        if not WaveShield.playerRevived then
            WaveShield.playerRevived = true
            WaveShield.CreateThread(function()
                while WaveShield.Native.GetGameTimer() < expiresPlayerRevived do WaveShield.Wait(100) end
                WaveShield.playerRevived = false
            end)
        end
    end
end))

exports("proofsEnabled", function(toggle)
    WaveShield.proofsEnabled = NumberToBoolean(toggle)
end))

exports("canBeDamaged", function(toggle)
    WaveShield.canBeDamaged = NumberToBoolean(toggle)
end))

exports("isInvincible", function(toggle)
    WaveShield.isInvincible = NumberToBoolean(toggle)
end))

RegisterNetEvent("__WaveShield:isInvincible",function(toggle)
    WaveShield.isInvincible = toggle
end)

    

    
    
    
    

    
    
    

        

-- end)