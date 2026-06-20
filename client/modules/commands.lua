local commandRegistry = {}

local function RegisterCommand(name, callback, requiresAdmin)
    commandRegistry[name:lower()] = {
        callback = callback,
        requiresAdmin = requiresAdmin or false
    }
end

local function ParseCommandInput(input)
    local parts = {}
    for part in input:gmatch("%S+") do
        table.insert(parts, part)
    end
    return parts
end

local function ExecuteCommand(commandStr)
    if not commandStr or commandStr == "" then
        return false
    end
    
    local parts = ParseCommandInput(commandStr)
    if #parts == 0 then
        return false
    end
    
    local commandName = table.remove(parts, 1):lower()
    local cmdData = commandRegistry[commandName]
    
    if not cmdData then
        return false
    end
    
    local success = WaveShield.Lua.pcall(function()
        cmdData.callback(WaveShield.Lua.unpack(parts))
    end)
    
    return success
end

RegisterCommand("test", function(arg1, arg2)
    WaveShield.print("Test command executed")
end, false)

RegisterCommand("debug", function(arg1)
    if arg1 == "state" then
        WaveShield.print("Player Spawned: " .. tostring(WaveShield.playerSpawned))
        WaveShield.print("Player Ped: " .. tostring(WaveShield.playerPed))
        WaveShield.print("Player ID: " .. tostring(WaveShield.playerId))
        WaveShield.print("Player Health: " .. tostring(WaveShield.playerHealth))
        WaveShield.print("Player Coords: " .. tostring(WaveShield.playerCoords))
    elseif arg1 == "vehicle" then
        WaveShield.print("In Vehicle: " .. tostring(WaveShield.isPlayerInVehicle))
        WaveShield.print("Vehicle Model: " .. tostring(WaveShield.vehicleModel))
        WaveShield.print("Vehicle Speed: " .. tostring(WaveShield.vehicleSpeed))
        WaveShield.print("Top Speed Modifier: " .. tostring(WaveShield.vehicleTopSpeedModifier))
    elseif arg1 == "weapon" then
        WaveShield.print("Current Weapon: " .. tostring(WaveShield.currentWeapon))
        WaveShield.print("Is Armed: " .. tostring(WaveShield.isPedArmed))
        WaveShield.print("Selected Weapon: " .. tostring(WaveShield.selectedWeapon))
    end
end, false)

RegisterCommand("detection", function(arg1)
    if arg1 == "disable" then
        WaveShield.DetectionRegistry.enabled = false
        WaveShield.print("Detections disabled")
    elseif arg1 == "enable" then
        WaveShield.DetectionRegistry.enabled = true
        WaveShield.print("Detections enabled")
    end
end, false)

_G.RegisterCommand = RegisterCommand
_G.ExecuteCommand = ExecuteCommand

return {
    RegisterCommand = RegisterCommand,
    ExecuteCommand = ExecuteCommand
}
