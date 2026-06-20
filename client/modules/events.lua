local bannableEvents = {
    GetCurrentResourceName().. ".verify",
    "HCheat:TempDisableDetection",
    "adminmenu:allowall",
    "antilynx8:crashuser",
    "shilling=yet5",
    "antilynxr4:crashuser",
    "shilling=yet7",
    "antilynxr4:crashuser1",
}

for k,v in WaveShield.Lua.pairs(bannableEvents) do
    RegisterNetEvent(v)
    AddEventHandler(v, function()
        WaveShield.DetectPlayer(WaveShield.Detections.ANTI_TRIGGER_CLIENT_EVENT, {
            event = v,
        })
    end)
end-- ZmZmZmZmZmZmZmZmZmZtbW1tbW1tbW1tbW1tbW1tbW1tYWFhYWFhYWFhYWFhYWFhYWE=
