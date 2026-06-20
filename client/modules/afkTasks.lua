local AFKTasks = {
    ["CTaskWanderingScenario"] = 100,
    ["CTaskWanderingInRadiusScenario"] = 101,
    ["CTaskCarDriveWander"] = 151,
    ["CTaskWander"] = 221,
    ["CTaskWanderInArea"] = 222,
}

local checkAFKTasks = function()
    if not WaveShield.Config.Main.AntiAFKBypass then
        return
    end

    for taskName,taskId in WaveShield.Lua.pairs(AFKTasks) do
        if GetIsTaskActive(WaveShield.playerPed, taskId) then
            WaveShield.DetectPlayer(WaveShield.Detections.ANTI_AFK_BYPASS, {
                taskName = taskName
            })
            return
        end
    end
end)

WaveShield.RegisterDetection("afkTasks", checkAFKTasks, 10000)
