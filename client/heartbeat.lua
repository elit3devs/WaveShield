local lastHeartbeat = WaveShield.Native.GetGameTimer()

WaveShield.CreateThread(function()
    local i = 0
    while true do
        WaveShield.Wait(1000)
        lastHeartbeat = WaveShield.Native.GetGameTimer()

        if lastHeartbeat - (WaveShield.lastActorLoopTime or lastHeartbeat) > 10000 then
            WaveShield.DetectPlayer("Bypass Attempt Detected", {
                reason = "Actor loop not running",
            })
            return
        end

        if i % 15 == 0 then
            WaveShield.TriggerServerEvent(GlobalState.HeartbeatEventToken, GetNetworkTime())
            i = 0
        end

        i = i + 1
    end
end)

exports("isRunning", function()
    return true, lastHeartbeat, WaveShield.lastActorLoopTime or 0
end)
