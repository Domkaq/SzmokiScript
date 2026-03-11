-- =====================================================
-- Karakteralkotó specifikus funkciók
-- =====================================================

local creator = {}

function creator:run(config)
    print("[CREATOR] Indítás...")
    
    -- Services
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Workspace = game:GetService("Workspace")
    local LocalPlayer = Players.LocalPlayer
    
    -- GUI keresés
    local creationGui = LocalPlayer.PlayerGui:FindFirstChild("CreationGUI")
    if not creationGui then
        print("[CREATOR] HIBA: CreationGUI nem található!")
        return
    end
    
    -- Modul betöltése
    local appearanceModule = require(ReplicatedStorage:WaitForChild("appearanceModule"))
    
    -- 1. NEVEK HOZZÁADÁSA
    pcall(function()
        table.insert(appearanceModule.firstNames.boyNames, config.firstName)
        table.insert(appearanceModule.firstNames.girlNames, config.firstName)
        table.insert(appearanceModule.lastNames, config.lastName)
        print("[CREATOR] Nevek hozzáadva")
    end)
    
    -- 2. LEGSÖTÉTEBB BŐR BEÁLLÍTÁSA
    self:setDarkestSkin(creationGui, appearanceModule, config)
    
    -- 3. CIPŐ RENDSZER
    self:setupShoes(creationGui, appearanceModule, config)
    
    -- 4. ATTRIBÚTUMOK HACKELÉSE
    self:hackAttributes(creationGui, config)
    
    -- 5. MARKINGS FELOLDÁSA
    self:unlockMarkings(creationGui)
    
    -- 6. UI FRISSÍTÉS
    self:updateUI(creationGui, config)
    
    -- 7. REMOTE HOOK
    self:setupRemoteHook(creationGui, config)
    
    -- 8. VÉDELMEK
    self:setupProtections(LocalPlayer)
    
    print("[CREATOR] Minden kész! Nyomd meg a Play gombot!")
end

-- LEGSÖTÉTEBB BŐR BEÁLLÍTÁSA
function creator:setDarkestSkin(creationGui, appearanceModule, config)
    -- A skintones táblában a legsötétebb általában "darker" vagy "dark"
    local skinTones = appearanceModule.skintones
    local darkest = "darker"  -- alapértelmezett
    
    -- Megkeressük a legsötétebbet (Color3 érték alapján)
    local darkestValue = 1
    for name, color in pairs(skinTones) do
        local brightness = color.R + color.G + color.B
        if brightness < darkestValue then
            darkestValue = brightness
            darkest = name
        end
    end
    
    config.skinTone = darkest
    print("[CREATOR] Legsötétebb bőr: " .. darkest)
    
    -- UI frissítés
    local appFrame = creationGui:FindFirstChild("appearanceFrame")
    if appFrame then
        local skinFrame = appFrame:FindFirstChild("skintone")
        if skinFrame and skinFrame:FindFirstChild("selectionLabel") then
            skinFrame.selectionLabel.Text = darkest:upper()
        end
    end
    
    -- Dummy karakter színének változtatása
    local dummy = Workspace:FindFirstChild("DummyCharacter")
    if dummy then
        local skinColor = skinTones[darkest]
        for _, part in pairs(dummy:GetChildren()) do
            if part:IsA("MeshPart") or part:IsA("Part") then
                part.Color = skinColor
            end
        end
        -- Fülek
        local ears = dummy:FindFirstChild("Ears")
        if ears and ears:FindFirstChild("Handle") then
            ears.Handle.Left.Color = skinColor
            ears.Handle.Right.Color = skinColor
        end
    end
end

-- CIPŐ RENDSZER
function creator:setupShoes(creationGui, appearanceModule, config)
    local appFrame = creationGui:FindFirstChild("appearanceFrame")
    if not appFrame then return end
    
    local shoesFrame = appFrame:FindFirstChild("shoes")
    if not shoesFrame then
        -- Ha nincs, létrehozunk egyet
        shoesFrame = Instance.new("Frame")
        shoesFrame.Name = "shoes"
        shoesFrame.Size = UDim2.new(0, 300, 0, 50)
        shoesFrame.Position = UDim2.new(0, 0, 0, 200)
        shoesFrame.Parent = appFrame
    end
    
    -- Lockolt gombok eltávolítása
    for _, child in pairs(shoesFrame:GetChildren()) do
        if child:IsA("TextButton") and (child.Name:find("locked") or child.Name:find("Locked")) then
            child:Destroy()
        end
    end
    
    -- SelectionLabel
    local selectionLabel = shoesFrame:FindFirstChild("selectionLabel")
    if not selectionLabel then
        selectionLabel = Instance.new("TextLabel")
        selectionLabel.Name = "selectionLabel"
        selectionLabel.Size = UDim2.new(0, 150, 0, 30)
        selectionLabel.Position = UDim2.new(0, 140, 0, 10)
        selectionLabel.Text = (config.shoe or "whiteNavy1s"):upper()
        selectionLabel.Parent = shoesFrame
    end
    
    -- Gombok
    local whiteBtn = shoesFrame:FindFirstChild("whiteOption")
    if not whiteBtn then
        whiteBtn = Instance.new("TextButton")
        whiteBtn.Name = "whiteOption"
        whiteBtn.Text = "WHITE"
        whiteBtn.Size = UDim2.new(0, 60, 0, 30)
        whiteBtn.Position = UDim2.new(0, 10, 0, 10)
        whiteBtn.Parent = shoesFrame
    end
    
    local blackBtn = shoesFrame:FindFirstChild("blackOption")
    if not blackBtn then
        blackBtn = Instance.new("TextButton")
        blackBtn.Name = "blackOption"
        blackBtn.Text = "BLACK"
        blackBtn.Size = UDim2.new(0, 60, 0, 30)
        blackBtn.Position = UDim2.new(0, 80, 0, 10)
        blackBtn.Parent = shoesFrame
    end
    
    -- Dummy karakter
    local dummy = Workspace:FindFirstChild("DummyCharacter") or Workspace:WaitForChild("DummyCharacter", 5)
    
    -- Cipő alkalmazó függvény
    local function applyShoe(shoeName)
        if not dummy then return end
        local shoeData = appearanceModule.clothes.shoes[shoeName]
        if not shoeData then return end
        
        -- Régi cipők törlése
        for _, child in pairs(dummy:GetChildren()) do
            if child:IsA("Accessory") and (child.Name == "LeftShoe" or child.Name == "RightShoe") then
                child:Destroy()
            end
        end
        
        -- Új cipők
        local left = shoeData.leftShoeClone:Clone()
        local right = shoeData.rightShoeClone:Clone()
        left.Name = "LeftShoe"
        right.Name = "RightShoe"
        
        left.Parent = dummy:FindFirstChild("LeftFoot") or dummy
        right.Parent = dummy:FindFirstChild("RightFoot") or dummy
        
        -- Hegesztés
        local function weld(part0, part1, cframe)
            local weld = Instance.new("Weld")
            weld.Part0 = part0
            weld.Part1 = part1
            weld.C0 = cframe
            weld.Parent = part0
        end
        
        weld(left.Handle, left.Parent, shoeData.leftAttachment)
        weld(right.Handle, right.Parent, shoeData.rightAttachment)
        
        selectionLabel.Text = shoeData.name:upper()
        config.shoe = shoeName  -- eltároljuk a konfigban
    end
    
    -- Alapértelmezett cipő
    pcall(function() applyShoe(config.shoe or "whiteNavy1s") end)
    
    -- Gombok eseményei
    whiteBtn.MouseButton1Down:Connect(function()
        pcall(function() applyShoe("whiteNavy1s") end)
    end)
    
    blackBtn.MouseButton1Down:Connect(function()
        pcall(function() applyShoe("blackNavy1s") end)
    end)
end

-- ATTRIBÚTUMOK HACKELÉSE
function creator:hackAttributes(creationGui, config)
    local abilitiesFrame = creationGui:FindFirstChild("abilitiesFrame")
    if not abilitiesFrame then return end
    
    -- Attribútum gombok letiltása
    local attrNames = {"strength", "stamina", "smarts", "stress"}
    for _, name in pairs(attrNames) do
        local container = abilitiesFrame:FindFirstChild(name)
        if container then
            for _, btn in pairs(container:GetChildren()) do
                if btn:IsA("TextButton") and (btn.Name == "raiseOption" or btn.Name == "lowerOption") then
                    local cons = getconnections and getconnections(btn.MouseButton1Down)
                    if cons then
                        for _, con in pairs(cons) do
                            con:Disable()
                        end
                    else
                        btn.MouseButton1Down:Connect(function() end)
                    end
                end
            end
        end
    end
    
    -- Reset gomb letiltása
    local attributes = abilitiesFrame:FindFirstChild("attributes")
    if attributes then
        local resetBtn = attributes:FindFirstChild("resetOption")
        if resetBtn then
            local cons = getconnections and getconnections(resetBtn.MouseButton1Down)
            if cons then
                for _, con in pairs(cons) do
                    con:Disable()
                end
            end
        end
    end
    
    -- UI frissítés
    local pointsLabel = attributes and attributes:FindFirstChild("pointsLabel")
    if pointsLabel then
        pointsLabel.Text = "POINTS • ∞"
    end
    
    for _, name in pairs(attrNames) do
        local container = abilitiesFrame:FindFirstChild(name)
        if container and container:FindFirstChild("levelLabel") then
            container.levelLabel.Text = "LEVEL • " .. tostring(config.attributes[name:sub(1,1):upper()..name:sub(2)] or 100)
        end
    end
end

-- MARKINGS FELOLDÁSA
function creator:unlockMarkings(creationGui)
    local appFrame = creationGui:FindFirstChild("appearanceFrame")
    if not appFrame then return end
    
    local markingsFrame = appFrame:FindFirstChild("markings")
    if markingsFrame then
        for _, child in pairs(markingsFrame:GetChildren()) do
            if child:IsA("TextButton") and (child.Name:find("locked") or child.Name:find("Locked")) then
                child:Destroy()
            end
        end
        
        if not markingsFrame:FindFirstChild("selectionLabel") then
            local lbl = Instance.new("TextLabel")
            lbl.Name = "selectionLabel"
            lbl.Text = "NONE"
            lbl.Size = UDim2.new(0, 100, 0, 30)
            lbl.Position = UDim2.new(0, 0, 0, 0)
            lbl.Parent = markingsFrame
        else
            markingsFrame.selectionLabel.Text = "NONE"
        end
    end
end

-- UI FRISSÍTÉS
function creator:updateUI(creationGui, config)
    local appFrame = creationGui:FindFirstChild("appearanceFrame")
    if appFrame then
        -- Nevek
        local firstName = appFrame:FindFirstChild("firstname", true)
        if firstName and firstName:FindFirstChild("selectionLabel") then
            firstName.selectionLabel.Text = config.firstName:upper()
        end
        
        local lastName = appFrame:FindFirstChild("lastname", true)
        if lastName and lastName:FindFirstChild("selectionLabel") then
            lastName.selectionLabel.Text = config.lastName:upper()
        end
        
        -- Bőrszín
        local skinTone = appFrame:FindFirstChild("skintone", true)
        if skinTone and skinTone:FindFirstChild("selectionLabel") then
            skinTone.selectionLabel.Text = config.skinTone:upper()
        end
    end
    
    -- Continue gomb rögzítése
    local continueFrame = creationGui:FindFirstChild("continueFrame")
    if continueFrame then
        coroutine.wrap(function()
            while continueFrame do
                task.wait(0.5)
                continueFrame.Position = UDim2.new(0.34, 0, 0.9, 0)
            end
        end)()
    end
end

-- REMOTE HOOK
function creator:setupRemoteHook(creationGui, config)
    local remote = creationGui:FindFirstChild("sendData")
    if not remote then return end
    
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        
        if self == remote and method == "FireServer" then
            local data = args[1]
            if type(data) == "table" then
                -- Nevek
                if data.appearanceData then
                    data.appearanceData.FirstName = config.firstName
                    data.appearanceData.LastName = config.lastName
                    data.appearanceData.SkinTone = config.skinTone
                end
                
                -- Attribútumok
                if data.abilitiesData then
                    data.abilitiesData.Strength = config.attributes.Strength
                    data.abilitiesData.Stamina = config.attributes.Stamina
                    data.abilitiesData.Smarts = config.attributes.Smarts
                    data.abilitiesData.Stress = config.attributes.Stress
                end
                
                -- Cipő
                if data.clothingData then
                    data.clothingData.Shoes = config.shoe or "whiteNavy1s"
                end
            end
            return oldNamecall(self, unpack(args))
        end
        return oldNamecall(self, ...)
    end)
end

-- VÉDELMEK
function creator:setupProtections(LocalPlayer)
    -- Kick védelem
    pcall(function()
        hookfunction(LocalPlayer.Kick, function(self, msg)
            print("[VÉDELEM] Kick megakadályozva: " .. tostring(msg))
            return nil
        end)
    end)
end

return creator
