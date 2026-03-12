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
            oldRequire.Shake = function() end
            oldRequire.StartShaking = function() end
            oldRequire.StopShaking = function() end
            print("[UTILS] Kamera rázás letiltva")
        end
    end
end

-- Legsötétebb bőrszín kiválasztása a modulból
function utils:getDarkestSkin(appearanceModule)
    local skinTones = appearanceModule.skintones
    local darkest, darkestValue = nil, 999
    for name, color in pairs(skinTones) do
        local brightness = color.R + color.G + color.B
        if brightness < darkestValue then
            darkestValue = brightness
            darkest = name
        end
    end
    return darkest or "darker"
end

-- Pénz hack (attribútumok módosítása)
function utils:hackCurrency(currencyObj, config)
    if not currencyObj then return end
    currencyObj:SetAttribute("Cash", config.currency.Cash)
    currencyObj:SetAttribute("Bank", config.currency.Bank)
    currencyObj:SetAttribute("Dirty", config.currency.Dirty)
    print("[CURRENCY] Pénz beállítva: Cash=" .. config.currency.Cash .. " Bank=" .. config.currency.Bank)
end

-- AdminRank hack
function utils:hackAdminRank(adminRankObj, rank)
    if adminRankObj and adminRankObj:IsA("StringValue") then
        adminRankObj.Value = rank
        print("[ADMIN] Rang beállítva: " .. rank)
    end
end

-- Attribútumok hackelése (Energy, Hunger, Stamina)
function utils:hackAttributes(attrFolder, config)
    if not attrFolder then return end
    for k, v in pairs(config.attributes) do
        attrFolder:SetAttribute(k, v)
    end
    print("[ATTRIBUTES] Energia/Éhség/Stamina beállítva")
end

return utils
