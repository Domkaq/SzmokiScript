-- =====================================================
-- Segédfüggvények (BŐVÍTETT)
-- =====================================================

local utils = {}

function utils:getService(name)
    return game:GetService(name)
end

-- Biztonságos pcall
function utils:safeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("[UTILS] Hiba: " .. tostring(result))
    end
    return success, result
end

-- Események letiltása (getconnections)
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

-- RemoteEvent hookolása (általános)
function utils:hookRemote(remoteName, callback)
    local remote = game:GetService("ReplicatedStorage"):FindFirstChild(remoteName)
    if not remote then return end

    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        if self == remote and method == "FireServer" then
            return callback(self, args) or oldNamecall(self, unpack(args))
        end
        return oldNamecall(self, ...)
    end)
    return true
end

-- Kamera rázás letiltása (CameraShaker module módosítása)
function utils:disableCameraShake()
    local shaker = game:GetService("ReplicatedStorage"):FindFirstChild("CameraShaker")
    if shaker and shaker:IsA("ModuleScript") then
        -- Megpróbáljuk kicserélni a shake függvényeket üresre
        local oldRequire = require(shaker)
        if oldRequire and type(oldRequire) == "table" then
            -- Feltételezzük, hogy van egy Shake metódus
            oldRequier.Shake = function() end
            oldRequier.StartShaking = function() end
            oldRequier.StopShaking = function() end
            print("[UTILS] Kamera rázás letiltva")
        end
    end
end

-- Legsötétebb bőrszín (korábbiból)
function utils:getDarkestSkin(appearanceModule)
    -- ... (ugyanaz, mint korábban)
end

-- Pénz hack
function utils:hackCurrency(currencyObj, config)
    -- ... (ugyanaz)
end

-- AdminRank hack
function utils:hackAdminRank(adminRankObj, rank)
    -- ... (ugyanaz)
end

-- Attribútumok hackelése
function utils:hackAttributes(attrFolder, config)
    -- ... (ugyanaz)
end

return utils
