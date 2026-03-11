-- =====================================================
-- Segédfüggvények
-- =====================================================

local utils = {}

-- Szolgáltatások gyors elérése
utils.Services = {
    Players = game:GetService("Players"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Workspace = game:GetService("Workspace"),
    TweenService = game:GetService("TweenService"),
    RunService = game:GetService("RunService")
}

-- Várakozás amíg egy elem betöltődik
function utils:waitForChild(parent, childName, timeout)
    timeout = timeout or 10
    local start = os.clock()
    while os.clock() - start < timeout do
        local child = parent:FindFirstChild(childName)
        if child then return child end
        task.wait()
    end
    return nil
end

-- Biztonságos függvényhívás
function utils:safeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("[UTILS] Hiba: " .. tostring(result))
    end
    return success, result
end

-- Események letiltása
function utils:disableEvents(instance, eventName)
    local cons = getconnections and getconnections(instance[eventName])
    if cons then
        for _, con in pairs(cons) do
            con:Disable()
        end
        return true
    end
    return false
end

-- Szín világosságának kiszámítása
function utils:getColorBrightness(color)
    return color.R + color.G + color.B
end

return utils
