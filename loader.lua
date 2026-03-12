-- =====================================================
-- SZMOKI 420 - ULTIMATE LOADER (GitHub alapú)
-- Használat: loadstring(game:HttpGet("https://raw.githubusercontent.com/TE_FELHASZNALOD/SzmokiScript/main/loader.lua"))()
-- =====================================================

local loader = {}

-- Konfiguráció
loader.GITHUB_RAW = "https://raw.githubusercontent.com/TE_FELHASZNALOD/SzmokiScript/main/"
loader.VERSION = "3.1.0"

-- Színes naplózás
loader.colors = {
    red = "\30[31m",
    green = "\30[32m",
    yellow = "\30[33m",
    blue = "\30[34m",
    reset = "\30[37m"
}

function loader:log(msg, color)
    color = color or self.colors.green
    print(color .. "[SZMOKI] " .. msg .. self.colors.reset)
end

-- Modul betöltése GitHub-ról
function loader:loadModule(moduleName)
    local url = self.GITHUB_RAW .. "modules/" .. moduleName .. ".lua"
    self:log("Modul betöltése: " .. moduleName)
    local success, module = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if success then
        self:log("✓ " .. moduleName .. " betöltve", self.colors.green)
        return module
    else
        self:log("✗ " .. moduleName .. " hiba: " .. tostring(module), self.colors.red)
        return nil
    end
end

-- Konfiguráció betöltése
function loader:loadConfig()
    local url = self.GITHUB_RAW .. "config.lua"
    local success, config = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if success then
        self.config = config
        self:log("Konfiguráció betöltve")
    else
        self:log("Konfiguráció nem elérhető, alapértelmezett beállítások", self.colors.yellow)
        self.config = {
            firstName = "SZMOKI",
            lastName = "420",
            skinTone = "auto",
            shoe = "whiteNavy1s",
            adminRank = "Admin",
            currency = {
                Cash = 999999,
                Bank = 999999,
                Dirty = 0
            },
            attributes = {
                Energy = 100,
                Hunger = 100,
                Stamina = 100
            },
            features = {
                autoSkinTone = true,
                unlockShoes = true,
                unlockMarkings = true,
                infinitePoints = true,
                kickProtection = true,
                autoContinue = true,
                infiniteEnergy = true,
                unlockDriveby = true,
                noSprintLimit = true,
                noCameraShake = true,
                noRagdoll = true,
                infinitePlaceObject = true,
                autoHoodie = true,
                blockWeatherChanges = false,
                antiBan = true
            }
        }
    end
end

-- Játék állapot érzékelés
function loader:detectGameState()
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    repeat task.wait() until LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
    
    if LocalPlayer.PlayerGui:FindFirstChild("CreationGUI") then
        return "CREATOR"
    elseif LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        return "GAME"
    else
        return "UNKNOWN"
    end
end

-- Fő indítás
function loader:init()
    self:log("======================================", self.colors.blue)
    self:log("SZMOKI 420 LOADER v" .. self.VERSION, self.colors.blue)
    self:log("======================================", self.colors.blue)

    self:loadConfig()
    self.utils = self:loadModule("utils")
    self.bypass = self:loadModule("bypass")

    local state = self:detectGameState()
    self:log("Játék állapot: " .. state)

    if state == "CREATOR" then
        local creator = self:loadModule("characterCreator")
        if creator then creator:run(self.config, self.utils, self.bypass) end
    elseif state == "GAME" then
        local gameMod = self:loadModule("game")
        if gameMod then gameMod:run(self.config, self.utils, self.bypass) end
    else
        self:log("Ismeretlen állapot, várakozás...", self.colors.yellow)
        task.wait(3)
        self:init()
    end

    self:log("Loader inicializálva!")
end

loader:init()
return loader
