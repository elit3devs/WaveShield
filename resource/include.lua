local _TriggerEvent = TriggerEvent
local _TriggerServerEvent = TriggerServerEvent
local _AddEventHandler = AddEventHandler

local resourceName = GetCurrentResourceName()

local function IsIgnoredEvent(eventName)
    if not eventName or type(eventName) ~= "string" then return true end
    local ignoredPrefixes = {
        "__cfx_export_", "__cfx_internal:", "__cfx_nui:", "txaLogger:", "txsv:",
        "baseevents:", "mapmanager:", "pmc__callback_retval:", "_WS:",
    }
    for _, prefix in ipairs(ignoredPrefixes) do
        if eventName:sub(1, #prefix) == prefix then return true end
    end
    local ignoredExact = {
        "onResourceStarting", "mumbleDisconnected", "entityDamaged", "onClientResourceStart",
        "onResourceStop", "gameEventTriggered", "onClientResourceStop", "populationPedCreating",
        "mumbleConnected", "onServerResourceStart", "onServerResourceStop", "onResourceListRefresh",
        "playerConnecting", "playerDropped", "playerJoining", "rconCommand", "weaponDamageEvent",
        "vehicleComponentControlEvent", "ptFxEvent", "removeAllWeaponsEvent", "removeWeaponEvent",
        "startProjectileEvent", "giveWeaponEvent", "clearPedTasksEvent", "fireEvent",
        "respawnPlayerPedEvent", "explosionEvent", "entityCreated", "entityCreating", "entityRemoved",
        "playerEnteredScope", "playerLeftScope", "hostingSession", "hostedSession",
        "sessionHostResult", "playerSpawned", "onClientMapStart", "onClientMapStop",
        "onClientGameTypeStart", "onClientGameTypeStop", "onMapStart", "onMapStop",
        "onGameTypeStart", "onGameTypeStop",
    }
    for _, evt in ipairs(ignoredExact) do
        if eventName == evt then return true end
    end
    return false
end

TriggerEvent = function(eventName, ...)
    _TriggerEvent(eventName, ...)
end

TriggerServerEvent = function(eventName, ...)
    if not IsIgnoredEvent(eventName) and exports["WaveShield"] and exports["WaveShield"]:isRunning() then
        local wsExports = exports["WaveShield"]
        if wsExports and wsExports.ConvertEvent then
        end
    end
    _TriggerServerEvent(eventName, ...)
end
