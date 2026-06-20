function WaveShield.Cache:new(keyLock, valueLock)
    local cache = {
        keyLock = keyLock or "any",
        valueLock = valueLock or "any",
        data = {},
    }
    self.__index = self
    self.__call = function(self, key)
        if not key then return self.data end
        return self:get(key)
    end
    return setmetatable(cache, self)
end

function WaveShield.Cache:set(key, value)
    rawset(self.data, key, value)
end

function WaveShield.Cache:reset(newData)
    self.data = newData
end

function WaveShield.Cache:get(key)
    return rawget(self.data, key)
end

function WaveShield.Cache:invalidate(key)
    rawset(self.data, key, nil)
end
