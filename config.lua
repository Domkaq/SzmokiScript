-- =====================================================
-- SZMOKI 420 - KONFIGURÁCIÓ
-- =====================================================

return {
    -- Alap adatok
    firstName = "SZMOKI",
    lastName = "420",
    
    -- Bőrszín (automatikusan a legsötétebbet választja)
    skinTone = "auto",  -- "auto" vagy konkrét név: "pale", "light", "medium", "brown", "dark", "darker"
    
    -- Cipő
    shoe = "whiteNavy1s",  -- "whiteNavy1s" vagy "blackNavy1s"
    
    -- Attribútumok
    attributes = {
        Strength = 100,
        Stamina = 100,
        Smarts = 100,
        Stress = 100
    },
    
    -- Extra funkciók
    features = {
        autoSkinTone = true,      -- Automatikus legsötétebb bőr
        unlockShoes = true,       -- Cipők feloldása
        unlockMarkings = true,    -- Markings feloldása
        infinitePoints = true,    -- Végtelen pontok (UI)
        kickProtection = true,     -- Kick védelem
        autoContinue = true        -- Continue gomb automatikus megjelenítése
    }
}
