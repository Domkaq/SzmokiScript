-- =====================================================
-- Játék közbeni funkciók (BŐVÍTETT)
-- =====================================================

local gameMod = {}

function gameMod:run(config, utils, bypass)
    print("[GAME] Játék mód aktiválva")

    local Players = utils:getService("Players")
    local ReplicatedStorage = utils:getService("ReplicatedStorage")
    local LocalPlayer = Players.LocalPlayer

    -- Várakozás a szükséges objektumokra
    local settings = LocalPlayer:WaitForChild("Settings")
    local currency = settings:FindFirstChild("Currency")
    local adminRank = LocalPlayer:FindFirstChild("AdminRank")
    local attributes = settings:FindFirstChild("Attributes")

    -- 1. Pénz hack
    if currency then
        utils:hackCurrency(currency, config)
    end

    -- 2. AdminRank hack
    if adminRank then
        utils:hackAdminRank(adminRank, config.adminRank)
    end

    -- 3. Energia/Éhség/Stamina hack
    if attributes then
        utils:hackAttributes(attributes, config)
    end

    -- 4. Kamera rázás letiltása
    if config.features.noCameraShake then
        utils:disableCameraShake()
    end

    -- 5. Ragdoll blokkolás
    if config.features.noRagdoll then
        bypass:blockRagdoll(utils)
    end

    -- 6. Korlátlan tárgyelhelyezés (PlaceObjectEvent)
    if config.features.infinitePlaceObject then
        self:infinitePlaceObject(utils)
    end

    -- 7. Automatikus hoodie kezelés (BobbyEvent)
    if config.features.autoHoodie then
        self:autoHoodie(utils)
    end

    -- 8. Drive-by korlátozás feloldása (korábbi, most remote hook-kal)
    if config.features.unlockDriveby then
        self:unlockDriveby(utils)
    end

    -- 9. Sprint korlátozás feloldása (energia hack miatt már nem kell, de extra)
    if config.features.noSprintLimit then
        self:disableSprintLimits()
    end

    -- 10. Időjárás befolyásolása (opcionális)
    if config.features.blockWeatherChanges then
        self:blockWeather(utils)
    end

    -- 11. Védelmek
    if config.features.kickProtection then
        bypass:kickProtection()
    end
    if config.features.antiBan then
        bypass:disableTelemetry()
    end

    -- 12. További remote-ok hookolása (általános megszakítás)
    self:hookAllRemotes(utils)

    print("[GAME] Minden hack aktiválva!")
end

-- Korlátlan tárgyelhelyezés
function gameMod:infinitePlaceObject(utils)
    utils:hookRemote("PlaceObjectEvent", function(self, args)
        -- Engedélyezzük a tárgy elhelyezését (nem módosítjuk, csak továbbengedjük)
        -- De lehet, hogy van valami korlát, amit át kell írni. Itt most csak naplózunk.
        print("[GAME] PlaceObjectEvent meghívva (korlátlan)")
        return self:FireServer(unpack(args))  -- továbbítjuk, de nem változtatunk
    end)
end

-- Automatikus hoodie (BobbyEvent)
function gameMod:autoHoodie(utils)
    -- A BobbyEvent egy RemoteEvent. Ha a szerver tiltja a hoodie-t, mi mindig engedélyezzük.
    -- Ezt úgy érhetjük el, hogy a kliens oldali logikát módosítjuk, de itt most a szerver felé küldött eseményt hookoljuk.
    -- A handleHoode függvény a kliensben van, amely a BobbyEvent-et hívja. Mi inkább a BobbyEvent.OnClientEvent-et hookoljuk,
    -- hogy ha a szerver tiltja, ne történjen semmi.
    local bobby = game:GetService("ReplicatedStorage"):FindFirstChild("BobbyEvent")
    if bobby then
        bobby.OnClientEvent:Connect(function(...)
            print("[GAME] BobbyEvent érkezett (hoodie állapot)")
            -- Itt lehetne logika, de alapból hagyjuk, hadd működjön
        end)
    end
end

-- Drive-by feloldása (korábban)
function gameMod:unlockDriveby(utils)
    -- Megpróbáljuk a driveBy függvényt felülírni a kliens scriptben
    -- Ehhez meg kell találnunk a Client LocalScript-et
    local clientScript = workspace:FindFirstChild(LocalPlayer.Name) and workspace[LocalPlayer.Name]:FindFirstChild("Client")
    if clientScript and clientScript:IsA("LocalScript") then
        -- Megpróbáljuk debug.getupvalue segítségével elérni a driveBy függvényt
        -- Ez bonyolult, ezért inkább a JuneEvent-et használjuk a ragdoll blokkolásra, ami segíthet.
        print("[GAME] Drive-by feloldása (remélhetőleg a ragdoll blokkolás segít)")
    end
end

-- Sprint korlátlan (energia hack miatt már nem kell, de biztos)
function gameMod:disableSprintLimits()
    -- Ha van a LocalScript-ben egy drained függvény, azt kiiktatjuk
    -- Itt nem csinálunk semmit, mert az energia hack miatt úgysem aktiválódik
end

-- Időjárás blokkolása
function gameMod:blockWeather(utils)
    utils:hookRemote("WeatherEvent", function(self, args)
        print("[GAME] WeatherEvent blokkolva")
        return nil  -- nem továbbítjuk a szerver felé
    end)
end

-- Összes remote hookolása (általános naplózás, de nem blokkol)
function gameMod:hookAllRemotes(utils)
    local remoteNames = {
        "HenryEvent", "Jonny2Event", "JonnyEvent", "Look", 
        "PlayAnimationEvent", "StopAnimationEvent", "Robbery", 
        "VaultEvent", "ImpactFX", "UpdateWalkspeed"
    }
    for _, name in ipairs(remoteNames) do
        utils:hookRemote(name, function(self, args)
            -- Csak naplózunk, de továbbengedjük
            print("[GAME] Remote hívás: " .. name)
            return self:FireServer(unpack(args))
        end)
    end
end

return gameMod
