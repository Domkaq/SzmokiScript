-- =====================================================
-- Általános bypass-ok (KIBŐVÍTVE)
-- =====================================================

local bypass = {}

function bypass:kickProtection()
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    pcall(function()
        hookfunction(LocalPlayer.Kick, function(self, msg)
            print("[BYpass] Kick megakadályozva: " .. tostring(msg))
            return nil
        end)
    end)
    print("[BYpass] Kick védelem aktív")
end

function bypass:disableTelemetry()
    pcall(function()
        local telemetry = game:GetService("TelemetryService")
        telemetry:SetReportAbuse(false)
    end)
end

-- Anti-ragdoll: JuneEvent és CombatEvent blokkolása
function bypass:blockRagdoll(utils)
    -- JuneEvent: OnClientEvent – ha a szerver ragdoll-t akar, nem csinálunk semmit
    local juneEvent = game:GetService("ReplicatedStorage"):FindFirstChild("JuneEvent")
    if juneEvent and juneEvent:IsA("RemoteEvent") then
        juneEvent.OnClientEvent:Connect(function(...)
            print("[BYpass] JuneEvent blokkolva (ragdoll)")
            -- Nem csinálunk semmit, így a ragdoll nem indul el
        end)
    end

    -- CombatEvent (bindable) – lehet, hogy ezt is blokkolni kell
    local combatEvent = game:GetService("ReplicatedStorage"):FindFirstChild("CombatEvent")
    if combatEvent and combatEvent:IsA("BindableEvent") then
        combatEvent.Event:Connect(function(...)
            print("[BYpass] CombatEvent blokkolva")
        end)
    end
    print("[BYpass] Ragdoll védelem aktív")
end

return bypass
