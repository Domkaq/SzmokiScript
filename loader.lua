-- =====================================================
-- SZMOKI 420 - ULTIMATE LOADER (GitHub alapú)
-- Használat: loadstring(game:HttpGet("https://raw.githubusercontent.com/TE_FELHASZNALOD/SzmokiScript/main/loader.lua"))()
-- =====================================================

local loader = {}

-- Konfiguráció
loader.GITHUB_RAW = "https://raw.githubusercontent.com/TE_FELHASZNALOD/SzmokiScript/main/"
loader.VERSION = "2.0.0"
loader.AUTO_UPDATE = true

-- Színek a konzolhoz
loader.colors = {
    red = "\30[31m",
    green = "\30[32m",
    yellow = "\30[33m",
    blue = "\30[34m",
    reset = "\30[37m"
}

-- Logger függvény
function loader:log(msg, color)
    color = color or self.colors.green
    print(color .. "[SZMOKI] " .. msg .. self.colors.reset)
end

-- Hibakezelés
function loader:pcall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        self:log("Hiba: " .. tostring(result), self.colors.red)
    end
    return success, result
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
        self:log("✗ " .. moduleName .. " betöltése sikertelen: " .. tostring(module), self.colors.red)
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
        self:log("Konfiguráció betöltése sikertelen, alapértelmezett használata", self.colors.yellow)
        self.config = {
            firstName = "SZMOKI",
            lastName = "420",
            skinTone = "darker",      -- legsötétebb bőr
            shoe = "whiteNavy1s",
            attributes = {
                Strength = 100,
                Stamina = 100,
                Smarts = 100,
                Stress = 100
            }
        }
    end
end

-- Játék állapot érzékelés
function loader:detectGameState()
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    -- Várakozás a PlayerGui-ra
    repeat task.wait() until LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
    
    -- Karakteralkotó érzékelés
    local inCreator = LocalPlayer.PlayerGui:FindFirstChild("CreationGUI") ~= nil
    
    -- Játékban vagyunk-e (karakter létezik)
    local inGame = LocalPlayer.Character ~= nil and LocalPlayer.Character:FindFirstChild("Humanoid") ~= nil
    
    if inCreator then
        return "CREATOR"
    elseif inGame then
        return "GAME"
    else
        return "UNKNOWN"
    end
end

-- Fő inicializálás
function loader:init()
    self:log("======================================", self.colors.blue)
    self:log("SZMOKI 420 LOADER v" .. self.VERSION, self.colors.blue)
    self:log("======================================", self.colors.blue)
    
    -- Konfiguráció betöltése
    self:loadConfig()
    
    -- Segédmodulok betöltése
    self.utils = self:loadModule("utils")
    
    -- Játék állapot érzékelése
    local state = self:detectGameState()
    self:log("Játék állapot: " .. state)
    
    -- Állapot alapú modulok betöltése
    if state == "CREATOR" then
        self:log("Karakteralkotó mód aktiválva")
        self.creator = self:loadModule("characterCreator")
        if self.creator then
            self:pcall(self.creator.run, self.creator, self.config)
        end
    elseif state == "GAME" then
        self:log("Játék mód aktiválva")
        self.game = self:loadModule("game")
        if self.game then
            self:pcall(self.game.run, self.game, self.config)
        end
    else
        self:log("Ismeretlen állapot, várakozás...", self.colors.yellow)
        -- Várakozás és újrapróbálkozás
        task.wait(3)
        self:init()
    end
    
    self:log("Loader inicializálva!")
end

-- Loader indítása
loader:init()

return loader
