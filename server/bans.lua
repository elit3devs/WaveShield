local bansFile = "bans.json"
local bans = {}
local banIdCounter = 1

local function loadBans()
    local raw = LoadResourceFile(GetCurrentResourceName(), bansFile)
    if raw then
        local decoded = json.decode(raw)
        if decoded then
            bans = decoded.bans or {}
            banIdCounter = decoded.counter or 1
        end
    end
end

local function saveBans()
    SaveResourceFile(GetCurrentResourceName(), bansFile, json.encode({ bans = bans, counter = banIdCounter }), -1)
end

loadBans()

local function nextBanId()
    local id = "WS-" .. tostring(banIdCounter)
    banIdCounter = banIdCounter + 1
    saveBans()
    return id
end

function WaveShield.StoreBan(playerLicense, reason, duration, bannedBy, identifiers)
    local banId = nextBanId()
    local expiry = (duration and duration > 0) and (os.time() + duration * 86400) or -1
    bans[banId] = {
        banId = banId,
        license = playerLicense,
        reason = reason,
        bannedBy = bannedBy or "WaveShield",
        bannedAt = os.time(),
        expiresAt = expiry,
        isPermanent = expiry == -1,
        identifiers = identifiers or {},
    }
    saveBans()
    return banId, bans[banId]
end

function WaveShield.CheckBan(playerLicense, identifiers)
    local now = os.time()
    for banId, banData in pairs(bans) do
        if banData.license == playerLicense then
            if banData.isPermanent or banData.expiresAt > now then
                return true, banData
            else
                bans[banId] = nil
                saveBans()
            end
        end
        if identifiers then
            for _, id in pairs(identifiers) do
                for _, bannedId in pairs(banData.identifiers or {}) do
                    if id == bannedId and (banData.isPermanent or banData.expiresAt > now) then
                        return true, banData
                    end
                end
            end
        end
    end
    return false, nil
end

function WaveShield.RemoveBan(banId)
    if bans[banId] then
        local banData = bans[banId]
        bans[banId] = nil
        saveBans()
        return true, banData
    end
    return false, nil
end

function WaveShield.RemoveAllBans()
    local count = 0
    for _ in pairs(bans) do count = count + 1 end
    bans = {}
    banIdCounter = 1
    saveBans()
    return count
end

function WaveShield.GetBan(banId)
    return bans[banId]
end

function WaveShield.GetAllBans()
    return bans
end
