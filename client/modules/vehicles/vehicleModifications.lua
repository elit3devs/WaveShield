local lastVehiclePlate, lastVehicle = "", 0

local checkVehiclePlateChanger = function()
    if not WaveShield.Config.Entities.AntiVehiclePlateChanger then
        return
    end

    if not WaveShield.isPlayerInVehicle or not WaveShield.isPlayerDriver then
        lastVehiclePlate, lastVehicle = "", 0
        return
    end

    if WaveShield.Native.GetGameTimer() < (WaveShield.GetSecuredStateBag("_WS:LastChangedVehiclePlate") or 0) + 10000 then
        lastVehiclePlate, lastVehicle = "", 0
        return
    end 
    
    local vehiclePlate = string.gsub(GetVehicleNumberPlateText(WaveShield.playerCurrentVehicle) or "", "%s+", "")

    if DoesEntityExist(WaveShield.playerCurrentVehicle) and WaveShield.playerCurrentVehicle == lastVehicle and vehiclePlate and vehiclePlate ~= lastVehiclePlate then
        WaveShield.DetectPlayer(WaveShield.Detections.ANTI_VEHICLE_PLATE_CHANGER, {
            oldPlate = lastVehiclePlate,
            newPlate = vehiclePlate,
        })
    end

    lastVehiclePlate = vehiclePlate
    lastVehicle = WaveShield.playerCurrentVehicle
end

WaveShield.RegisterDetection("vehiclePlateChanger", checkVehiclePlateChanger, 3000)

RegisterNetEvent("__WaveShield:setVehicleNumberPlateText", function(plateText)
    if not plateText then return end
    WaveShield.SetSecuredStateBag("_WS:LastChangedVehiclePlate", WaveShield.Native.GetGameTimer(), false)
end)

exports("ChangeVehiclePlate", function(vehicle, plateText)
    if not plateText then return end
    WaveShield.SetSecuredStateBag("_WS:LastChangedVehiclePlate", WaveShield.Native.GetGameTimer(), false)
end)
