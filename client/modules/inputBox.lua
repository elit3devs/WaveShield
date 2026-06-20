local isInputBoxDisplayed = false

local checkInputBox = function()
    if not WaveShield.Config.Main.AntiInputBox then
        return
    end

    if not isInputBoxDisplayed and UpdateOnscreenKeyboard() == 0 then
        WaveShield.DetectPlayer(WaveShield.Detections.ANTI_INPUT_BOX)
        return
    end
end)

WaveShield.RegisterDetection("inputBox", checkInputBox, 1000)

exports("displayInputBox", function()
    isInputBoxDisplayed = true
    WaveShield.CreateThread(function()
        while true do
            if UpdateOnscreenKeyboard() ~= 0 then
                break
            end
            WaveShield.Wait(100)
        end
        WaveShield.Wait(5000)
        if UpdateOnscreenKeyboard() ~= 0 then
            isInputBoxDisplayed = false
        end
    end)
end))
