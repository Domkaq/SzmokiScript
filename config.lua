-- =====================================================
-- SZMOKI 420 - KONFIGURÁCIÓ (BŐVÍTETT)
-- =====================================================

return {
    -- Alap adatok
    firstName = "SZMOKI",
    lastName = "420",
    skinTone = "auto",               -- "auto" vagy konkrét név: "pale", "light", "medium", "brown", "dark", "darker"
    shoe = "whiteNavy1s",             -- "whiteNavy1s" vagy "blackNavy1s"
    adminRank = "Admin",               -- "Player", "Admin", "Mod", stb.

    -- Pénz
    currency = {
        Cash = 999999,
        Bank = 999999,
        Dirty = 0
    },

    -- Alapvető attribútumok (energia, éhség, stamina)
    attributes = {
        Energy = 100,
        Hunger = 100,
        Stamina = 100
    },

    -- Funkciók kapcsolói
    features = {
        -- Karakteralkotó
        autoSkinTone = true,
        unlockShoes = true,
        unlockMarkings = true,
        infinitePoints = true,
        autoContinue = true,

        -- Játék
        infiniteEnergy = true,
        unlockDriveby = true,
        noSprintLimit = true,

        -- Új funkciók
        noCameraShake = true,           -- Kamera rázás kikapcsolása
        noRagdoll = true,               -- Ragdoll blokkolása (JuneEvent, CombatEvent)
        infinitePlaceObject = true,      -- Korlátlan tárgyelhelyezés
        autoHoodie = true,               -- Hoodie automatikus kezelése (BobbyEvent)
        blockWeatherChanges = false,     -- Időjárás változások blokkolása (opcionális)

        -- Általános védelem
        kickProtection = true,
        antiBan = true                   -- Telemetria tiltás
    }
}
