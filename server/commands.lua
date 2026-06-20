local prefix = function() return WaveShield.Config.Settings.CommandPrefix or "ws" end

RegisterCommand(prefix().."ban", function(source, args, rawCommand)
    if not WaveShield:doesPlayerHavePerms(source, "Commands") and source ~= 0 then return end
    local targetId = tonumber(args[1])
    if not targetId or not GetPlayerName(targetId) then
        WaveShield:print("Invalid player ID.", "^1", "Commands")
        return
    end
    local reason = table.concat(args, " ", 2) or "No reason specified"
    local playerObj = WaveShield.Player:new(targetId)
    playerObj:ban(reason, {}, -1, GetPlayerName(source) or "Console")
    WaveShield:print(("Banned player ^3%s^0"):format(GetPlayerName(targetId)), "^2", "Commands")
end, true)

RegisterCommand(prefix().."kick", function(source, args, rawCommand)
    if not WaveShield:doesPlayerHavePerms(source, "Commands") and source ~= 0 then return end
    local targetId = tonumber(args[1])
    if not targetId or not GetPlayerName(targetId) then
        WaveShield:print("Invalid player ID.", "^1", "Commands")
        return
    end
    local reason = table.concat(args, " ", 2) or "No reason specified"
    DropPlayer(targetId, "[WaveShield] " .. reason)
    WaveShield:print(("Kicked player ^3%s^0"):format(GetPlayerName(targetId)), "^2", "Commands")
end, true)

RegisterCommand(prefix().."unban", function(source, args, rawCommand)
    if not WaveShield:doesPlayerHavePerms(source, "Commands") and source ~= 0 then return end
    local banId = args[1]
    if not banId then
        WaveShield:print("Usage: " .. prefix() .. "unban <BanID>", "^1", "Commands")
        return
    end
    local ok, banData = WaveShield.RemoveBan(banId)
    if ok then
        WaveShield:print(("Unbanned Ban-ID: ^3%s^0"):format(banId), "^2", "Commands")
        TriggerEvent("__WaveShield_internal:playerUnbanned", banData, GetPlayerName(source) or "Console")
    else
        WaveShield:print(("No ban found with ID: ^3%s^0"):format(banId), "^1", "Commands")
    end
end, true)

RegisterCommand(prefix().."bans", function(source, args, rawCommand)
    if not WaveShield:doesPlayerHavePerms(source, "Commands") and source ~= 0 then return end
    local allBans = WaveShield.GetAllBans()
    local count = 0
    for banId, banData in pairs(allBans) do
        count = count + 1
        WaveShield:print(("Ban ^3%s^0: %s | Reason: %s"):format(banId, banData.license, banData.reason), "^3", "Bans")
    end
    if count == 0 then
        WaveShield:print("No active bans.", "^2", "Commands")
    else
        WaveShield:print(("Total active bans: ^3%s^0"):format(count), "^2", "Commands")
    end
end, true)

RegisterCommand(prefix().."reload", function(source, args, rawCommand)
    if not WaveShield:doesPlayerHavePerms(source, "Commands") and source ~= 0 then return end
    WaveShield:ReloadConfiguration()
end, true)

RegisterCommand(prefix().."debug", function(source, args, rawCommand)
    if not WaveShield:doesPlayerHavePerms(source, "Commands") and source ~= 0 then return end
    local targetId = tonumber(args[1]) or source
    if targetId and GetPlayerName(targetId) then
        TriggerClientEvent("__WaveShield:debug", targetId)
    end
end, true)

RegisterCommand(prefix().."setadmin", function(source, args, rawCommand)
    if source ~= 0 then return end
    local targetId = tonumber(args[1])
    if not targetId or not GetPlayerName(targetId) then return end
    Player(targetId).state:set("WS:isAdmin", true, false)
    WaveShield:print(("Set ^3%s^0 as admin."):format(GetPlayerName(targetId)), "^2", "Commands")
end, true)

RegisterCommand(prefix().."setbypass", function(source, args, rawCommand)
    if source ~= 0 then return end
    local targetId = tonumber(args[1])
    if not targetId or not GetPlayerName(targetId) then return end
    Player(targetId).state:set("WS:isBypass", true, false)
    WaveShield:print(("Set ^3%s^0 as bypass."):format(GetPlayerName(targetId)), "^2", "Commands")
end, true)

RegisterCommand(prefix().."deleteallbans", function(source, args, rawCommand)
    if source ~= 0 then return end
    local count = WaveShield.RemoveAllBans()
    WaveShield:print(("Deleted ^3%s^0 bans."):format(count), "^2", "Commands")
end, true)
